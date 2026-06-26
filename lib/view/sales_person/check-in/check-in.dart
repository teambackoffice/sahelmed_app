import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sahelmed_app/providers/employee_check_in_provider.dart';
import 'package:app_settings/app_settings.dart';

class EmployeeCheckIn extends StatefulWidget {
  const EmployeeCheckIn({super.key});

  @override
  State<EmployeeCheckIn> createState() => _EmployeeCheckInState();
}

class _EmployeeCheckInState extends State<EmployeeCheckIn> {
  // 1. Initialize the Controller
  final EmployeeCheckinController _controller = EmployeeCheckinController();
  FlutterSecureStorage storage = FlutterSecureStorage();
  String? sessionId;
  String? employeeId;
  String? fullName;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _loadFullName();
  }

  Future<void> _loadFullName() async {
    try {
      final savedFullName = await storage.read(key: 'full_name');
      if (mounted) {
        setState(() {
          fullName = savedFullName;
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to load full name', isError: true);
      }
    }
  }

  Future<void> _loadSessionData() async {
    try {
      final sid = await storage.read(key: 'session_id');
      final empId = await storage.read(key: 'employee_name');

      // Load persisted check-in state
      final savedIsCheckedIn = await storage.read(key: 'is_checked_in');
      final savedCheckInTime = await storage.read(key: 'check_in_time');
      final savedCheckOutTime = await storage.read(key: 'check_out_time');
      final savedDate = await storage.read(key: 'check_in_date');

      // Check if the saved date is today
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final bool isSameDay = savedDate == today;

      if (mounted) {
        setState(() {
          sessionId = sid;
          employeeId = empId;

          // Restore check-in state only if it's from today
          if (isSameDay) {
            isCheckedIn = savedIsCheckedIn == 'true';
            checkInTime = savedCheckInTime;
            checkOutTime = savedCheckOutTime;
          } else {
            // Reset state for new day
            isCheckedIn = false;
            checkInTime = null;
            checkOutTime = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to load session data', isError: true);
      }
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw _LocationException('location_off');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw _LocationException('permission_denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw _LocationException('permission_permanent');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // ── Location error dialogs ──────────────────────────────────────────────

  void _showLocationOffDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon badge
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  color: Color(0xFFFF8C42),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Location is Turned Off',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your device location (GPS) is currently off.\nPlease turn it on to check in or check out.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Open Settings button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppSettings.openAppSettings(type: AppSettingsType.location);
                  },
                  icon: const Icon(Icons.settings_rounded, size: 18),
                  label: const Text(
                    'Open Location Settings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationPermissionDialog({required bool isPermanent}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_disabled_rounded,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isPermanent
                    ? 'Location Permission Blocked'
                    : 'Location Permission Denied',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isPermanent
                    ? 'Location access has been permanently denied. Please go to App Settings and enable it to use check-in.'
                    : 'Location permission is required to check in or out.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              if (isPermanent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      AppSettings.openAppSettings(
                        type: AppSettingsType.location,
                      );
                    },
                    icon: const Icon(Icons.settings_rounded, size: 18),
                    label: const Text(
                      'Open App Settings',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isCheckedIn = false;
  String? checkInTime;
  String? checkOutTime;

  // Loading overlay state
  bool _isProcessing = false;
  String _loadingMessage = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper to show SnackBar
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleCheckIn() async {
    // Check if session data is loaded
    if (sessionId == null || employeeId == null) {
      _showMessage("Session data not loaded. Please try again.", isError: true);
      return;
    }

    _showConfirmationDialog(
      title: "Confirm Check-In",
      content: "Are you ready to start your work day?",
      confirmText: "Check In",
      isCheckIn: true,
      onConfirm: () async {
        // Step 1: Show GPS loading
        setState(() {
          _isProcessing = true;
          _loadingMessage = 'Getting your location...';
        });

        Position position;
        try {
          position = await _getCurrentLocation();
        } on _LocationException catch (e) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          if (e.code == 'location_off') {
            _showLocationOffDialog();
          } else if (e.code == 'permission_permanent') {
            _showLocationPermissionDialog(isPermanent: true);
          } else {
            _showLocationPermissionDialog(isPermanent: false);
          }
          return;
        } catch (e) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          _showMessage(
            'Could not get location. Please try again.',
            isError: true,
          );
          return;
        }

        // Step 2: Show API loading
        if (mounted) {
          setState(() => _loadingMessage = 'Submitting check-in...');
        }

        final String currentLat = position.latitude.toString();
        final String currentLong = position.longitude.toString();
        final String currentTime = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(DateTime.now());

        await _controller.checkIn(
          token: sessionId!,
          employee: employeeId!,
          time: currentTime,
          latitude: currentLat,
          longitude: currentLong,
        );

        if (!mounted) return;
        setState(() => _isProcessing = false);

        if (_controller.errorMessage != null) {
          _showMessage(_controller.errorMessage!, isError: true);
        } else {
          final formattedCheckInTime = DateFormat(
            'hh:mm a',
          ).format(DateTime.now());

          setState(() {
            checkInTime = formattedCheckInTime;
            checkOutTime = null;
            isCheckedIn = true;
          });

          final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          await storage.write(key: 'is_checked_in', value: 'true');
          await storage.write(
            key: 'check_in_time',
            value: formattedCheckInTime,
          );
          await storage.write(key: 'check_in_date', value: currentDate);
          await storage.delete(key: 'check_out_time');

          _showMessage("Checked In Successfully!");
        }
      },
    );
  }

  Future<void> _handleCheckOut() async {
    // Check if session data is loaded
    if (sessionId == null || employeeId == null) {
      _showMessage("Session data not loaded. Please try again.", isError: true);
      return;
    }

    _showConfirmationDialog(
      title: "Confirm Check-Out",
      content: "Are you done for the day?",
      confirmText: "Check Out",
      isCheckIn: false,
      onConfirm: () async {
        // Step 1: Show GPS loading
        setState(() {
          _isProcessing = true;
          _loadingMessage = 'Getting your location...';
        });

        Position position;
        try {
          position = await _getCurrentLocation();
        } on _LocationException catch (e) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          if (e.code == 'location_off') {
            _showLocationOffDialog();
          } else if (e.code == 'permission_permanent') {
            _showLocationPermissionDialog(isPermanent: true);
          } else {
            _showLocationPermissionDialog(isPermanent: false);
          }
          return;
        } catch (e) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          _showMessage(
            'Could not get location. Please try again.',
            isError: true,
          );
          return;
        }

        // Step 2: Show API loading
        if (mounted) {
          setState(() => _loadingMessage = 'Submitting check-out...');
        }

        final String currentLat = position.latitude.toString();
        final String currentLong = position.longitude.toString();
        final String currentTime = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(DateTime.now());

        await _controller.checkOut(
          token: sessionId!,
          employee: employeeId!,
          time: currentTime,
          latitude: currentLat,
          longitude: currentLong,
        );

        if (!mounted) return;
        setState(() => _isProcessing = false);

        if (_controller.errorMessage != null) {
          _showMessage(_controller.errorMessage!, isError: true);
        } else {
          final formattedCheckOutTime = DateFormat(
            'hh:mm a',
          ).format(DateTime.now());

          setState(() {
            checkOutTime = formattedCheckOutTime;
            isCheckedIn = false;
          });

          await storage.write(key: 'is_checked_in', value: 'false');
          await storage.write(
            key: 'check_out_time',
            value: formattedCheckOutTime,
          );

          _showMessage("Checked Out Successfully!");
        }
      },
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required bool isCheckIn,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isCheckIn
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                    color: isCheckIn ? Colors.green : Colors.orange,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog first
                          onConfirm(); // Trigger API Call
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCheckIn
                              ? const Color(0xFF00BFA6)
                              : const Color(0xFFFF8C42),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF6F8FB),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildStatusCard(),
                            const SizedBox(height: 25),
                            _buildLocationCard(),
                            const SizedBox(height: 25),
                            if (checkInTime != null) _buildTimeline(),
                            const SizedBox(height: 30),
                            _buildSliderButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Full-screen loading overlay
            if (_isProcessing) _buildLoadingOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated spinner with colored ring
              SizedBox(
                height: 64,
                width: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCheckedIn
                        ? const Color(0xFFFF8C42)
                        : const Color(0xFF2575FC),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _loadingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait...',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCheckedIn
              ? [const Color(0xFF00BFA6), const Color(0xFF009688)]
              : [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM yyyy').format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                "Welcome Back,",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              Text(
                (fullName ?? '')
                    .split(' ')
                    .where((e) => e.isNotEmpty)
                    .map((e) => e[0].toUpperCase() + e.substring(1))
                    .join(' '),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance Status",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isCheckedIn ? "Checked In" : "Checked Out",
                    style: TextStyle(
                      color: isCheckedIn
                          ? const Color(0xFF00BFA6)
                          : const Color(0xFF2D3436),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCheckedIn
                      ? const Color(0xFFE0F2F1)
                      : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCheckedIn ? Icons.timer : Icons.timer_off_outlined,
                  color: isCheckedIn ? const Color(0xFF009688) : Colors.grey,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.business, color: Color(0xFF2575FC)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Company",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  "Al Sahel Medical Supplies Trading L.L.C",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Activity",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              _buildTimelineItem(
                time: checkInTime ?? "--:--",
                title: "Check In",

                color: const Color(0xFF00BFA6),
                isFirst: true,
                isLast: checkOutTime == null,
              ),
              if (checkOutTime != null)
                _buildTimelineItem(
                  time: checkOutTime!,
                  title: "Check Out",
                  color: const Color(0xFFFF8C42),
                  isFirst: false,
                  isLast: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required Color color,
    required bool isFirst,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 4),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 50, color: Colors.grey.shade200),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderButton() {
    final bool isLoading = _isProcessing || _controller.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        // Disable button while loading to prevent double taps
        onPressed: isLoading
            ? null
            : (isCheckedIn ? _handleCheckOut : _handleCheckIn),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCheckedIn
              ? const Color(0xFFFF8C42)
              : const Color(0xFF2575FC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: (isCheckedIn ? Colors.orange : Colors.blue).withOpacity(
            0.4,
          ),
          // Change style when disabled (loading)
          disabledBackgroundColor: (isCheckedIn ? Colors.orange : Colors.blue)
              .withOpacity(0.6),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCheckedIn ? Icons.logout : Icons.location_on_outlined,
                    size: 26,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCheckedIn ? "Tap to Check Out" : "Tap to Check In",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Private exception type for location errors ──────────────────────────────
class _LocationException implements Exception {
  final String code;
  const _LocationException(this.code);
}
