import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/providers/get_leads_provider.dart';
import 'package:sahelmed_app/view/sales_person/leads/create_new_lead.dart';

class Leadspage extends StatefulWidget {
  const Leadspage({super.key});

  @override
  State<Leadspage> createState() => _LeadspageState();
}

class _LeadspageState extends State<Leadspage> {
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    // Defer the load until after the first frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeads();
    });
  }

  Future<void> _loadLeads() async {
    await context.read<LeadController>().getLeads();
    if (mounted) {
      setState(() {
        _isInitialLoad = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'lead':
        return const Color(0xFF3B82F6); // Soft Blue
      case 'contacted':
      case 'open':
        return const Color(0xFFF59E0B); // Soft Amber
      case 'qualified':
      case 'converted':
        return const Color(0xFF10B981); // Soft Green
      case 'lost':
      case 'do not contact':
        return const Color(0xFFEF4444); // Soft Red
      default:
        return Colors.grey;
    }
  }

  IconData _sourceIcon(String? source) {
    if (source == null) return Icons.source;

    switch (source.toLowerCase()) {
      case 'website':
      case 'existing customer':
        return Icons.language;
      case 'whatsapp':
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'referral':
      case 'customer':
        return Icons.people_outline;
      case 'campaign':
      case 'advertisement':
        return Icons.campaign_outlined;
      case 'walk in':
        return Icons.directions_walk;
      default:
        return Icons.source;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1D4ED8),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Leads',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateNewLead(),
                  ),
                );

                // Refresh leads if new lead was created
                if (result == true && mounted) {
                  context.read<LeadController>().getLeads();
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 35),
              ),
            ),
          ),
        ],
      ),
      body: _isInitialLoad
          ? _buildLoadingState()
          : Consumer<LeadController>(
              builder: (context, controller, child) {
                // Error state
                if (controller.errorMessage != null &&
                    controller.leads.isEmpty) {
                  return _buildErrorState(controller);
                }

                // Empty state
                if (controller.leads.isEmpty) {
                  return _buildEmptyState();
                }

                // Success state - show leads
                return _buildLeadsList(controller);
              },
            ),
    );
  }

  // Loading State Widget
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF1D4ED8),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading leads...',
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

  // Error State Widget
  Widget _buildErrorState(LeadController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to load leads',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? 'Unknown error',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isInitialLoad = true;
                });
                _loadLeads();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No leads found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first lead to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // Leads List Widget
  Widget _buildLeadsList(LeadController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.getLeads(),
      color: const Color(0xFF1D4ED8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: controller.leads.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final lead = controller.leads[index];
          final color = _statusColor(lead.status);
          final icon = _sourceIcon(lead.source);

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
                  // Icon Container
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),

                  // Lead Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lead Name
                        Text(
                          lead.leadName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Company Name
                        Text(
                          lead.companyName ?? 'No organization',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Mobile Number
                        if (lead.mobile != null && lead.mobile!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  lead.mobile!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Status Pill
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
