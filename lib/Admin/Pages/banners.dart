import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lexyapp/Admin/Pages/edit_image_page.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/images_picker.dart';
import 'package:lexyapp/Features/Home%20Features/Widgets/image_carousel.dart';

class BannerImagesPage extends StatefulWidget {
  const BannerImagesPage({super.key});

  @override
  State<BannerImagesPage> createState() => _BannerImagesPageState();
}

class _BannerImagesPageState extends State<BannerImagesPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<String> _imageUrls = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBannerImages();
  }

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
      showCustomSnackBar(
        context,
        'Limit Exceeded',
        'You can only upload a maximum of 5 images',
        isError: true,
      );
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
          'banners/${DateTime.now().millisecondsSinceEpoch}',
        );
        final uploadTask = await imageRef.putFile(file);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('banners').add({
          'url': imageUrl,
        });
      }

      showCustomSnackBar(context, 'Success', 'Images uploaded successfully');
      _fetchBannerImages();
    } catch (e) {
      showCustomSnackBar(
        context,
        'Error',
        'Failed to upload images: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
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
      showCustomSnackBar(
        context,
        'Error',
        'Failed to delete image: $e',
        isError: true,
      );
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Images'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Manage'), Tab(text: 'Preview')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Manage Tab
          Column(
            children: [
              if (_isUploading) const LinearProgressIndicator(),
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future:
                      FirebaseFirestore.instance.collection('banners').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading banners'));
                    }

                    final docs = snapshot.data!.docs;

                    return ReorderableListView.builder(
                      itemCount: docs.length,
                      onReorder: _reorderImages,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final imageUrl = doc['url'] as String;
                        final docId = doc.id; // Get the document ID

                        return ListTile(
                          key: ValueKey(imageUrl),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: const Text('Banner Image'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Navigate to the edit page and pass docId and imageUrl
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditImagePage(
                                            docId: docId, // Pass docId here
                                            imageUrl: imageUrl,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Delete the image
                                  _deleteImage(imageUrl);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_imageUrls.length < 5) {
                    _uploadImages();
                  } else {
                    showCustomSnackBar(
                      context,
                      'Limit Reached',
                      'Maximum of 5 images allowed',
                      isError: true,
                    );
                  }
                },
                icon: const Icon(Icons.upload),
                label: const Text('Upload Images'),
              ),
            ],
          ),

          // Preview Tab
          SlidingImagesSection(),
        ],
      ),
    );
  }
}
