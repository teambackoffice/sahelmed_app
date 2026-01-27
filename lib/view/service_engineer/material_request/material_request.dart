import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/modal/get_material_request_modal.dart';
import 'package:sahelmed_app/providers/get_material_request_provider.dart';
import 'material_request_detail.dart';

class MaterialRequestList extends StatefulWidget {
  const MaterialRequestList({super.key});

  @override
  State<MaterialRequestList> createState() => _MaterialRequestListState();
}

class _MaterialRequestListState extends State<MaterialRequestList> {
  late GetMachineRequestController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GetMachineRequestController();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchRequests();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'draft':
        return const Color(0xFFFF9800);
      case 'approved':
      case 'submitted':
        return const Color(0xFF4CAF50);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFE53935);
      case 'completed':
      case 'stopped':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'draft':
        return Icons.pending_outlined;
      case 'approved':
      case 'submitted':
        return Icons.check_circle_outline;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'completed':
      case 'stopped':
        return Icons.task_alt;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getPurposeIcon(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'purchase':
        return Icons.shopping_cart_outlined;
      case 'material transfer':
      case 'material issue':
        return Icons.swap_horiz;
      case 'manufacture':
        return Icons.precision_manufacturing_outlined;
      case 'customer provided':
        return Icons.person_outline;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Material Requests',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.darkNavy,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _controller.fetchRequests();
              },
            ),
          ],
        ),
        body: Consumer<GetMachineRequestController>(
          builder: (context, controller, child) {
            // Loading state
            if (controller.isLoading && controller.requests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (controller.errorMessage != null &&
                controller.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading requests',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.fetchRequests();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkNavy,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Empty state
            if (controller.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No material requests found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Data loaded successfully
            return RefreshIndicator(
              onRefresh: () => controller.fetchRequests(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.requests.length,
                itemBuilder: (context, index) {
                  final request = controller.requests[index];
                  return _buildMaterialRequestCard(request, index);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Widget _buildMaterialRequestCard(Datum request, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MaterialRequestDetail(request: request),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getPurposeIcon(request.materialRequestType),
                          color: const Color(0xFF1A237E),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              request.materialRequestType,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            request.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(request.status),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(request.status),
                              size: 14,
                              color: _getStatusColor(request.status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              request.status,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(request.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title if available
                  if (request.title.isNotEmpty) ...[
                    Text(
                      request.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade200,
                          Colors.grey.shade100,
                          Colors.grey.shade200,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Information
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          Icons.calendar_today_outlined,
                          'Transaction Date',
                          _formatDate(request.transactionDate),
                          const Color(0xFF5C6BC0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoRow(
                          Icons.event_available_outlined,
                          'Required By',
                          _formatDate(request.scheduleDate),
                          const Color(0xFF26A69A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Warehouse Information
                  if (request.setWarehouse.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.warehouse_outlined,
                              size: 16,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Target Warehouse',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  request.setWarehouse ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Company Information
                  Row(
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        request.company,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
