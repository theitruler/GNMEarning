import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../earning/earning_detail.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: Container(),
          ),
          ListTile(
            leading: Icon(Icons.home, color: textLight),
            title: Text(
              '💰 Earnings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18, // Increase font size for better visibility
                fontWeight: FontWeight.w600, // Make the text bolder
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EarningDetailScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
} 