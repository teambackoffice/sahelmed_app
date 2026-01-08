import 'package:flutter/material.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/view/sales_engineer/maintenance_visit/visit_detail.dart';

class MaintenanceVisit extends StatefulWidget {
  const MaintenanceVisit({super.key});

  @override
  State<MaintenanceVisit> createState() => _MaintenanceVisitState();
}

class _MaintenanceVisitState extends State<MaintenanceVisit> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _visits = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchAssignedVisits();
  }

  Future<void> _fetchAssignedVisits() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Replace with your actual API call
      // final response = await ApiService.getAssignedVisits();

      // Mock data for demonstration
      await Future.delayed(const Duration(seconds: 1));
      _visits = [
        {
          'name': 'MV-2024-001',
          'customer': 'ABC Company',
          'customer_contact': '+971 50 123 4567',
          'customer_email': 'contact@abccompany.com',
          'site': 'Main Office Building',
          'site_address': 'Sheikh Zayed Road, Dubai, UAE',
          'scheduled_date': '2024-01-10',
          'scheduled_time': '10:00 AM',
          'status': 'Scheduled',
          'priority': 'High',
          'maintenance_type': 'Preventive',
          'equipment': 'HVAC System',
          'equipment_model': 'Carrier 40RUQA',
          'equipment_serial': 'SN-2023-HV-001',
          'description': 'Regular maintenance check for HVAC system',
          'notes': 'Check all filters and refrigerant levels',
          'assigned_to': 'John Smith',
          'estimated_duration': '2 hours',
          'checklist': [
            {'task': 'Inspect air filters', 'completed': false},
            {'task': 'Check refrigerant levels', 'completed': false},
            {'task': 'Test thermostat', 'completed': false},
            {'task': 'Clean condenser coils', 'completed': false},
          ],
        },

        {
          'name': 'MV-2024-002',
          'customer': 'XYZ Corporation',
          'customer_contact': '+971 4 567 8900',
          'customer_email': 'support@xyzcorp.com',
          'site': 'Warehouse A',
          'site_address': 'Jebel Ali Industrial Area, Dubai, UAE',
          'scheduled_date': '2024-01-11',
          'scheduled_time': '02:00 PM',
          'status': 'In Progress',
          'priority': 'Medium',
          'maintenance_type': 'Corrective',
          'equipment': 'Generator',
          'equipment_model': 'Caterpillar C15',
          'equipment_serial': 'SN-2023-GN-045',
          'description': 'Fix generator overheating issue',
          'notes': 'Customer reported unusual noise and temperature spike',
          'assigned_to': 'Ahmed Hassan',
          'estimated_duration': '3 hours',
          'checklist': [
            {'task': 'Check coolant levels', 'completed': true},
            {'task': 'Inspect radiator', 'completed': true},
            {'task': 'Test temperature sensors', 'completed': false},
            {'task': 'Replace coolant if needed', 'completed': false},
          ],
        },
        {
          'name': 'MV-2024-001',
          'customer': 'ABC Company',
          'customer_contact': '+971 50 123 4567',
          'customer_email': 'contact@abccompany.com',
          'site': 'Main Office Building',
          'site_address': 'Sheikh Zayed Road, Dubai, UAE',
          'scheduled_date': '2024-01-10',
          'scheduled_time': '10:00 AM',
          'status': 'Scheduled',
          'priority': 'High',
          'maintenance_type': 'Preventive',
          'equipment': 'HVAC System',
          'equipment_model': 'Carrier 40RUQA',
          'equipment_serial': 'SN-2023-HV-001',
          'description': 'Regular maintenance check for HVAC system',
          'notes': 'Check all filters and refrigerant levels',
          'assigned_to': 'John Smith',
          'estimated_duration': '2 hours',
          'checklist': [
            {'task': 'Inspect air filters', 'completed': false},
            {'task': 'Check refrigerant levels', 'completed': false},
            {'task': 'Test thermostat', 'completed': false},
            {'task': 'Clean condenser coils', 'completed': false},
          ],
        },
        {
          'name': 'MV-2024-003',
          'customer': 'Tech Solutions Ltd',
          'customer_contact': '+971 2 345 6789',
          'customer_email': 'ops@techsolutions.ae',
          'site': 'Data Center',
          'site_address': 'Dubai Internet City, Dubai, UAE',
          'scheduled_date': '2024-01-12',
          'scheduled_time': '09:00 AM',
          'status': 'Scheduled',
          'priority': 'Critical',
          'maintenance_type': 'Emergency',
          'equipment': 'Cooling Unit',
          'equipment_model': 'Liebert DS',
          'equipment_serial': 'SN-2023-CU-012',
          'description': 'Emergency repair of cooling unit',
          'notes':
              'URGENT: Data center temperature rising. Needs immediate attention.',
          'assigned_to': 'Mohammad Ali',
          'estimated_duration': '4 hours',
          'checklist': [
            {'task': 'Diagnose cooling failure', 'completed': false},
            {'task': 'Check compressor', 'completed': false},
            {'task': 'Inspect electrical connections', 'completed': false},
            {'task': 'Test backup cooling system', 'completed': false},
          ],
        },
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching visits: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredVisits {
    if (_selectedFilter == 'All') return _visits;
    return _visits.where((v) => v['status'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF5B8DEF);
      case 'in progress':
        return const Color(0xFFFF9F43);
      case 'completed':
        return const Color(0xFF26C281);
      case 'cancelled':
        return const Color(0xFFEF5B5B);
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return const Color(0xFFFF4757);
      case 'high':
        return const Color(0xFFFF6348);
      case 'medium':
        return const Color(0xFFFFA502);
      case 'low':
        return const Color(0xFF7BED9F);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Visits',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _buildFilterChips(),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _filteredVisits.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildVisitCard(_filteredVisits[index]);
                    }, childCount: _filteredVisits.length),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'All',
      'Scheduled',
      'In Progress',
      'Completed',
      'Cancelled',
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _selectedFilter = filter);
            },
            backgroundColor: Colors.white,
            selectedColor: Color(0xFF203A43),
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF2C3E50),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF5B8DEF)
                    : Colors.grey.shade300,
              ),
            ),
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'All'
                ? 'No visits yet'
                : 'No $_selectedFilter visits',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter != 'All'
                ? 'Try selecting a different filter'
                : 'New visits will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit) {
    final priority = visit['priority'] ?? '';
    final status = visit['status'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: () => _navigateToVisitDetails(visit),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border(
                left: BorderSide(color: Color(0xFF203A43), width: 5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        visit['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          color: _getPriorityColor(priority),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        visit['customer'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        visit['site'] ?? '',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        visit['equipment'] ?? '',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: const Color(0xFF5B8DEF),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${visit['scheduled_date']} • ${visit['scheduled_time']}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
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
    );
  }

  void _navigateToVisitDetails(Map<String, dynamic> visit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenanceVisitDetail(visit: visit),
      ),
    );

    // Refresh list if status was changed
    if (result == true) {
      _fetchAssignedVisits();
    }
  }
}
