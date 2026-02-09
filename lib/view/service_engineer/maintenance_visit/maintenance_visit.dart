import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/modal/get_mv_modal.dart';
import 'package:sahelmed_app/providers/get_mv_provider.dart';
import 'package:sahelmed_app/view/service_engineer/maintenance_visit/visit_detail.dart';

class MaintenanceVisit extends StatefulWidget {
  const MaintenanceVisit({super.key});

  @override
  State<MaintenanceVisit> createState() => _MaintenanceVisitState();
}

class _MaintenanceVisitState extends State<MaintenanceVisit> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<GetMaintenanceRequestController>()
          .fetchMaintenanceRequests();
    });
  }

  List<Visit> _getFilteredVisits(List<Visit> visits) {
    if (_selectedFilter == 'All') return visits;

    return visits.where((v) {
      final status = v.customVisitStatus.toLowerCase();
      switch (_selectedFilter) {
        case 'Open':
          return status == 'open';
        case 'In Progress':
          return status == 'assigned' || status == 'in progress';
        case 'Completed':
          return status == 'completed';
        default:
          return true;
      }
    }).toList();
  }

  int _getFilterCount(List<Visit> visits, String filter) {
    if (filter == 'All') return visits.length;

    return visits.where((v) {
      final status = v.customVisitStatus.toLowerCase();
      switch (filter) {
        case 'Open':
          return status == 'open';
        case 'In Progress':
          return status == 'assigned' || status == 'in progress';
        case 'Completed':
          return status == 'completed';
        default:
          return true;
      }
    }).length;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF5B8DEF);
      case 'assigned':
      case 'in progress':
        return const Color(0xFFFF9F43);
      case 'completed':
        return const Color(0xFF26C281);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'assigned':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
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
      body: Consumer<GetMaintenanceRequestController>(
        builder: (context, controller, child) {
          final filteredVisits = _getFilteredVisits(controller.visits);

          return CustomScrollView(
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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF2C3E50)),
                    onPressed: () => controller.fetchMaintenanceRequests(),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: _buildFilterChips(controller.visits),
                ),
              ),
              if (controller.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.errorMessage != null)
                SliverFillRemaining(child: _buildErrorState(controller))
              else if (filteredVisits.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildVisitCard(filteredVisits[index]);
                    }, childCount: filteredVisits.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(List<Visit> visits) {
    final filters = ['All', 'Open', 'In Progress', 'Completed'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          final count = _getFilterCount(visits, filter);

          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(filter),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : const Color(0xFF5B8DEF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF5B8DEF),
                    ),
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _selectedFilter = filter);
            },
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF203A43),
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

  Widget _buildErrorState(GetMaintenanceRequestController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Error Loading Visits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.fetchMaintenanceRequests(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF203A43),
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

  Widget _buildVisitCard(Visit visit) {
    final firstPurpose = visit.purposes.isNotEmpty
        ? visit.purposes.first
        : null;
    final equipment = firstPurpose?.itemName ?? 'N/A';

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
              border: const Border(
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
                        visit.id,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
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
                        visit.customerName,
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
                if (visit.customerAddress != null) ...[
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
                          visit.customerAddress.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
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
                        equipment,
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
                      const Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: Color(0xFF5B8DEF),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_formatDate(visit.mntcDate)} • ${_formatTime(visit.mntcTime)}',
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
                          color: _getStatusColor(visit.customVisitStatus),
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
                              _getStatusText(visit.customVisitStatus),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(String time) {
    try {
      // Extract HH:MM from time string
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  void _navigateToVisitDetails(Visit visit) async {
    final visitMap = {
      'name': visit.id,
      'customer': visit.customerName,
      'customer_contact': '',
      'customer_email': '',
      'site': visit.customerAddress?.toString() ?? 'N/A',
      'site_address': visit.customerAddress?.toString() ?? 'N/A',
      'scheduled_date': _formatDate(visit.mntcDate),
      'scheduled_time': _formatTime(visit.mntcTime),
      'status': _getStatusText(visit.customVisitStatus),
      'priority': 'Medium',
      'maintenance_type': 'Maintenance',
      'equipment': visit.purposes.isNotEmpty
          ? visit.purposes.first.itemName
          : 'N/A',
      'equipment_model': '',
      'equipment_serial': visit.purposes.isNotEmpty
          ? visit.purposes.first.serialNo ?? ''
          : '',
      'description': visit.purposes.isNotEmpty
          ? visit.purposes.first.description
          : '',
      'notes': visit.purposes.isNotEmpty ? visit.purposes.first.workDone : '',
      'assigned_to': visit.assignedEngineer ?? '',
      'estimated_duration': '',
      'checklist': [],
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenanceVisitDetail(
          visit: visitMap,
          visitObject: visit, // Pass the full Visit object
        ),
      ),
    );

    if (result == true) {
      context
          .read<GetMaintenanceRequestController>()
          .fetchMaintenanceRequests();
    }
  }
}
