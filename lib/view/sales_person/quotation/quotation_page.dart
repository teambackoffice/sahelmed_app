import 'package:flutter/material.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/view/sales_person/quotation/create_quotation.dart';

class QuotationPage extends StatelessWidget {
  const QuotationPage({super.key});

  final List<Map<String, dynamic>> quotations = const [
    {
      "customerName": "ABC Traders",
      "orderType": "Sales",
      "items": [
        {"name": "Cement", "qty": 10, "price": 350},
        {"name": "Steel Rod", "qty": 5, "price": 500},
      ],
    },
    {
      "customerName": "XYZ Constructions",
      "orderType": "Maintenance",
      "items": [
        {"name": "Paint", "qty": 8, "price": 450},
        {"name": "Brush", "qty": 12, "price": 80},
      ],
    },
    {
      "customerName": "ABC Traders",
      "orderType": "Sales",
      "items": [
        {"name": "Cement", "qty": 10, "price": 350},
        {"name": "Steel Rod", "qty": 5, "price": 500},
      ],
    },
    {
      "customerName": "XYZ Constructions",
      "orderType": "Maintenance",
      "items": [
        {"name": "Paint", "qty": 8, "price": 450},
        {"name": "Brush", "qty": 12, "price": 80},
      ],
    },
    {
      "customerName": "ABC Traders",
      "orderType": "Sales",
      "items": [
        {"name": "Cement", "qty": 10, "price": 350},
        {"name": "Steel Rod", "qty": 5, "price": 500},
      ],
    },
    {
      "customerName": "XYZ Constructions",
      "orderType": "Maintenance",
      "items": [
        {"name": "Paint", "qty": 8, "price": 450},
        {"name": "Brush", "qty": 12, "price": 80},
      ],
    },
    {
      "customerName": "ABC Traders",
      "orderType": "Sales",
      "items": [
        {"name": "Cement", "qty": 10, "price": 350},
        {"name": "Steel Rod", "qty": 5, "price": 500},
      ],
    },
    {
      "customerName": "XYZ Constructions",
      "orderType": "Maintenance",
      "items": [
        {"name": "Paint", "qty": 8, "price": 450},
        {"name": "Brush", "qty": 12, "price": 80},
      ],
    },
    {
      "customerName": "Home Store",
      "orderType": "Shopping Cart",
      "items": [
        {"name": "Tiles", "qty": 20, "price": 120},
      ],
    },
  ];

  double calculateTotal(List items) {
    double total = 0;
    for (var item in items) {
      total += item['qty'] * item['price'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey-blue background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Quotations',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateQuotation(),
                  ),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: quotations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final quotation = quotations[index];
          final items = quotation['items'] as List;
          final total = calculateTotal(items);
          final customerName = quotation['customerName'];
          final String initial = customerName.substring(0, 1);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header: Customer Info & Status
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        radius: 24,
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "INV-${1000 + index}", // Dummy ID
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(quotation['orderType']),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // Body: Item List
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${items.length} Items",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...items.map<Widget>((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${item['name']}  x${item['qty']}",
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "₹${item['price'] * item['qty']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // Footer: Total & Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FC), // Slightly off-white footer
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Grand Total",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "₹${total.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // _buildActionButton(
                          //   icon: Icons.share_outlined,
                          //   onTap: () {},
                          // ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.arrow_forward,
                            color: Color(0xFF2563EB),
                            iconColor: Colors.white,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper Widget for the Status Chip
  Widget _buildStatusChip(String type) {
    Color color;
    Color bgColor;

    switch (type) {
      case 'Sales':
        color = Colors.orange.shade700;
        bgColor = Colors.orange.shade50;
        break;
      case 'Maintenance':
        color = Colors.blue.shade700;
        bgColor = Colors.blue.shade50;
        break;
      default:
        color = Colors.purple.shade700;
        bgColor = Colors.purple.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper Widget for Circular Action Buttons
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color iconColor = Colors.black54,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: color == Colors.white ? 0 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: color == Colors.white
                ? Border.all(color: Colors.grey.shade300)
                : null,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}
