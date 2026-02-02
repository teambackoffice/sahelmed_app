import 'package:flutter/material.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/modal/get_machine_service_modal.dart';

class MachineServiceCertificateDetail extends StatefulWidget {
  final Certificate certificate;

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
    final daysUntilExpiry = _getDaysUntilExpiry(cert.nextServiceDue);

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
                              _getServiceIcon(cert.contractType),
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getContractTypeText(cert.contractType),
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
                        cert.customerName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Machine Name / Title
                      Text(
                        cert.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Certificate Number
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cert.certificateNumber,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
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
                              _getStatusIcon(cert.status),
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusText(cert.status),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
                  const SizedBox(height: 16),

                  // Service Information Card
                  _buildInfoCard(
                    title: 'Service Information',
                    children: [
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Service Date',
                        value: _formatDate(cert.serviceDate),
                        color: Colors.purple,
                      ),
                      cert.nextServiceDue != null
                          ? const SizedBox(height: 16)
                          : const SizedBox(),
                      cert.nextServiceDue != null
                          ? _buildInfoRow(
                              icon: Icons.event_outlined,
                              label: 'Next Service Due',
                              value: _formatDate(cert.nextServiceDue),
                              color: Colors.orange,
                            )
                          : const SizedBox(),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Visit Date',
                        value: _formatDate(cert.visitDate),
                        color: Colors.teal,
                      ),
                      // const SizedBox(height: 16),
                      // _buildInfoRow(
                      //   icon: Icons.access_time_outlined,
                      //   label: 'Visit Time',
                      //   value: cert.visitTime,
                      //   color: Colors.indigo,
                      // ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.build_outlined,
                        label: 'Contract Type',
                        value: _getServiceTypeName(cert.contractType),
                        color: _getServiceColor(cert.contractType),
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
                        value: cert.customerName ?? '-',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.precision_manufacturing_outlined,
                        label: 'Certificate Title',
                        value: cert.title,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Certificate Number',
                        value: cert.certificateNumber,
                        color: Colors.indigo,
                      ),
                      if (cert.maintenanceVisit != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.description_outlined,
                          label: 'Maintenance Visit',
                          value: cert.maintenanceVisit!,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Service Engineer Details
                  _buildInfoCard(
                    title: 'Service Engineer',
                    children: [
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Engineer Name',
                        value: cert.serviceEngineerName,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Engineer ID',
                        value: cert.serviceEngineer,
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // // Service Status & Results
                  // _buildInfoCard(
                  //   title: 'Service Status & Results',
                  //   children: [
                  //     _buildInfoRow(
                  //       icon: Icons.assessment_outlined,
                  //       label: 'Overall Status',
                  //       value: _getOverallStatusText(cert.overallServiceStatus),
                  //       color: _getOverallStatusColor(
                  //         cert.overallServiceStatus,
                  //       ),
                  //     ),
                  //     const SizedBox(height: 16),
                  //     Row(
                  //       children: [
                  //         Expanded(
                  //           child: _buildStatCard(
                  //             icon: Icons.build_circle_outlined,
                  //             label: 'Total Machines',
                  //             value: cert.totalMachinesServiced.toString(),
                  //             color: Colors.blue,
                  //           ),
                  //         ),
                  //         const SizedBox(width: 12),
                  //         Expanded(
                  //           child: _buildStatCard(
                  //             icon: Icons.check_circle_outline,
                  //             label: 'Passed',
                  //             value: cert.machinesPassed.toString(),
                  //             color: Colors.green,
                  //           ),
                  //         ),
                  //         const SizedBox(width: 12),
                  //         Expanded(
                  //           child: _buildStatCard(
                  //             icon: Icons.cancel_outlined,
                  //             label: 'Failed',
                  //             value: cert.machinesFailed.toString(),
                  //             color: Colors.red,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     if (cert.serviceDescription != null &&
                  //         cert.serviceDescription!.isNotEmpty) ...[
                  //       const SizedBox(height: 16),
                  //       _buildInfoRow(
                  //         icon: Icons.description_outlined,
                  //         label: 'Service Description',
                  //         value: cert.serviceDescription!,
                  //         color: Colors.deepOrange,
                  //       ),
                  //     ],
                  //     if (cert.technicianComments != null &&
                  //         cert.technicianComments.toString().isNotEmpty) ...[
                  //       const SizedBox(height: 16),
                  //       _buildInfoRow(
                  //         icon: Icons.notes_outlined,
                  //         label: 'Technician Comments',
                  //         value: cert.technicianComments.toString(),
                  //         color: Colors.blueGrey,
                  //       ),
                  //     ],
                  //   ],
                  // ),
                  // const SizedBox(height: 16),

                  // Certificate Information
                  _buildInfoCard(
                    title: 'Certificate Information',
                    children: [
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Issue Date',
                        value: _formatDate(cert.certificateIssueDate),
                        color: Colors.purple,
                      ),
                      // const SizedBox(height: 16),
                      // _buildInfoRow(
                      //   icon: Icons.verified_outlined,
                      //   label: 'Certificate Generated',
                      //   value: cert.certificateGenerated == 1 ? 'Yes' : 'No',
                      //   color: cert.certificateGenerated == 1
                      //       ? Colors.green
                      //       : Colors.orange,
                      // ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Created By',
                        value: cert
                            .serviceEngineer, // fallback to service engineer email
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.update_outlined,
                        label: 'Last Modified',
                        value: _formatDateTime(cert.lastModified),
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),

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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  String _getServiceTypeName(ContractType type) {
    switch (type) {
      case ContractType.EMERGENCY:
        return 'Emergency Service';
      case ContractType.PPM:
        return 'Preventive Maintenance';
      case ContractType.EMPTY:
        return 'Not Specified';
      default:
        return 'Not Specified';
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

  IconData _getStatusIcon(Status status) {
    switch (status) {
      case Status.DRAFT:
        return Icons.edit_outlined;
      case Status.SUBMITTED:
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _getOverallStatusText(OverallServiceStatus status) {
    switch (status) {
      case OverallServiceStatus.PASS:
        return 'Passed';
      default:
        return 'Unknown';
    }
  }

  Color _getOverallStatusColor(OverallServiceStatus status) {
    switch (status) {
      case OverallServiceStatus.PASS:
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  // String _getCreatedByText(EdBy? createdBy) {
  //   if (createdBy == null) return 'Unknown';
  //   switch (createdBy) {
  //     case EdBy.ADMINISTRATOR:
  //       return 'Administrator';
  //     case EdBy.SALESENGINEER_GMAIL_COM:
  //       return 'Sales Engineer';
  //     case EdBy.SERVICEMANAGER_GMAIL_COM:
  //       return 'Service Manager';
  //     default:
  //       return 'Unknown';
  //   }
  // }

  int _getDaysUntilExpiry(DateTime? validityDate) {
    if (validityDate == null) return 0;
    try {
      return validityDate.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
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

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
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
      final time =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} at $time';
    } catch (e) {
      return '-';
    }
  }
}
