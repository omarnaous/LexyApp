// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SalonImagesPage extends StatefulWidget {
  const SalonImagesPage({super.key, this.isAdmin, this.salonId});
  final bool? isAdmin;
  final String? salonId;

  @override
  State<SalonImagesPage> createState() => _SalonImagesPageState();
}

class _SalonImagesPageState extends State<SalonImagesPage> {
  late final String? userId;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    userId = widget.isAdmin == true
        ? widget.salonId
        : FirebaseAuth.instance.currentUser?.uid;
    _fetchSalonImages();
  }

  Future<void> _fetchSalonImages() async {
    if (userId == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Salons')
        .where('ownerUid', isEqualTo: userId)
        .get();

    final List<String> imageUrls = [];
    for (var doc in querySnapshot.docs) {
      List<dynamic> urls = doc['imageUrls'] ?? [];
      imageUrls.addAll(urls.cast<String>());
    }

    setState(() {
      _imageUrls = imageUrls;
    });
  }

  Future<void> _uploadImages() async {
    if (userId == null) {
      showCustomSnackBar(context, 'Error', 'No user logged in', isError: true);
      return;
    }

    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    if (_imageUrls.length + pickedFiles.length > 5) {
      showCustomSnackBar(
          context, 'Limit Exceeded', 'Maximum of 5 images allowed',
          isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final storageRef = FirebaseStorage.instance.ref();
      List<String> newImageUrls = [];

      for (var pickedFile in pickedFiles) {
        final File file = File(pickedFile.path);
        final imageRef = storageRef.child(
            'salon_images/$userId/${DateTime.now().millisecondsSinceEpoch}');
        await imageRef.putFile(file);
        final imageUrl = await imageRef.getDownloadURL();
        newImageUrls.add(imageUrl);
      }

      _imageUrls.addAll(newImageUrls);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({'imageUrls': _imageUrls});
      }

      showCustomSnackBar(context, 'Success', 'Images uploaded successfully');
    } catch (e) {
      showCustomSnackBar(context, 'Error', 'Failed to upload images: $e',
          isError: true);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    if (userId == null) return;

    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({
          'imageUrls': FieldValue.arrayRemove([imageUrl]),
        });
      }

      setState(() {
        _imageUrls.remove(imageUrl);
      });

      showCustomSnackBar(context, 'Success', 'Image deleted successfully');
    } catch (e) {
      showCustomSnackBar(context, 'Error', 'Failed to delete image: $e',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salon Images')),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = _imageUrls[index];
                return Card(
                  key: ValueKey(imageUrl),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrl,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () => _deleteImage(imageUrl),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _imageUrls.length < 5 ? _uploadImages : null,
        child: const Icon(Icons.upload),
      ),
    );
  }
}

void showCustomSnackBar(BuildContext context, String title, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      content:
          Text('$title: $message', style: const TextStyle(color: Colors.white)),
    ),
  );
}
