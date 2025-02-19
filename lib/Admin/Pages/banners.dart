import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BannerImagesPage extends StatefulWidget {
  const BannerImagesPage({super.key});

  @override
  State<BannerImagesPage> createState() => _BannerImagesPageState();
}

class _BannerImagesPageState extends State<BannerImagesPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<String> _imageUrls = [];

  Future<void> _fetchBannerImages() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('banners').get();
    final List<String> imageUrls =
        querySnapshot.docs.map((doc) => doc['url'] as String).toList();

    setState(() {
      _imageUrls = imageUrls;
    });
  }

  Future<void> _uploadImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    if (_imageUrls.length + pickedFiles.length > 5) {
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
        final imageRef = storageRef
            .child('banners/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = await imageRef.putFile(file);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('banners')
            .add({'url': imageUrl});
      }

      showCustomSnackBar(context, 'Success', 'Images uploaded successfully');
      _fetchBannerImages();
    } catch (e) {
      showCustomSnackBar(context, 'Error', 'Failed to upload images: $e',
          isError: true);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('banners')
          .where('url', isEqualTo: imageUrl)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();

      setState(() {
        _imageUrls.remove(imageUrl);
      });

      showCustomSnackBar(context, 'Success', 'Image deleted successfully');
    } catch (e) {
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
  }

  @override
  void initState() {
    super.initState();
    _fetchBannerImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Images'),
      ),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _imageUrls.length,
              onReorder: _reorderImages,
              itemBuilder: (context, index) {
                final imageUrl = _imageUrls[index];
                return Card(
                  key: ValueKey(imageUrl),
                  margin: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Image.network(imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover),
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
        icon: const Icon(Icons.upload),
        label: const Text('Upload Images'),
      ),
    );
  }
}

void showCustomSnackBar(BuildContext context, String title, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(message,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
