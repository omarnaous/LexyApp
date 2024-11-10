import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';
import 'package:lexyapp/Features/Search%20Salons/Data/salon_model.dart';
import 'package:lexyapp/custom_image.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _auth.currentUser != null
              ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(_auth.currentUser!.uid)
                  .snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("User data not found."));
            }

            final userDoc = snapshot.data!;
            UserModel userModel =
                UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
            return _HomePageContent(userModel: userModel);
          },
        ),
      ),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  final UserModel userModel;

  const _HomePageContent({required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: "Hey, ${userModel.firstName}",
              fontSize: 30,
            ),
          ),
          _buildSection(
            title: "Your Favourites",
            icon: Icons.favorite,
            items: userModel.favourites ?? [],
            buildItem: (context, salonId) => _SalonStream(salonId: salonId),
            emptyMessage: "No favourites added yet.",
          ),
          _buildSection(
            title: "Your Appointments",
            icon: Icons.calendar_today,
            items: userModel.appointments ?? [],
            buildItem: (context, appointment) {
              String salonId = appointment['salonId'];
              return _SalonStream(
                salonId: salonId,
                appointmentDate: appointment['date'],
              );
            },
            emptyMessage: "No appointments scheduled yet.",
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List items,
    required Widget Function(BuildContext, dynamic) buildItem,
    required String emptyMessage,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          const SizedBox(height: 10),
          _SectionHeader(title: title, icon: icon),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Center(
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    buildItem(context, items[index]),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  final IconData? icon;

  const _SectionHeader({
    required this.title,
    this.fontSize = 22,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          ),
          const SizedBox(width: 8),
          if (icon != null) Icon(icon, color: Colors.red, size: fontSize),
        ],
      ),
    );
  }
}

class _SalonStream extends StatelessWidget {
  final String salonId;
  final String? appointmentDate;

  const _SalonStream({required this.salonId, this.appointmentDate});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Salons')
          .doc(salonId)
          .snapshots(),
      builder: (context, salonSnapshot) {
        if (salonSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!salonSnapshot.hasData || !salonSnapshot.data!.exists) {
          return const SizedBox(
              width: 150, child: Center(child: Text("Salon not found.")));
        }

        final salonData = salonSnapshot.data!.data() as Map<String, dynamic>;
        Salon salonModel = Salon.fromMap(salonData);

        return _SalonCard(
            salonModel: salonModel, appointmentDate: appointmentDate);
      },
    );
  }
}

class _SalonCard extends StatelessWidget {
  final Salon salonModel;
  final String? appointmentDate;

  const _SalonCard({required this.salonModel, this.appointmentDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                elevation: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomImage(imageUrl: salonModel.imageUrls[0]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salonModel.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    salonModel.city,
                    style: const TextStyle(
                        color: Colors.black45, fontWeight: FontWeight.bold),
                  ),
                  if (appointmentDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Date: $appointmentDate',
                      style: const TextStyle(
                          color: Colors.black45, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
