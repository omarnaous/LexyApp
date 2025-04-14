import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:lexyapp/Business%20Store/constants.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/map_salons.dart';
import 'package:lexyapp/Features/Search%20Salons/Pages/new_search.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/salon_card.dart';

class SearchSalonsPage extends StatefulWidget {
  const SearchSalonsPage({super.key});

  @override
  State<SearchSalonsPage> createState() => _SearchSalonsPageState();
}

class _SearchSalonsPageState extends State<SearchSalonsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String _searchText = '';

  List<String> getAllKeys(Map<String, dynamic> data) {
    return data.keys.toList();
  }

  void _performSearch(String queryText) {
    setState(() {
      _searchText = queryText.trim();
    });
  }

  void _showCategoryPicker() async {
    List<String> fetchedCategories = [];

    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('SalonCategories').get();

      fetchedCategories =
          querySnapshot.docs
              .map((doc) => doc['categoryName'] as String)
              .toList();
    } catch (e) {
      print('Error fetching categories: $e');
    }

    final allCategories = getAllKeys(services) + fetchedCategories;

    showMaterialScrollPicker<String>(
      context: context,
      title: "Select Category",
      items: allCategories,
      selectedItem: _selectedCategory ?? allCategories.first,
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

  Stream<QuerySnapshot> _getSalons() {
    Query query = FirebaseFirestore.instance
        .collection('Salons')
        .where('active', isEqualTo: true);

    if (_searchText.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: _searchText)
          .where('name', isLessThanOrEqualTo: '$_searchText\uf8ff');
    }

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      query = query.where('categories', arrayContains: _selectedCategory);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: const Text("Search Salons"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
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
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1,
                    child: TextFormField(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return QuickSearchSalonsPage();
                            },
                          ),
                        );
                      },
                      onFieldSubmitted:
                          (_) => context.read<NavBarCubit>().showNavBar(),
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
                        _performSearch(value);
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
                            child: const Text(
                              'Select Category',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                                _performSearch("");
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SalonMapPage(),
                                ),
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getSalons(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No salons found",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      var doc =
                          snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                      Salon salon = Salon.fromMap(doc);
                      return SalonCard(salon: salon, salonId: document.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
