import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SalonImagesPage extends StatefulWidget {
  const SalonImagesPage({super.key});

  @override
  State<SalonImagesPage> createState() => _SalonImagesPageState();
}

class _SalonImagesPageState extends State<SalonImagesPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<String> _imageUrls = [];

  Future<void> _fetchSalonImages() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception('No user logged in');
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Salons')
        .where('ownerUid', isEqualTo: userId)
        .get();

    final List<String> imageUrls = [];
    for (var doc in querySnapshot.docs) {
      print(doc);
      List<dynamic> urls = doc['imageUrls'] ?? [];
      imageUrls.addAll(urls.cast<String>());
    }

    setState(() {
      _imageUrls = imageUrls;
    });
  }

  Future<void> _uploadImages() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      showCustomSnackBar(context, 'Error', 'No user logged in', isError: true);
      return;
    }

    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    if (_imageUrls.length + pickedFiles.length > 5) {
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, 'Limit Exceeded',
          'You can only upload a maximum of 5 images',
          isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref();
      for (var pickedFile in pickedFiles) {
        final File file = File(pickedFile.path);
        final imageRef = storageRef.child(
            'salon_images/$userId/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = await imageRef.putFile(file);
        final imageUrl = await uploadTask.ref.getDownloadURL();
        _imageUrls.add(imageUrl);
      }

      // Update Firestore with new image URLs
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final salonDoc = querySnapshot.docs.first;
        await salonDoc.reference.update({
          'imageUrls': _imageUrls,
        });
      }

      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, 'Success', 'Images uploaded successfully');
    } catch (e) {
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, 'Error', 'Failed to upload images: $e',
          isError: true);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      showCustomSnackBar(context, 'Error', 'No user logged in', isError: true);
      return;
    }

    try {
      // Step 1: Delete from Firebase Storage
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();

      // Step 2: Remove URL from Firestore
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

      // Step 3: Update local state to reflect the changes
      setState(() {
        _imageUrls.remove(imageUrl);
      });

      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, 'Success', 'Image deleted successfully');
    } catch (e) {
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, 'Error', 'Failed to delete image: $e',
          isError: true);
    }
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String movedImage = _imageUrls.removeAt(oldIndex);
      _imageUrls.insert(newIndex, movedImage);
    });

    // Update Firestore with the new order
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('Salons')
          .where('ownerUid', isEqualTo: userId)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final salonDoc = querySnapshot.docs.first;
          salonDoc.reference.update({'imageUrls': _imageUrls});
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSalonImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Salon Images',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          if (_isUploading)
            const LinearProgressIndicator(
              minHeight: 4,
            ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(8.0),
              onReorder: _reorderImages,
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = _imageUrls[index];
                return Card(
                  key: ValueKey(imageUrl),
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.error));
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _deleteImage(imageUrl),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white),
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
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          if (_imageUrls.length < 5) {
            _uploadImages();
          } else {
            showCustomSnackBar(
                context, 'Limit Reached', 'Maximum of 5 images allowed',
                isError: true);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.upload, color: Colors.white),
        label: const Text(
          'Upload Images',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

void showCustomSnackBar(BuildContext context, String title, String message,
    {bool isError = false}) {
  Color backgroundColor = isError ? Colors.red : Colors.deepPurple;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
