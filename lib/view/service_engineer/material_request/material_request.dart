import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'material_request_detail.dart';

class MaterialRequestList extends StatefulWidget {
  const MaterialRequestList({super.key});

  @override
  State<MaterialRequestList> createState() => _MaterialRequestListState();
}

class _MaterialRequestListState extends State<MaterialRequestList> {
  // Dummy data for material requests
  final List<Map<String, dynamic>> materialRequests = [
    {
      'id': 'MAT-REQ-2024-001',
      'purpose': 'Purchase',
      'transactionDate': '2024-01-15',
      'requiredBy': '2024-01-20',
      'status': 'Pending',
      'items': [
        {'itemCode': 'ITM-001', 'qty': 10, 'uom': 'Nos'},
        {'itemCode': 'ITM-002', 'qty': 5, 'uom': 'Box'},
      ],
    },
    {
      'id': 'MAT-REQ-2024-002',
      'purpose': 'Material Transfer',
      'transactionDate': '2024-01-14',
      'requiredBy': '2024-01-18',
      'status': 'Approved',
      'items': [
        {'itemCode': 'RAW-101', 'qty': 100, 'uom': 'Kg'},
        {'itemCode': 'RAW-102', 'qty': 50, 'uom': 'Ltr'},
      ],
    },
    {
      'id': 'MAT-REQ-2024-003',
      'purpose': 'Manufacture',
      'transactionDate': '2024-01-13',
      'requiredBy': '2024-01-17',
      'status': 'Rejected',
      'items': [
        {'itemCode': 'COMP-201', 'qty': 25, 'uom': 'Pcs'},
      ],
    },
    {
      'id': 'MAT-REQ-2024-004',
      'purpose': 'Customer Provided',
      'transactionDate': '2024-01-12',
      'requiredBy': '2024-01-16',
      'status': 'Completed',
      'items': [
        {'itemCode': 'CUST-301', 'qty': 15, 'uom': 'Sets'},
        {'itemCode': 'CUST-302', 'qty': 8, 'uom': 'Nos'},
      ],
    },
    {
      'id': 'MAT-REQ-2024-005',
      'purpose': 'Purchase',
      'transactionDate': '2024-01-11',
      'requiredBy': '2024-01-19',
      'status': 'Pending',
      'items': [
        {'itemCode': 'OFF-401', 'qty': 200, 'uom': 'Sheets'},
        {'itemCode': 'OFF-402', 'qty': 10, 'uom': 'Box'},
      ],
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFF9800);
      case 'Approved':
        return const Color(0xFF4CAF50);
      case 'Rejected':
        return const Color(0xFFE53935);
      case 'Completed':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending_outlined;
      case 'Approved':
        return Icons.check_circle_outline;
      case 'Rejected':
        return Icons.cancel_outlined;
      case 'Completed':
        return Icons.task_alt;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getPurposeIcon(String purpose) {
    switch (purpose) {
      case 'Purchase':
        return Icons.shopping_cart_outlined;
      case 'Material Transfer':
        return Icons.swap_horiz;
      case 'Manufacture':
        return Icons.precision_manufacturing_outlined;
      case 'Customer Provided':
        return Icons.person_outline;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: materialRequests.isEmpty
          ? Center(
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
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: materialRequests.length,
              itemBuilder: (context, index) {
                final request = materialRequests[index];
                return _buildMaterialRequestCard(request, index);
              },
            ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  Widget _buildMaterialRequestCard(Map<String, dynamic> request, int index) {
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
                          _getPurposeIcon(request['purpose']),
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
                              request['id'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              request['purpose'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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
                          'Created On',
                          _formatDate(request['transactionDate']),
                          const Color(0xFF5C6BC0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoRow(
                          Icons.event_available_outlined,
                          'Required By',
                          _formatDate(request['requiredBy']),
                          const Color(0xFF26A69A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Items Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Items (${request['items'].length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          request['items'].length > 2
                              ? 2
                              : request['items'].length,
                          (index) {
                            final item = request['items'][index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A237E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item['itemCode'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF1A237E,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item['qty']} ${item['uom']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1A237E),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (request['items'].length > 2)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  size: 14,
                                  color: Color(0xFF1A237E),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${request['items'].length - 2} more items',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1A237E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
