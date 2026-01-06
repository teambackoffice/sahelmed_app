import 'package:flutter/material.dart';
import 'package:sahelmed_app/view/sales_person/leads/create_new_lead.dart';

class Lead {
  final String firstName;
  final String organization;
  final String status;
  final String source;

  Lead({
    required this.firstName,
    required this.organization,
    required this.status,
    required this.source,
  });
}

class Leadspage extends StatelessWidget {
  const Leadspage({super.key});

  static final List<Lead> leads = [
    Lead(
      firstName: 'Rahul',
      organization: 'TechSoft',
      status: 'New',
      source: 'Website',
    ),
    Lead(
      firstName: 'Amina',
      organization: 'BlueOcean LLC',
      status: 'Contacted',
      source: 'Referral',
    ),
    Lead(
      firstName: 'Rahul',
      organization: 'TechSoft',
      status: 'New',
      source: 'Website',
    ),
    Lead(
      firstName: 'John',
      organization: 'NextGen Corp',
      status: 'Qualified',
      source: 'WhatsApp',
    ),
    Lead(
      firstName: 'Rahul',
      organization: 'TechSoft',
      status: 'New',
      source: 'Website',
    ),
    Lead(
      firstName: 'Fatima',
      organization: 'VisionWorks',
      status: 'Lost',
      source: 'Campaign',
    ),
    Lead(
      firstName: 'Rahul',
      organization: 'TechSoft',
      status: 'New',
      source: 'Website',
    ),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'New':
        return const Color(0xFF3B82F6); // Soft Blue
      case 'Contacted':
        return const Color(0xFFF59E0B); // Soft Amber
      case 'Qualified':
        return const Color(0xFF10B981); // Soft Green
      case 'Lost':
        return const Color(0xFFEF4444); // Soft Red
      default:
        return Colors.grey;
    }
  }

  // Helper to map source text to icons
  IconData _sourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'website':
        return Icons.language;
      case 'whatsapp':
        return Icons.chat_bubble_outline;
      case 'referral':
        return Icons.people_outline;
      case 'campaign':
        return Icons.campaign_outlined;
      default:
        return Icons.source;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FA,
      ), // Very light grey-blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Leads',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateNewLead(),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: leads.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final lead = leads[index];
          final color = _statusColor(lead.status);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Unique Element: Icon Box instead of Circle Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _sourceIcon(lead.source),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.firstName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lead.organization,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Pill (Clean Style)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      lead.status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
