import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/map_salons.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/salon_card.dart';

class SearchSalonsPage extends StatefulWidget {
  const SearchSalonsPage({super.key});

  @override
  State<SearchSalonsPage> createState() => _SearchSalonsPageState();
}

class _SearchSalonsPageState extends State<SearchSalonsPage> {
  final TextEditingController _searchController = TextEditingController();
  late Query _baseQuery;
  late Query _searchQuery;
  String? _selectedCategory; // Track selected category

  final List<String> _categories = [
    'Hair Salon',
    'Nail Salon',
    'Beauty Salon',
    'Spa',
  ];

  @override
  void initState() {
    super.initState();
    _baseQuery = FirebaseFirestore.instance
        .collection('Salons')
        .where('active', isEqualTo: true);
    _searchQuery = _baseQuery; // Initialize the search query
  }

  // Perform search based on queryText and category
  void _performSearch(String queryText) {
    setState(() {
      Query query = _baseQuery;

      // Apply text query if not empty
      if (queryText.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: queryText)
            .where('name', isLessThanOrEqualTo: '$queryText\uf8ff');
      }

      // Apply category filter if selected
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        query = query.where('categories', arrayContains: _selectedCategory);
      }

      _searchQuery = query;
    });
  }

  // Show Material Picker Dialog for categories
  void _showCategoryPicker() {
    showMaterialScrollPicker<String>(
      context: context,
      title: "Select Category",
      items: _categories,
      selectedItem: _selectedCategory ?? _categories.first,
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
          _performSearch(_searchController.text);
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Search Salons"),
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(10.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Discover Your Ideal Salon",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Search Input Field
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Salons...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          // Capitalize the first letter of the input
                          if (value.isNotEmpty) {
                            String capitalizedValue =
                                value[0].toUpperCase() + value.substring(1);
                            _searchController.value = TextEditingValue(
                              text: capitalizedValue,
                              selection: TextSelection.fromPosition(
                                TextPosition(offset: capitalizedValue.length),
                              ),
                            );
                          }

                          _performSearch(value.trim());
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: ElevatedButton(
                              onPressed: _showCategoryPicker,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: Text(
                                _selectedCategory ?? 'Select Category',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedCategory = null;
                                  _performSearch(""); // Reset search
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SalonMapPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: const Text(
                                'Locations',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            // StreamBuilder for displaying results
            StreamBuilder<QuerySnapshot>(
              stream: _searchQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: Text("No salons found")),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      try {
                        Map<String, dynamic> salonData =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        Salon salon = Salon.fromMap(salonData);
                        String salonId = snapshot.data!.docs[index].id;

                        print(salon);

                        return SalonCard(
                          salon: salon,
                          salonId: salonId,
                        );
                      } catch (e) {
                        print(e);
                        return const ListTile(
                          title: Text("Error loading salon data"),
                        );
                      }
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
