import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/editservice_page.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';

class AddServicesPage extends StatefulWidget {
  const AddServicesPage({
    super.key,
    this.salonModel,
  });
  final Salon? salonModel;

  @override
  State<AddServicesPage> createState() => _AddServicesPageState();
}

class _AddServicesPageState extends State<AddServicesPage> {
  Stream<List<ServiceModel>> _fetchSalonServicesStream() {
    return FirebaseFirestore.instance
        .collection("Salons")
        .where('ownerUid', isEqualTo: widget.salonModel?.ownerUid)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final services = querySnapshot.docs.first.data()["services"] ?? [];

        return List<ServiceModel>.from(
          (services as List).map((service) => ServiceModel.fromMap(service)),
        );
      }
      return [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Services'),
      ),
      body: StreamBuilder<List<ServiceModel>>(
        stream: _fetchSalonServicesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return const Center(child: Text('No services available.'));
          }

          // Group services by category
          final Map<String, List<ServiceModel>> categorizedServices = {};
          for (var service in services) {
            categorizedServices
                .putIfAbsent(service.category, () => [])
                .add(service);
          }

          return ListView(
            children: categorizedServices.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 5,
                child: ExpansionTile(
                  title: Text(entry.key,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text("${entry.value.length} services"),
                  children: entry.value.map((service) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "USD ${service.price}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    service.description,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return EditServicePage(
                                      index: services.indexOf(service),
                                      salonModel: widget.salonModel!,
                                      serviceModel: service,
                                    );
                                  },
                                ));
                              },
                              icon: const Icon(Icons.edit),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
