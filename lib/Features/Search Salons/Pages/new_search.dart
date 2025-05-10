import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Widget/salon_card.dart';

class QuickSearchSalonsPage extends StatefulWidget {
  const QuickSearchSalonsPage({super.key});

  @override
  State<QuickSearchSalonsPage> createState() => _QuickSearchSalonsPageState();
}

class _QuickSearchSalonsPageState extends State<QuickSearchSalonsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  void _performSearch(String query) {
    setState(() {
      _searchText = query.trim();
    });
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

    // Remove any ordering by rank here; sort manually in Dart.
    return query.snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    String capitalized =
                        value[0].toUpperCase() + value.substring(1);
                    _searchController.value = TextEditingValue(
                      text: capitalized,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: capitalized.length),
                      ),
                    );
                  }
                  _performSearch(value);
                },
                decoration: InputDecoration(
                  labelText: 'Search Salons...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
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

                  // Sort salons by rank (nulls last) before displaying
                  List<QueryDocumentSnapshot> sortedDocs = List.from(
                    snapshot.data!.docs,
                  );
                  sortedDocs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>?;
                    final bData = b.data() as Map<String, dynamic>?;

                    final aRank =
                        aData != null && aData.containsKey('rank')
                            ? aData['rank']
                            : null;
                    final bRank =
                        bData != null && bData.containsKey('rank')
                            ? bData['rank']
                            : null;

                    if (aRank == null && bRank == null) return 0;
                    if (aRank == null) return 1;
                    if (bRank == null) return -1;
                    return (aRank as num).compareTo(bRank as num);
                  });

                  return ListView.builder(
                    itemCount: sortedDocs.length,
                    itemBuilder: (context, index) {
                      var document = sortedDocs[index];
                      var data = document.data() as Map<String, dynamic>;
                      Salon salon = Salon.fromMap(data);
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
