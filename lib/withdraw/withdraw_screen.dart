import 'package:flutter/material.dart';
import 'withdraw_bottom_widget.dart'; // Import the new WithdrawBottomWidget
import '../services/services.dart'; // Import the SupabaseService

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  double _withdrawableBalance = 0.0; // Variable to hold withdrawable balance
  List<Map<String, dynamic>> _withdrawRecords = []; // List to hold withdrawal records
  DateTime? _lastWithdrawalDate; // Variable to hold the last withdrawal date

  @override
  void initState() {
    super.initState();
    _fetchWithdrawableBalance(); // Fetch the withdrawable balance on init
    _fetchWithdrawRecords(); // Fetch withdrawal records on init
    _fetchLastWithdrawalDate(); // Fetch the last withdrawal date on init
  }

  Future<void> _fetchWithdrawableBalance() async {
    try {
      _withdrawableBalance = await SupabaseService.getWithdrawableBalance();
      setState(() {}); // Update the UI
    } catch (e) {
      debugPrint('Error fetching withdrawable balance: $e');
    }
  }

  Future<void> _fetchWithdrawRecords() async {
    try {
      _withdrawRecords = await SupabaseService.getWithdrawData(); // Fetch records from the service
      setState(() {}); // Update the UI
    } catch (e) {
      debugPrint('Error fetching withdraw records: $e');
    }
  }

  Future<void> _fetchLastWithdrawalDate() async {
    _lastWithdrawalDate = await SupabaseService.getLastWithdrawalDate(); // Fetch last withdrawal date
  }

  void _showWithdrawBottomSheet() async {
    // Check if a week has passed since the last withdrawal
    if (_lastWithdrawalDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastWithdrawalDate!);
      if (difference.inDays < 7) {
        // If less than 7 days, show a message and return
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only withdraw once a week.')),
        );
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the bottom sheet to be scrollable
      builder: (context) {
        return WithdrawBottomWidget(withdrawableBalance: _withdrawableBalance); // Use the new widget
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the withdrawable balance at the top
            Text(
              'Withdrawable Balance: ₹${_withdrawableBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Add some space below the balance text

            // Display the withdrawal records
            const Text(
              'Withdrawal History:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _withdrawRecords.isEmpty // Check if the list is empty
                  ? const Center(
                      child: Text(
                        'No withdraw requests yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _withdrawRecords.length,
                      itemBuilder: (context, index) {
                        final record = _withdrawRecords[index];
                        return Card( // Use Card for better visual separation
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              'Amount: ₹${record['amount']}',
                              style: const TextStyle(fontWeight: FontWeight.bold), // Make text bold
                            ),
                            trailing: Chip(
                              label: Text(
                                record['success'] ? 'Complete' : 'Pending',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: record['success'] ? Colors.green : Colors.red, // Green for complete, red for pending
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Add vertical and horizontal padding
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _showWithdrawBottomSheet, // Show the bottom sheet when pressed
            child: const Text('Withdraw Amount'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60), // Increased button height
            ),
          ),
        ),
      ),
    );
  }
} 