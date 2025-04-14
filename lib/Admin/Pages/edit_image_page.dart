import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/images_picker.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class EditImagePage extends StatefulWidget {
  final String imageUrl;
  final String docId;

  const EditImagePage({super.key, required this.imageUrl, required this.docId});

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage>
    with SingleTickerProviderStateMixin {
  TextEditingController _linkController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String? _selectedSalonId;
  List<QueryDocumentSnapshot> _allSalons = [];
  TabController? _tabController;
  Salon? _selectedSalon;

  @override
  void initState() {
    super.initState();
    _fetchSalons();
    _fetchCurrentData();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchSalons() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Salons').get();
    setState(() {
      _allSalons = snapshot.docs;
    });
  }

  Future<void> _fetchCurrentData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('banners')
            .doc(widget.docId)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _linkController.text = data['link'] ?? '';
        _selectedSalonId = data['salonId'];
      });
      // If there's a selected salonId, find the salon and update the selectedSalon
      if (_selectedSalonId != null) {
        final selectedSalonDoc =
            await FirebaseFirestore.instance
                .collection('Salons')
                .doc(_selectedSalonId)
                .get();
        if (selectedSalonDoc.exists) {
          setState(() {
            _selectedSalon = Salon.fromMap(
              selectedSalonDoc.data() as Map<String, dynamic>,
            );
          });
        }
      }
    }
  }

  List<QueryDocumentSnapshot> get _filteredSalons {
    String query = _searchController.text.toLowerCase();
    return _allSalons.where((doc) {
      final salon = Salon.fromMap(doc.data() as Map<String, dynamic>);
      return salon.name.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _saveImage() async {
    String result;

    if (_tabController!.index == 0) {
      // If the tab is 0, we are working with the link field
      if (_linkController.text.isEmpty) {
        showCustomSnackBar(
          context,
          'Error',
          'Please enter a link.',
          isError: true,
        );
        return;
      }

      // Update the link in Firestore
      result = _linkController.text;
      await FirebaseFirestore.instance
          .collection('banners')
          .doc(widget.docId)
          .update(
            {
              'link': _linkController.text,
              'salonId': FieldValue.delete(),
            }, // Delete salonId
          );
    } else {
      // If the tab is not 0, we are working with the salonId field
      if (_selectedSalonId == null) {
        showCustomSnackBar(
          context,
          'Error',
          'Please select a salon.',
          isError: true,
        );
        return;
      }

      // Update the salonId in Firestore
      result = _selectedSalonId!;
      await FirebaseFirestore.instance
          .collection('banners')
          .doc(widget.docId)
          .update(
            {
              'salonId': _selectedSalonId,
              'link': FieldValue.delete(),
            }, // Delete link
          );
    }

    // Optional: You can show a success message after saving
    showCustomSnackBar(
      context,
      'Success',
      'Changes saved successfully',
      isError: false,
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Banner Image')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveImage();
        },
        icon: const Icon(Icons.save),
        label: const Text('Save'),
      ),
      body: Column(
        children: [
          Image.network(widget.imageUrl, height: 200, fit: BoxFit.cover),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Link'), Tab(text: 'Salon')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                /// Link Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Image Link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                /// Salon Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Chosen Salon at the top
                      if (_selectedSalon != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            children: [
                              const Text(
                                'Chosen Salon',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Divider(), // Divider between header and content
                              Card(
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 15,
                                  ),
                                  title: Row(
                                    children: [
                                      _selectedSalon!.imageUrls.isNotEmpty
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.network(
                                              _selectedSalon!.imageUrls[0],
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : Icon(
                                            Icons.account_circle,
                                            size: 60,
                                          ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          _selectedSalon!.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Search Bar for Salons
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search Salons',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),

                      // Salon List
                      Expanded(
                        child:
                            _filteredSalons.isEmpty
                                ? const Center(child: Text('No salons found'))
                                : ListView.builder(
                                  itemCount: _filteredSalons.length,
                                  itemBuilder: (context, index) {
                                    final doc = _filteredSalons[index];
                                    final salon = Salon.fromMap(
                                      doc.data() as Map<String, dynamic>,
                                    );
                                    return Card(
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 15,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedSalonId = doc.id;
                                            _selectedSalon = salon;
                                          });
                                        },
                                        title: Row(
                                          children: [
                                            salon.imageUrls.isNotEmpty &&
                                                    salon.imageUrls[0] != null
                                                ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.network(
                                                    salon.imageUrls[0],
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                                : Icon(
                                                  Icons.account_circle,
                                                  size: 60,
                                                ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: Text(
                                                salon.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Radio<String>(
                                          value: doc.id,
                                          groupValue: _selectedSalonId,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedSalonId = value;
                                              _selectedSalon = salon;
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
