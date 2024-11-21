import 'package:flutter/material.dart';
import '../services/services.dart';

class WithdrawBottomWidget extends StatefulWidget {
  final double withdrawableBalance;
  const WithdrawBottomWidget({super.key, required this.withdrawableBalance});

  @override
  State<WithdrawBottomWidget> createState() => _WithdrawBottomWidgetState();
}

class _WithdrawBottomWidgetState extends State<WithdrawBottomWidget> {
  String? _upiId;

  @override
  void initState() {
    super.initState();
    _fetchUpiId();
  }

  Future<void> _fetchUpiId() async {
    _upiId = await SupabaseService.getUpiId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '₹${widget.withdrawableBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (_upiId != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Text('Paying to: '),
                    Chip(
                      label: Text(
                        _upiId!,
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.yellow,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _withdrawAmount(widget.withdrawableBalance);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _withdrawAmount(double amount) async {
    try {
      await SupabaseService.insertWithdrawRequest(amount: amount, success: false);
      await SupabaseService.updateJoiningBonus();
    } catch (e) {
      // Handle error silently
    }
  }
} 