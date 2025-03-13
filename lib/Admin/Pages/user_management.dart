import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexyapp/Features/Authentication/Data/user_model.dart';

class UsersManagement extends StatefulWidget {
  const UsersManagement({super.key});

  @override
  State<UsersManagement> createState() => _UsersManagementState();
}

class _UsersManagementState extends State<UsersManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = "";

  Future<List<UserModel>> fetchUsers(bool isBusiness) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('isBusinessUser', isEqualTo: isBusiness ? true : null)
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((user) =>
              user.firstName
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              user.lastName
                      ?.toLowerCase()
                      .contains(searchQuery.toLowerCase()) ==
                  true ||
              user.email.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  Future<void> disableAndDeleteUser(String email) async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text(
              "Are you sure you want to disable and delete this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({'disabled': true});
          await doc.reference.delete();
        }
        debugPrint('User disabled and deleted from Firestore');
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error disabling and deleting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Users Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Business Users'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Search by name or email",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserList(false),
                  _buildUserList(true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(bool isBusiness) {
    return FutureBuilder<List<UserModel>>(
      future: fetchUsers(isBusiness),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        List<UserModel> users = snapshot.data!;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: user.imageUrl != null && user.imageUrl!.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.imageUrl!),
                    )
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text('${user.firstName} ${user.lastName ?? ''}'),
              subtitle: Text("${user.email}\n${user.password}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () async {
                  await disableAndDeleteUser(user.email);
                },
              ),
            );
          },
        );
      },
    );
  }
}
