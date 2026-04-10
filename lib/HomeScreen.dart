import 'package:flutter/material.dart';
import 'package:grocery/DeveloperScreenPage.dart';
import 'package:grocery/EventForm.dart';
import 'package:grocery/design_system.dart';
import 'package:grocery/repositories/event_repository.dart';
import 'package:grocery/ExpenseList.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Future<List<dynamic>>? _futureEvents;
  bool _isViewAll = false;

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  void _refreshEvents() {
    setState(() {
      _futureEvents = EventRepository().fetchEventsByHostId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DesignSystem.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final events = snapshot.data ?? [];
          
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              if (!_isViewAll) ...[
                _buildSummaryStats(events),
                _buildEventListHeader(),
              ],
              if (_isViewAll)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("All Events", style: DesignSystem.titleLarge),
                        TextButton(
                          onPressed: () => setState(() => _isViewAll = false),
                          child: const Text("Show Less", style: TextStyle(color: DesignSystem.accent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              _buildEventList(events),
            ],
          );
        },
      ),
    ),
      floatingActionButton: FadeInUp(
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToCreateEvent(),
          backgroundColor: DesignSystem.primary,
          elevation: 8,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text("Add Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: DesignSystem.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        centerTitle: false,
        title: FadeInDown(child: const Text("Events", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white))),
        background: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(color: DesignSystem.accent, shape: BoxShape.circle),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 20,
              child: FadeInRight(
                delay: const Duration(milliseconds: 500),
                child: const Icon(Icons.show_chart_rounded, size: 100, color: Colors.white12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
          onPressed: () => Share.share('Check out Group Expense Manager!'),
        ),
        _buildPopupMenu(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.borderRadius),
      onSelected: (value) async {
        if (value == 'developer') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DeveloperScreenPage()));
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'developer', child: Text("Developer")),
      ],
    );
  }

  Widget _buildSummaryStats(List<dynamic> events) {
    int totalEvents = events.length;
    double totalPayout = events.fold(0.0, (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0.0));

    return SliverToBoxAdapter(
      child: FadeInDown(
        delay: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DesignSystem.cardBorderRadius,
              boxShadow: DesignSystem.softShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Total Events", totalEvents.toString(), Icons.event_available_rounded, Colors.blue),
                Container(width: 1, height: 40, color: DesignSystem.outline),
                _buildStatItem("Total Amount", "₹ ${NumberFormat("#,##,##0", "en_IN").format(totalPayout)}", Icons.payments_rounded, Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 24),
        const SizedBox(height: 12),
        Text(value, style: DesignSystem.displayMedium),
        const SizedBox(height: 4),
        Text(label, style: DesignSystem.labelMedium),
      ],
    );
  }

  Widget _buildEventListHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Events", style: DesignSystem.titleLarge),
            TextButton(
              onPressed: () => setState(() => _isViewAll = !_isViewAll), 
              child: Text(_isViewAll ? "Show Less" : "View All", style: TextStyle(color: DesignSystem.accent, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<dynamic> events) {
    if (events.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    } else {
      final filteredEvents = _isViewAll ? events : events.take(3).toList();
      
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final event = filteredEvents[index];
            return FadeInLeft(
              delay: Duration(milliseconds: 100 * (index % 10)),
              child: _buildEventCard(event),
            );
          },
          childCount: filteredEvents.length,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_rounded, size: 80, color: DesignSystem.outline),
          const SizedBox(height: 24),
          Text("No events found", style: DesignSystem.titleLarge),
          const SizedBox(height: 8),
          Text("Add your first event to start tracking expenses.", style: DesignSystem.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignSystem.borderRadius,
        boxShadow: DesignSystem.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExpenseList(eventName: event['eventName'], eventId: event['eventID'])),
            ).then((_) => _refreshEvents());
          },
          onDoubleTap: () => _showEventActions(event),
          borderRadius: DesignSystem.borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: DesignSystem.background, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: DesignSystem.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['eventName'] ?? 'Untitled', style: DesignSystem.titleLarge.copyWith(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(DateTime.tryParse(event['eventDate'] ?? '') ?? DateTime.now()),
                        style: DesignSystem.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${NumberFormat("#,##0", "en_IN").format(event['amount'] ?? 0)}',
                      style: DesignSystem.titleLarge.copyWith(color: DesignSystem.primary),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: DesignSystem.outline),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCreateEvent() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const EventForm())).then((value) {
      if (value == true) _refreshEvents();
    });
  }

  void _showEventActions(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 32), decoration: BoxDecoration(color: DesignSystem.outline, borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text("Edit Event"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => EventForm(map: event))).then((value) {
                  if (value == true) _refreshEvents();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: DesignSystem.tertiary),
              title: const Text("Delete Event", style: TextStyle(color: DesignSystem.tertiary)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event?"),
        content: const Text("Are you sure you want to delete this event? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await EventRepository().deleteEvent(event['eventID']);
              _refreshEvents();
            },
            child: const Text("Delete Event", style: TextStyle(color: DesignSystem.tertiary)),
          ),
        ],
      ),
    );
  }
}
