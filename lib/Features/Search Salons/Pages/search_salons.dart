import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:lexyapp/Business%20Store/constants.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
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
  String? _selectedCategory;

  List<String> getAllKeys(Map<String, dynamic> data) {
    return data.keys.toList();
  }

  @override
  void initState() {
    super.initState();
    _baseQuery = FirebaseFirestore.instance
        .collection('Salons')
        .where('active', isEqualTo: true);
    _searchQuery = _baseQuery;
  }

  void _performSearch(String queryText) {
    setState(() {
      Query query = _baseQuery;
      if (queryText.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: queryText)
            .where('name', isLessThanOrEqualTo: '$queryText\uf8ff');
      }
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        query = query.where('categories', arrayContains: _selectedCategory);
      }
      _searchQuery = query;
    });
  }

  void _showCategoryPicker() {
    showMaterialScrollPicker<String>(
      context: context,
      title: "Select Category",
      items: getAllKeys(services),
      selectedItem: _selectedCategory ?? getAllKeys(services).first,
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
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          context.read<NavBarCubit>().showNavBar();
                        },
                        onTap: () {
                          context.read<NavBarCubit>().hideNavBar();
                        },
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
                              child: const Text(
                                'Select Category',
                                style: TextStyle(
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
                                  _performSearch("");
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
            SliverToBoxAdapter(
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No salons found",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
