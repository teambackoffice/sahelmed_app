import 'package:flutter/material.dart';
import 'package:sahelmed_app/core/app_colors.dart';

class MachineServiceCertificate extends StatefulWidget {
  const MachineServiceCertificate({super.key});

  @override
  State<MachineServiceCertificate> createState() =>
      _MachineServiceCertificateState();
}

class _MachineServiceCertificateState extends State<MachineServiceCertificate> {
  // Sample data - replace with your API call
  List<Map<String, dynamic>> certificates = [
    {
      'customer_name': 'ABC Healthcare Ltd',
      'machine_name': 'X-Ray Machine Model 2000',
      'service_type': 'AMC',
      'visit_reference': 'VST-2024-001',
      'date': '2024-01-15',
      'validity': '2024-12-31',
    },
    {
      'customer_name': 'XYZ Medical Center',
      'machine_name': 'CT Scanner Pro',
      'service_type': 'PPM',
      'visit_reference': 'VST-2024-002',
      'date': '2026-01-19', // Today's date for testing
      'validity': '2026-07-18',
    },
    {
      'customer_name': 'City Hospital',
      'machine_name': 'MRI Scanner',
      'service_type': 'AMC',
      'visit_reference': 'VST-2024-003',
      'date': '2025-01-19', // Today's date for testing
      'validity': '2025-12-31',
    },
    {
      'customer_name': 'City Hospital',
      'machine_name': 'MRI Scanner',
      'service_type': 'AMC',
      'visit_reference': 'VST-2024-003',
      'date': '2026-01-19', // Today's date for testing
      'validity': '2025-12-31',
    },
  ];

  bool isLoading = false;
  bool showTodayOnly = true; // Start with today's filter active

  @override
  void initState() {
    super.initState();
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    setState(() => isLoading = true);

    // Replace with your actual API call
    await Future.delayed(const Duration(seconds: 1));

    // Sort by date - most recent first
    certificates.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['date']);
        final dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    setState(() => isLoading = false);
  }

  List<Map<String, dynamic>> get displayCertificates {
    if (!showTodayOnly) return certificates;

    final today = DateTime.now();
    return certificates.where((cert) {
      try {
        final certDate = DateTime.parse(cert['date']);
        return certDate.year == today.year &&
            certDate.month == today.month &&
            certDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayCerts = displayCertificates;
    final todayCount = certificates.where((cert) {
      try {
        final today = DateTime.now();
        final certDate = DateTime.parse(cert['date']);
        return certDate.year == today.year &&
            certDate.month == today.month &&
            certDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Certificates',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Today's Filter Banner
          if (showTodayOnly && todayCount > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.splashGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.today_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Certificates',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$todayCount certificate${todayCount > 1 ? 's' : ''} created today',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => showTodayOnly = false);
                    },
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Show all certificates',
                  ),
                ],
              ),
            ),

          // Show all button when filter is closed
          if (!showTodayOnly && todayCount > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => showTodayOnly = true);
                },
                icon: const Icon(Icons.today_rounded, size: 18),
                label: Text('Show Today\'s Certificates ($todayCount)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade300, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayCerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          showTodayOnly
                              ? 'No certificates created today'
                              : 'No certificates found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          showTodayOnly
                              ? 'Tap the close button to view all certificates'
                              : 'Service certificates will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (showTodayOnly && todayCount == 0) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() => showTodayOnly = false);
                            },
                            icon: const Icon(Icons.list_rounded, size: 18),
                            label: const Text('Show All Certificates'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue.shade700,
                              side: BorderSide(
                                color: Colors.blue.shade300,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchCertificates,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayCerts.length,
                      itemBuilder: (context, index) {
                        final cert = displayCerts[index];
                        return CertificateCard(
                          certificate: cert,
                          onTap: () {
                            // Navigate to detail page
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final Map<String, dynamic> certificate;
  final VoidCallback? onTap;

  const CertificateCard({super.key, required this.certificate, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpired = _isExpired(certificate['validity']);
    final daysUntilExpiry = _getDaysUntilExpiry(certificate['validity']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Type Badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getServiceColor(
                          certificate['service_type'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getServiceIcon(certificate['service_type']),
                        color: _getServiceColor(certificate['service_type']),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Customer & Machine Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate['customer_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            certificate['machine_name'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Service Type Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getServiceColor(
                          certificate['service_type'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getServiceColor(
                            certificate['service_type'],
                          ).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        certificate['service_type'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getServiceColor(certificate['service_type']),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(height: 1, color: Colors.grey.shade100),

                const SizedBox(height: 16),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Visit Reference',
                        value: certificate['visit_reference'] ?? '-',
                        color: Colors.blue,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade100,
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Service Date',
                        value: _formatDate(certificate['date']),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Validity Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expiry Date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(certificate['validity']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onTap != null)
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getServiceColor(String? serviceType) {
    switch (serviceType) {
      case 'AMC':
        return Colors.blue.shade600;
      case 'PPM':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getServiceIcon(String? serviceType) {
    switch (serviceType) {
      case 'AMC':
        return Icons.shield_outlined;
      case 'PPM':
        return Icons.build_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  bool _isExpired(String? validityDate) {
    if (validityDate == null) return false;
    try {
      final validity = DateTime.parse(validityDate);
      return validity.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  int _getDaysUntilExpiry(String? validityDate) {
    if (validityDate == null) return 0;
    try {
      final validity = DateTime.parse(validityDate);
      return validity.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  String _formatDate(String? date) {
    if (date == null) return '-';
    try {
      final dt = DateTime.parse(date);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return date;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
