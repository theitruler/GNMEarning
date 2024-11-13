import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;
  String? email;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchUserEmail();
  }

  Future<void> _fetchProfileData() async {
    final data = await SupabaseService.fetchUserProfile();
    if (data != null) {
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load profile data';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserEmail() async {
    email = await SupabaseService.getUserEmail();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Container(
                  color: Colors.grey[200], // Background color
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: TextEditingController(text: 'Name: ${profileData!['name'] ?? 'N/A'}'),
                        readOnly: true, // Non-editable field
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: TextEditingController(text: 'Zomato ID: ${profileData!['zomato_id'] ?? 'N/A'}'),
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Zomato ID',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: TextEditingController(text: 'UPI ID: ${profileData!['upi_id'] ?? 'N/A'}'),
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'UPI ID',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: TextEditingController(text: 'Phone: ${profileData!['phone'] ?? 'N/A'}'),
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Phone',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: TextEditingController(text: 'Email: ${email ?? 'N/A'}'),
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                      ),
                      // Add more fields as necessary
                    ],
                  ),
                ),
    );
  }
} 