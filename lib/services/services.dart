import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class SupabaseService {
  static final supabase = Supabase.instance.client;
  static final ImagePicker _picker = ImagePicker();

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<String?> takePictureAndUpload() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) return null;

      final File photoFile = File(photo.path);
      final Position position = await _getCurrentLocation();
      
      return await uploadFile(
        photoFile, 
        'userImages',
        position,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> uploadFile(
    File file, 
    String bucket,
    Position position,
  ) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final filePath = '${user.id}/$fileName';

      await supabase
          .storage
          .from(bucket)
          .upload(filePath, file);
      
      final String fileUrl = supabase
          .storage
          .from(bucket)
          .getPublicUrl(filePath);

      await supabase.from('images').insert({
        'user_id': user.id,
        'image_url': fileUrl,
        'price': 18,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });
          
      return fileUrl;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getTodayStats() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      // Get timestamps for today from 12 AM to 12 AM of the next day
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day); // 12 AM today
      final endOfDay = startOfDay.add(const Duration(days: 1)); // 12 AM tomorrow
      
      final response = await supabase
          .from('images')
          .select('id, price')
          .eq('user_id', user.id)
          .gte('created_at', startOfDay.toIso8601String()) // Use startOfDay
          .lt('created_at', endOfDay.toIso8601String()); // Use endOfDay
      
      final List<dynamic> data = response;
      
      int imageCount = data.length;
      double totalEarnings = 0.0;

      for (var item in data) {
        final price = item['price'];
        if (price != null) {
          if (price is num) {
            totalEarnings += price.toDouble();
          } else if (price is String) {
            totalEarnings += double.tryParse(price) ?? 0.0;
          }
        }
      }

      return {
        'imageCount': imageCount,
        'totalEarnings': totalEarnings,
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from('profiles')
          .select('name, zomato_id, upi_id, phone, bann') // Revert to original fields
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<void> withdraw() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Fetching all prices from the images table
      final responseImages = await supabase
          .from('images')
          .select('price')
          .eq('user_id', user.id);

      final List<dynamic> dataImages = responseImages;

      // Extracting all prices and calculating total
      List<double> prices = [];
      double totalImagePrices = 0.0; // Variable to hold total image prices
      for (var item in dataImages) {
        final price = item['price'];
        if (price != null) {
          if (price is int) {
            totalImagePrices += price.toDouble();
            prices.add(price.toDouble());
          } else if (price is double) {
            totalImagePrices += price;
            prices.add(price);
          } else if (price is String) {
            final parsedPrice = double.tryParse(price) ?? 0.0;
            totalImagePrices += parsedPrice;
            prices.add(parsedPrice);
          }
        }
      }

      // Fetching all amounts from the withdraw table where success is true
      final responseWithdraw = await supabase
          .from('withdraw')
          .select('amount')
          .eq('user_id', user.id)
          .eq('success', true);

      final List<dynamic> dataWithdraw = responseWithdraw;

      // Extracting all amounts and calculating total
      List<double> amounts = [];
      double totalWithdrawAmounts = 0.0; // Variable to hold total withdraw amounts
      for (var item in dataWithdraw) {
        final amount = item['amount'];
        if (amount != null) {
          if (amount is int) {
            totalWithdrawAmounts += amount.toDouble();
            amounts.add(amount.toDouble());
          } else if (amount is double) {
            totalWithdrawAmounts += amount;
            amounts.add(amount);
          } else if (amount is String) {
            final parsedAmount = double.tryParse(amount) ?? 0.0;
            totalWithdrawAmounts += parsedAmount;
            amounts.add(parsedAmount);
          }
        }
      }

      // Calculate withdrawable balance
      double withdrawableBalance = totalImagePrices - totalWithdrawAmounts;

    } catch (e) {
      rethrow;
    }
  }

  static Future<double> getWithdrawableBalance() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Fetching all prices from the images table
      final responseImages = await Supabase.instance.client
          .from('images')
          .select('price')
          .eq('user_id', user.id)
          .eq('status', 'approved');

      final List<dynamic> dataImages = responseImages;

      // Calculate total image prices
      double totalImagePrices = 0.0;
      for (var item in dataImages) {
        final price = item['price'];
        if (price != null) {
          if (price is int) {
            totalImagePrices += price.toDouble();
          } else if (price is double) {
            totalImagePrices += price;
          } else if (price is String) {
            totalImagePrices += double.tryParse(price) ?? 0.0;
          }
        }
      }

      // Fetching all amounts from the withdraw table where success is true
      final responseWithdraw = await Supabase.instance.client
          .from('withdraw')
          .select('amount')
          .eq('user_id', user.id)
          .eq('success', true);

      final List<dynamic> dataWithdraw = responseWithdraw;

      // Calculate total withdraw amounts
      double totalWithdrawAmounts = 0.0;
      for (var item in dataWithdraw) {
        final amount = item['amount'];
        if (amount != null) {
          if (amount is int) {
            totalWithdrawAmounts += amount.toDouble();
          } else if (amount is double) {
            totalWithdrawAmounts += amount;
          } else if (amount is String) {
            totalWithdrawAmounts += double.tryParse(amount) ?? 0.0;
          }
        }
      }

      // Calculate withdrawable balance
      double withdrawableBalance = totalImagePrices - totalWithdrawAmounts;

      return withdrawableBalance; // Return the calculated balance
    } catch (e) {
      return 0.0; // Return 0.0 in case of an error
    }
  }

  static Future<void> insertWithdrawRequest({required double amount, required bool success}) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await Supabase.instance.client.from('withdraw').insert({
        'user_id': user.id,
        'amount': amount,
        'success': success,
      });
    } catch (e) {
      throw e; // Rethrow the error for handling in the calling method
    }
  }

  static Future<List<Map<String, dynamic>>> getWithdrawData() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Fetching withdraw records
    final List<dynamic> response = await Supabase.instance.client
        .from('withdraw')
        .select('amount, success')
        .eq('user_id', user.id);

    // Convert and return the response directly
    return response.map((item) => Map<String, dynamic>.from(item)).toList();
  } catch (e) {
    throw e;
  }
}

  static Future<String?> getUpiId() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await Supabase.instance.client
        .from('profiles')
        .select('upi_id')
        .eq('id', user.id)  // Filter by user ID
        .single();
    
    // The response is directly a Map<String, dynamic>
    return response['upi_id'] as String?;
  } catch (e) {
    return null;
  }
}

  static Future<String?> getUserEmail() async {
    final user = Supabase.instance.client.auth.currentUser; // Get the current user
    return user?.email; // Return the email if the user is authenticated
  }

  static Future<DateTime?> getLastWithdrawalDate() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from('withdraw')
          .select('created_at') // Assuming 'created_at' is the field for withdrawal date
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      return DateTime.parse(response['created_at']); // Return the last withdrawal date
    } catch (e) {
      return null; // Return null in case of an error
    }
  }

  static Future<DateTime?> getUserCreatedAt() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase
          .from('profiles') // Adjust the table name if necessary
          .select('updated_at') // Fetch the created_at field
          .eq('id', user.id)
          .single();

      return DateTime.parse(response['updated_at']); // Return the created_at date
    } catch (e) {
      return null; // Return null in case of an error
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUserImageDetails() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return []; // Return empty list if no user is authenticated
    }

    try {
      final response = await supabase
          .from('images')
          .select('price, created_at, status, reason')
          .eq('user_id', user.id)
          .order('created_at', ascending: true); // Order by creation date

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}

// Extension to get start of day
extension DateTimeExtension on DateTime {
  DateTime get startOfDay => DateTime.utc(year, month, day, 0, 0, 0, 0, 0);
} 