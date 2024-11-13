import 'package:flutter/material.dart';
import '../services/services.dart';
import '../login/login.dart';
import 'logic.dart';
import '../theme/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profile/profile_page.dart';
import '../withdraw/withdraw_screen.dart';
import 'homedrawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _imageCount = 0;
  double _totalEarnings = 0.0;
  bool _isLoading = false;
  String? _errorMessage;
  late HomeLogic _logic;
  final supabase = Supabase.instance.client;
  String? zomatoId;
  String? userName;
  double _withdrawableBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _logic = HomeLogic(
      context: context,
      setLoading: (value) => setState(() => _isLoading = value),
      setError: (value) => setState(() => _errorMessage = value),
      setImageCount: (value) => setState(() => _imageCount = value),
      setTotalEarnings: (value) => setState(() => _totalEarnings = value),
    );
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _logic.loadTodayStats(),
      _fetchZomatoId(),
      _fetchWithdrawableBalance(),
    ]);
  }

  Future<void> _fetchZomatoId() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('profiles')
          .select('zomato_id, name')
          .eq('id', userId)
          .single();
      
      debugPrint('Fetched response: $response');

      setState(() {
        zomatoId = response['zomato_id'] as String?;
        userName = response['name'] as String?;
      });
    } catch (e) {
      debugPrint('Error fetching zomato_id: $e');
    }
  }

  Future<void> _fetchWithdrawableBalance() async {
    try {
      _withdrawableBalance = await SupabaseService.getWithdrawableBalance();
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching withdrawable balance: $e');
    }
  }

  Future<void> fetchTodayStats() async {
    try {
      setState(() => _isLoading = true);
      final stats = await SupabaseService.getTodayStats();
      setState(() {
        _totalEarnings = stats['totalEarnings'];
        _imageCount = stats['imageCount'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading stats: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> uploadImage() async {
    // Call your upload function here
    await SupabaseService.takePictureAndUpload();
    // After upload, refresh today's stats
    await fetchTodayStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GNMEarning',
              style: TextStyle(
                color: textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (zomatoId != null)
              Text(
                'ID: $zomatoId',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: textLight),
            onPressed: _logic.loadTodayStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: textLight),
            onPressed: () async {
              await SupabaseService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logic.handleTakePicture,
        icon: const Icon(Icons.camera_alt, color: textLight),
        label: const Text(
          'Take Picture',
          style: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        ),
        elevation: 8.0,
        backgroundColor: primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : Container(
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Error: $_errorMessage',
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [secondaryColor, primaryColor],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.account_circle,
                                      size: 50,
                                      color: textLight,
                                    ),
                                    if (userName != null && userName!.isNotEmpty)
                                      Text(
                                        '$userName',
                                        style: const TextStyle(
                                          color: textLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else
                                      const Text(
                                        'No Name Available',
                                        style: TextStyle(
                                          color: textLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const WithdrawScreen(),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [secondaryColor, primaryColor],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Withdrawable Balance: ₹${_withdrawableBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: textLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [secondaryColor, primaryColor],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's Earnings",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textLight,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₹${_totalEarnings.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: textLight,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Images taken: $_imageCount',
                                          style: const TextStyle(
                                            color: textLight,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.currency_rupee,
                                      size: 40,
                                      color: textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      drawer: const HomeDrawer(),
    );
  }
} 