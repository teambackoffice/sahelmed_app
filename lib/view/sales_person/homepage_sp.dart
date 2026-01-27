import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/providers/logout_provider.dart';
import 'package:sahelmed_app/view/login_page.dart';
import 'package:sahelmed_app/view/sales_person/check-in/check-in.dart';
import 'package:sahelmed_app/view/sales_person/leads/leads.dart';
import 'package:sahelmed_app/view/sales_person/quotation/quotation_page.dart';

class SalesPersonHomepage extends StatefulWidget {
  const SalesPersonHomepage({super.key});

  @override
  State<SalesPersonHomepage> createState() => _SalesPersonHomepageState();
}

class _SalesPersonHomepageState extends State<SalesPersonHomepage> {
  String fullName = '';

  @override
  void initState() {
    super.initState();
  }

  void showLogoutDialog(BuildContext context) async {
    final logoutController = Provider.of<LogoutController>(
      context,
      listen: false,
    );

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.blue[900]),
            const SizedBox(width: 12),
            const Text(
              'Confirm Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          Consumer<LogoutController>(
            builder: (_, controller, __) {
              return ElevatedButton(
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        Navigator.pop(context, true);
                      },
                child: controller.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Logout'),
              );
            },
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await logoutController.logout();

      if (success) {
        // Navigate to Login Screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(logoutController.errorMessage ?? 'Logout failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Greeting Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3B82F6), // Lighter Blue
                    Color(0xFF2563EB), // Base Blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

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
                    fullName.isNotEmpty
                        ? '${fullName[0].toUpperCase()}${fullName.substring(1)}'
                        : 'Welcome!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Track your sales performance',
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

            // Enhanced Menu Items
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildEnhancedMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Quotations',
                  subtitle: 'Create & manage quotes',
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to Quotation page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuotationPage()),
                    );
                  },
                ),
                _buildEnhancedMenuItem(
                  icon: Icons.person_search,
                  title: 'Leads',
                  subtitle: 'Track potential customers',
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to Leads page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Leadspage()),
                    );
                  },
                ),

                _buildEnhancedMenuItem(
                  icon: Icons.location_on,
                  title: 'Check-In',
                  subtitle: 'Log your location',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeCheckIn(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
