import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/services.dart';
import 'package:intl/intl.dart';

class EarningDetailScreen extends StatefulWidget {
  @override
  _EarningDetailScreenState createState() => _EarningDetailScreenState();
}

class _EarningDetailScreenState extends State<EarningDetailScreen> {
  DateTime selectedDate = DateTime.now(); // Default to current date
  DateTime? userCreatedAt;
  bool isAccountCreated = false;

  @override
  void initState() {
    super.initState();
    _checkAccountStatus();
  }

  Future<void> _checkAccountStatus() async {
    final profile = await SupabaseService.fetchUserProfile();
    setState(() {
      isAccountCreated = profile != null;
    });
    userCreatedAt = await SupabaseService.getUserCreatedAt();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!isAccountCreated) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: userCreatedAt ?? DateTime.now(),
      lastDate: DateTime.now(), // Can't select future dates
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earnings Detail'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(selectedDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: isAccountCreated ? () => _selectDate(context) : null,
                  child: Text('Select Date'),
                ),
              ],
            ),
          ),
          if (!isAccountCreated)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Please create an account to select a date.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Stream.fromFuture(SupabaseService.fetchUserImageDetails()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final imageDetails = snapshot.data ?? [];
                
                final filteredImages = imageDetails.where((image) {
                  final createdAt = DateTime.parse(image['created_at']);
                  return createdAt.year == selectedDate.year &&
                         createdAt.month == selectedDate.month &&
                         createdAt.day == selectedDate.day;
                }).toList();

                if (filteredImages.isEmpty) {
                  return const Center(
                    child: Text('No Earnings'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredImages.length,
                  itemBuilder: (context, index) {
                    final image = filteredImages[index];
                    final createdAt = DateTime.parse(image['created_at']);
                    final formattedTime = DateFormat('hh:mm a').format(createdAt);
                    final status = image['status'] ?? 'N/A';
                    final price = image['price']?.toString() ?? '0';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text('₹$price'),
                        subtitle: Text('Time: $formattedTime'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'pending' 
                                ? Colors.orange 
                                : status == 'approved'
                                    ? Colors.green
                                    : status == 'rejected'
                                        ? Colors.red
                                        : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 