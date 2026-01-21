import 'package:flutter/material.dart';
import 'package:sahelmed_app/core/app_colors.dart';

class MachineServiceCertificateDetail extends StatefulWidget {
  final Map<String, dynamic> certificate;

  const MachineServiceCertificateDetail({super.key, required this.certificate});

  @override
  State<MachineServiceCertificateDetail> createState() =>
      _MachineServiceCertificateDetailState();
}

class _MachineServiceCertificateDetailState
    extends State<MachineServiceCertificateDetail> {
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final cert = widget.certificate;
    final daysUntilExpiry = _getDaysUntilExpiry(cert['validity']);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: AppColors.darkNavy,
        title: const Text(
          'Certificate Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.splashGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getServiceIcon(cert['service_type']),
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cert['service_type'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Customer Name
                      Text(
                        cert['customer_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Machine Name
                      Text(
                        cert['machine_name'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Visit Reference
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cert['visit_reference'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Validity Status Card
                  const SizedBox(height: 16),

                  // Service Information Card
                  _buildInfoCard(
                    title: 'Service Information',
                    children: [
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Service Date',
                        value: _formatDate(cert['date']),
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.event_outlined,
                        label: 'Valid Until',
                        value: _formatDate(cert['validity']),
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.build_outlined,
                        label: 'Service Type',
                        value: _getServiceTypeName(cert['service_type']),
                        color: _getServiceColor(cert['service_type']),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Customer & Machine Details
                  _buildInfoCard(
                    title: 'Customer & Machine Details',
                    children: [
                      _buildInfoRow(
                        icon: Icons.business_outlined,
                        label: 'Customer',
                        value: cert['customer_name'] ?? '-',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.precision_manufacturing_outlined,
                        label: 'Machine',
                        value: cert['machine_name'] ?? '-',
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Visit Reference',
                        value: cert['visit_reference'] ?? '-',
                        color: Colors.indigo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Service Details (if available)
                  if (cert['service_details'] != null ||
                      cert['technician_name'] != null ||
                      cert['remarks'] != null)
                    _buildInfoCard(
                      title: 'Service Details',
                      children: [
                        if (cert['technician_name'] != null) ...[
                          _buildInfoRow(
                            icon: Icons.person_outline,
                            label: 'Technician',
                            value: cert['technician_name'],
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (cert['service_details'] != null) ...[
                          _buildInfoRow(
                            icon: Icons.description_outlined,
                            label: 'Service Details',
                            value: cert['service_details'],
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (cert['remarks'] != null)
                          _buildInfoRow(
                            icon: Icons.notes_outlined,
                            label: 'Remarks',
                            value: cert['remarks'],
                            color: Colors.blueGrey,
                          ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
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

  String _getServiceTypeName(String? serviceType) {
    switch (serviceType) {
      case 'AMC':
        return 'Annual Maintenance Contract';
      case 'PPM':
        return 'Preventive Maintenance';
      default:
        return serviceType ?? '-';
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
