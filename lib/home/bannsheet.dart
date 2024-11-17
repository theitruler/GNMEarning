import 'package:flutter/material.dart';
import '../services/services.dart';

void showBannedBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.5,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your account has been banned. Please contact support for more information.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
} 