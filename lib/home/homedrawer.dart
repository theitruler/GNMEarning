import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/colors.dart';
import '../earning/earning_detail.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
          ),
          FutureBuilder<String>(
            future: _getAppVersion(),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Version ${snapshot.data ?? ''}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 