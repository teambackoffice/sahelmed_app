import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/modal/get_machine_service_modal.dart';
import 'package:sahelmed_app/providers/get_machine_service_certi_provider.dart';
import 'package:sahelmed_app/view/service_engineer/machine_certificate/machine_certifcate_detail.dart';

class MachineServiceCertificate extends StatefulWidget {
  const MachineServiceCertificate({super.key});

  @override
  State<MachineServiceCertificate> createState() =>
      _MachineServiceCertificateState();
}

class _MachineServiceCertificateState extends State<MachineServiceCertificate> {
  bool showTodayOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<GetMachineServiceProvider>()
          .fetchMachineServiceCertificates();
    });
  }

  List<Certificate> get displayCertificates {
    final provider = context.watch<GetMachineServiceProvider>();
    final certificates = provider.certificates;

    if (!showTodayOnly) return certificates;

    final today = DateTime.now();
    return certificates.where((cert) {
      try {
        final certDate = cert.visitDate;
        if (certDate == null) return false;
        return certDate.year == today.year &&
            certDate.month == today.month &&
            certDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  int get todayCount {
    final provider = context.watch<GetMachineServiceProvider>();
    final certificates = provider.certificates;

    final today = DateTime.now();
    return certificates.where((cert) {
      try {
        final certDate = cert.visitDate;
        if (certDate == null) return false;
        return certDate.year == today.year &&
            certDate.month == today.month &&
            certDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetMachineServiceProvider>();
    final displayCerts = displayCertificates;
    final todayCountValue = todayCount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: AppColors.darkNavy,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Certificates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Today's Filter Banner
          if (showTodayOnly && todayCountValue > 0)
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
                          '$todayCountValue certificate${todayCountValue > 1 ? 's' : ''} created today',
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
          if (!showTodayOnly && todayCountValue > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => showTodayOnly = true);
                },
                icon: const Icon(Icons.today_rounded, size: 18),
                label: Text('Show Today\'s Certificates ($todayCountValue)'),
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

          // Error Message
          if (provider.errorMessage != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: provider.isLoading
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
                        if (showTodayOnly && todayCountValue == 0) ...[
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
                    onRefresh: () => provider.fetchMachineServiceCertificates(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayCerts.length,
                      itemBuilder: (context, index) {
                        final cert = displayCerts[index];
                        return CertificateCard(
                          certificate: cert,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MachineServiceCertificateDetail(
                                      certificate: cert,
                                    ),
                              ),
                            );
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
  final Certificate certificate;
  final VoidCallback? onTap;

  const CertificateCard({super.key, required this.certificate, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
                          certificate.contractType,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getServiceIcon(certificate.contractType),
                        color: _getServiceColor(certificate.contractType),
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
                            certificate.customerName ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            certificate.title,
                            maxLines: 2, // 👈 limit to two lines
                            overflow:
                                TextOverflow.ellipsis, // optional: adds "..."
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
                          certificate.contractType,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getServiceColor(
                            certificate.contractType,
                          ).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getContractTypeText(certificate.contractType),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getServiceColor(certificate.contractType),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(height: 1, color: Colors.grey.shade300),

                const SizedBox(height: 16),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Certificate No',
                        value: certificate.certificateNumber,
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
                        value: _formatDate(certificate.serviceDate),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status & Next Service
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        certificate.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(certificate.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(certificate.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(certificate.status),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getContractTypeText(ContractType type) {
    switch (type) {
      case ContractType.EMERGENCY:
        return 'Emergency';
      case ContractType.PPM:
        return 'PPM';
      case ContractType.EMPTY:
        return 'N/A';
      default:
        return 'N/A';
    }
  }

  Color _getServiceColor(ContractType type) {
    switch (type) {
      case ContractType.EMERGENCY:
        return Colors.red.shade600;
      case ContractType.PPM:
        return Colors.green.shade600;
      case ContractType.EMPTY:
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getServiceIcon(ContractType type) {
    switch (type) {
      case ContractType.EMERGENCY:
        return Icons.warning_outlined;
      case ContractType.PPM:
        return Icons.build_outlined;
      case ContractType.EMPTY:
        return Icons.description_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  String _getStatusText(Status status) {
    switch (status) {
      case Status.DRAFT:
        return 'Draft';
      case Status.SUBMITTED:
        return 'Submitted';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.DRAFT:
        return Colors.orange;
      case Status.SUBMITTED:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '-';
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
