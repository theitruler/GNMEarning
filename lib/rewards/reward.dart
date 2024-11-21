import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/services.dart' as services;

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  bool? isJoiningBonusClaimed;

  @override
  void initState() {
    super.initState();
    _checkJoiningBonus();
  }

  Future<void> _checkJoiningBonus() async {
    final claimed = await services.SupabaseService.getJoiningBonus();
    setState(() {
      isJoiningBonusClaimed = claimed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.1), backgroundColor],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isJoiningBonusClaimed != null) // Only show when status is loaded
                RewardTile(
                  title: 'Join Bonus',
                  description: 'Congratulations you got Joining bonus!',
                  status: isJoiningBonusClaimed == true ? 'Claimed' : 'Not Claimed',
                  statusColor: isJoiningBonusClaimed == true ? Colors.green : Colors.red,
                  amount: '₹100',
                  icon: Icons.celebration,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RewardTile extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final Color statusColor;
  final String amount;
  final IconData icon;

  const RewardTile({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 