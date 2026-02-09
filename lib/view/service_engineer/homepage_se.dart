import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/providers/get_mr_count_provider.dart';
import 'package:sahelmed_app/providers/get_msc_count_provider.dart';
import 'package:sahelmed_app/providers/logout_provider.dart';
import 'package:sahelmed_app/providers/get_mv_count_provider.dart';
import 'package:sahelmed_app/view/login_page.dart';
import 'package:sahelmed_app/view/service_engineer/machine_certificate/machine_certificate.dart';
import 'package:sahelmed_app/view/service_engineer/maintenance_visit/maintenance_visit.dart';
import 'package:sahelmed_app/view/service_engineer/material_request/material_request.dart';

class ServiceEngineerHomepage extends StatefulWidget {
  const ServiceEngineerHomepage({super.key});

  @override
  State<ServiceEngineerHomepage> createState() =>
      _ServiceEngineerHomepageState();
}

class _ServiceEngineerHomepageState extends State<ServiceEngineerHomepage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String fullName = '';

  @override
  void initState() {
    super.initState();
    _loadFullName();
    // Defer _fetchCounts() to after the build phase completes
    // This prevents calling notifyListeners() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCounts();
    });
  }

  Future<void> _loadFullName() async {
    final name = await _storage.read(key: 'full_name');

    setState(() {
      fullName = name ?? '';
    });
  }

  Future<void> _fetchCounts() async {
    // Fetch MV Count
    final mvCountProvider = Provider.of<GetMvCountProvider>(
      context,
      listen: false,
    );

    // Fetch Material Request Count
    final mrCountProvider = Provider.of<GetMaterialRequestCountProvider>(
      context,
      listen: false,
    );

    // Fetch Machine Service Certificate Count
    final mscCountProvider =
        Provider.of<GetMachineServiceCertificateCountProvider>(
          context,
          listen: false,
        );

    // Fetch all counts concurrently
    await Future.wait([
      mvCountProvider.fetchMvCount(),
      mrCountProvider.fetchMaterialRequestCount(),
      mscCountProvider.fetchTotalCount(),
    ]);
  }

  Future<void> _refreshData() async {
    await _fetchCounts();
  }

  void showLogoutDialog(BuildContext context) async {
    final logoutController = Provider.of<LogoutController>(
      context,
      listen: false,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),

              // Animated Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.splashGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[200]!.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 28),

              // Title
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),

              const SizedBox(height: 12),

              // Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Are you sure you want to\nlogout from your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Buttons with loading state
              Consumer<LogoutController>(
                builder: (_, controller, __) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading
                                ? null
                                : () async {
                                    // Perform logout
                                    final success = await logoutController
                                        .logout();

                                    if (context.mounted) {
                                      Navigator.of(context).pop(success);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.darkNavy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: controller.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Yes, Logout',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Cancel Button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: controller.isLoading
                                ? null
                                : () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    // Check if logout was successful
    final success =
        logoutController.isLoading == false &&
        logoutController.errorMessage == null;

    if (success && context.mounted) {
      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else if (logoutController.errorMessage != null && context.mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  logoutController.errorMessage ?? 'Logout failed',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
        title: Row(
          children: [
            Container(
              child: Image.asset(
                "assets/app-logo-transparent.png",
                height: 45,
                width: 45,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Al Sahel Medical",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.blue[900]),
              onPressed: () => showLogoutDialog(context),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.splashGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      (fullName ?? '').trim().isNotEmpty
                          ? fullName!
                                .trim()
                                .split(' ')
                                .where((e) => e.isNotEmpty)
                                .map((e) => e[0].toUpperCase() + e.substring(1))
                                .join(' ')
                          : 'Welcome!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Track your service performance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section Title
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Enhanced Menu Items - Always show grid, loading only on count
              Consumer3<
                GetMvCountProvider,
                GetMaterialRequestCountProvider,
                GetMachineServiceCertificateCountProvider
              >(
                builder:
                    (
                      context,
                      mvCountProvider,
                      mrCountProvider,
                      mscCountProvider,
                      child,
                    ) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.95,
                        children: [
                          _buildEnhancedMenuItem(
                            icon: Icons.description_outlined,
                            title: 'Assigned Visit',
                            subtitle: '',
                            color: Colors.orange,
                            count: mvCountProvider.totalCount,
                            isLoading: mvCountProvider.isLoading,
                            hasError: mvCountProvider.errorMessage != null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MaintenanceVisit(),
                                ),
                              );
                            },
                          ),
                          _buildEnhancedMenuItem(
                            icon: Icons.shopping_cart,
                            title: 'Material Request',
                            subtitle: '',
                            color: Colors.orange,
                            count:
                                mrCountProvider
                                    .materialRequestCount
                                    ?.totalCount ??
                                0,
                            isLoading: mrCountProvider.isLoading,
                            hasError: mrCountProvider.error != null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MaterialRequestList(),
                                ),
                              );
                            },
                          ),
                          _buildEnhancedMenuItem(
                            icon: Icons.workspace_premium_outlined,
                            title: 'Machine Service Certificate',
                            subtitle: '',
                            color: Colors.orange,
                            count: mscCountProvider.totalCount,
                            isLoading: mscCountProvider.isLoading,
                            hasError: mscCountProvider.errorMessage.isNotEmpty,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MachineServiceCertificate(),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    int? count,
    bool isLoading = false,
    bool hasError = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 32),
              ),

              const SizedBox(height: 2),

              // Title
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.3,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 2),

              // Count Section with Loading/Error States
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF475569), Color(0xFF334155)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF475569).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.5),
                              child: TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 600),
                                builder: (context, double value, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      -4 * (value > 0.5 ? 1 - value : value),
                                    ),
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        )
                      : hasError
                      ? Icon(Icons.error_outline, color: Colors.white, size: 20)
                      : Text(
                          (count ?? 0) > 99 ? '99+' : (count ?? 0).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
