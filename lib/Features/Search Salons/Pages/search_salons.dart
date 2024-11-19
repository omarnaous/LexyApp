import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
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

  @override
  void initState() {
    super.initState();
    _baseQuery = FirebaseFirestore.instance.collection('Salons');
    _searchQuery = _baseQuery; // Initialize the search query
  }

  void _performSearch(String queryText) {
    setState(() {
      if (queryText.isNotEmpty) {
        _searchQuery = _baseQuery
            .where('name', isGreaterThanOrEqualTo: queryText.toLowerCase())
            .where('name',
                isLessThanOrEqualTo: '${queryText.toLowerCase()}\uf8ff');
      } else {
        _searchQuery = _baseQuery;
      }
    });
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
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
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
                    const SizedBox(height: 20),
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
                        onFieldSubmitted: (value) {
                          _performSearch(value.trim());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _searchQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  print("Error: ${snapshot.error}");
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
                  return const SliverToBoxAdapter(
                    child: Center(child: Text("No salons found")),
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

                        return SalonCard(
                          salon: salon,
                          salonId: salonId,
                        );
                      } catch (e) {
                        print("Error parsing salon data: $e");
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
