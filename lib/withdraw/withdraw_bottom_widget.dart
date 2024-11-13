import 'package:flutter/material.dart';
import '../services/services.dart'; // Import the SupabaseService

class WithdrawBottomWidget extends StatefulWidget {
  final double withdrawableBalance; // Pass the withdrawable balance
  const WithdrawBottomWidget({super.key, required this.withdrawableBalance});

  @override
  State<WithdrawBottomWidget> createState() => _WithdrawBottomWidgetState();
}

class _WithdrawBottomWidgetState extends State<WithdrawBottomWidget> {
  final TextEditingController _amountController = TextEditingController(); // Controller for the amount text field
  String? _errorMessage; // Variable to hold error message
  String? _upiId; // Variable to hold the UPI ID

  @override
  void initState() {
    super.initState();
    _fetchUpiId(); // Fetch the UPI ID when the widget is initialized
  }

  Future<void> _fetchUpiId() async {
    // Fetch the UPI ID from the profiles table
    _upiId = await SupabaseService.getUpiId(); // Assuming this method exists
    setState(() {}); // Update the state to reflect the fetched UPI ID
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Make the bottom sheet scrollable
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Withdraw Amount',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Enter amount',
                border: const OutlineInputBorder(),
                errorText: _errorMessage, // Show error message here
              ),
              keyboardType: TextInputType.number,
            ),
            if (_upiId != null) // Check if UPI ID is available
              Align(
                alignment: Alignment.centerLeft, // Align to the left
                child: Row(
                  children: [
                    const Text('Paying to: '), // Keep "Pay to:" in default color
                    Chip(
                      label: Text(
                        _upiId!, // Display only the UPI ID
                        style: const TextStyle(color: Colors.black), // Text color for UPI ID
                      ),
                      backgroundColor: Colors.yellow, // Yellow chip background
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement the withdraw request functionality here
                final amount = double.tryParse(_amountController.text);
                setState(() {
                  _errorMessage = null; // Reset error message
                });
                if (amount != null && amount > 0) {
                  if (amount > widget.withdrawableBalance) {
                    // Set error message if the amount exceeds the withdrawable balance
                    setState(() {
                      _errorMessage = 'Amount exceeds withdrawable balance';
                    });
                  } else {
                    // Call the withdraw method from SupabaseService
                    _withdrawAmount(amount);
                    Navigator.of(context).pop(); // Close the bottom sheet
                  }
                } else {
                  // Set error message if the amount is invalid
                  setState(() {
                    _errorMessage = 'Please enter a valid amount';
                  });
                }
              },
              child: const Text('Send Request'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _withdrawAmount(double amount) async {
    try {
      // Insert the withdrawal request into the withdraw table
      await SupabaseService.insertWithdrawRequest(amount: amount, success: false);
      debugPrint('Withdraw request for amount: ₹$amount has been submitted.');
    } catch (e) {
      debugPrint('Error submitting withdraw request: $e');
    }
  }
} 