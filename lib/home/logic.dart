import 'package:flutter/material.dart';
import '../services/services.dart';

class HomeLogic {
  final BuildContext context;
  final Function(bool) setLoading;
  final Function(String?) setError;
  final Function(int) setImageCount;
  final Function(double) setTotalEarnings;

  HomeLogic({
    required this.context,
    required this.setLoading,
    required this.setError,
    required this.setImageCount,
    required this.setTotalEarnings,
  });

  Future<void> loadTodayStats() async {
    try {
      setLoading(true);
      setError(null);
      
      final stats = await SupabaseService.getTodayStats();
      
      setImageCount(stats['imageCount']);
      setTotalEarnings(stats['totalEarnings']);
      
      setLoading(false);
    } catch (e) {
      setError('Failed to load stats: ${e.toString()}');
      setLoading(false);
    }
  }

  Future<void> handleTakePicture() async {
    try {
      setLoading(true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Taking picture...')),
        );
      }

      final String? fileUrl = await SupabaseService.takePictureAndUpload();
      
      if (fileUrl == null) {
        setLoading(false);
        return;
      }

      await loadTodayStats();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload complete!')),
        );
      }
    } catch (e) {
      setLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
} 