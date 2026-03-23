import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../viewmodels/tabs/home_tab_viewmodel.dart';
import '../../../viewmodels/tabs/plan_tab_viewmodel.dart';
import '../../../viewmodels/tabs/track_tab_viewmodel.dart';
import '../../../viewmodels/tabs/you_tab_viewmodel.dart';
// import '../tools/npf_calculator_screen.dart';
import '../tools/npf_calculator_screen.dart';
import '../tools/depth_of_field_calculator_screen.dart';
import '../tools/my_equipment_screen.dart';
import '../tools/space_pictures_screen.dart';
import '../welcome/welcome_screen.dart';
import '../../themes/theme_provider.dart';
import '../../../widgets/add_event_dialog.dart';
import '../../../../data/models/user_event.dart';
import 'package:table_calendar/table_calendar.dart';

// ============================================================================
// HOME SCREEN - Main container with bottom navigation (MVVM)
// ============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = const [
    HomeTab(),
    PlanTab(),
    TrackTab(),
    ToolsTab(),
    YouTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          body: _screens[viewModel.selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: viewModel.selectedIndex,
            onTap: viewModel.onTabChanged,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'PLAN',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.track_changes),
                label: 'TRACK',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.build), label: 'TOOLS'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'YOU'),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// HOME TAB - Main Dashboard (MVVM)
// ============================================================================
class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Fetch data from APIs when the tab loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<HomeTabViewModel>();
      if (viewModel.hasLoadedOnce) return;

      try {
        await viewModel.refreshData();
      } catch (error, stackTrace) {
        if (!mounted) return;
        viewModel.handleUnexpectedError(error, stackTrace);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<HomeTabViewModel>(
          builder: (context, viewModel, _) {
            // Show error state if there's an error
            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading data',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.refreshData(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with logo and greeting
                    Row(
                      children: [
                        Image.asset(
                          'assets/logos/round-logo.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                viewModel.greetingMessage,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Ready to capture the stars?',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Location Card
                    _buildInfoCard(
                      context,
                      title: 'CURRENT LOCATION',
                      children: [
                        _buildInfoRow(
                          Icons.location_on,
                          'Location',
                          viewModel.locationName,
                        ),
                        _buildInfoRow(
                          Icons.map,
                          'Coordinates',
                          viewModel.coordinates,
                        ),
                        _buildInfoRow(
                          Icons.terrain,
                          'Elevation',
                          viewModel.elevation,
                        ),
                        _buildInfoRow(
                          Icons.access_time,
                          'Local Time',
                          viewModel.localTime,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Weather Conditions Section
                    Text(
                      'WEATHER CONDITIONS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Weather Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      padding: EdgeInsets.zero,
                      children: [
                        _buildWeatherCard(
                          context,
                          icon: Icons.cloud,
                          label: 'Cloud Cover',
                          value: '${viewModel.cloudCover}%',
                        ),
                        _buildWeatherCard(
                          context,
                          icon: Icons.thermostat,
                          label: 'Temperature',
                          value: '${viewModel.temperature}°C',
                        ),
                        _buildWeatherCard(
                          context,
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: '${viewModel.humidity}%',
                        ),
                        _buildWeatherCard(
                          context,
                          icon: Icons.lightbulb_outline,
                          label: 'Light Pollution',
                          value: viewModel.lightPollution,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Visibility Status
                    _buildVisibilityStatusCard(context, viewModel),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityStatusCard(
    BuildContext context,
    HomeTabViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final accent = viewModel.visibilityColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.16), accent.withOpacity(0.06)],
        ),
        border: Border.all(color: accent.withOpacity(0.28), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.visibility_rounded, color: accent, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Visibility Status',
                  style: theme.textTheme.bodySmall?.copyWith(
                    letterSpacing: 0.4,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  viewModel.visibilityStatus,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PLAN TAB - Calendar & Events (MVVM)
// ============================================================================
class PlanTab extends StatefulWidget {
  const PlanTab({Key? key}) : super(key: key);

  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<PlanTabViewModel>().selectTab(_tabController.index);
        setState(() {}); // Rebuild to show/hide FAB
      }
    });

    // Start listeners and fetch only if data wasn't preloaded already.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<PlanTabViewModel>();
      viewModel.startListeningToUserEvents();
      if (!viewModel.hasLoadedOnce) {
        viewModel.fetchEvents();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<PlanTabViewModel>(
          builder: (context, viewModel, _) {
            // show loading overlay when fetching events
            if (viewModel.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading astronomical events...'),
                  ],
                ),
              );
            }

            // show error state if fetch fails
            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading events',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => viewModel.refreshEvents(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header with title
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        'PLAN',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? theme.colorScheme.surface
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[700],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                    tabs: const [
                      Tab(text: 'EVENTS'),
                      Tab(text: 'MY EVENTS'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Calendar and Events - Height-aware split to avoid bottom overflow
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxHeight < 360;

                      return Column(
                        children: [
                          // Calendar
                          Flexible(
                            flex: compact ? 5 : 6,
                            child: SingleChildScrollView(
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TableCalendar(
                                    firstDay: DateTime.utc(2020, 1, 1),
                                    lastDay: DateTime.utc(2030, 12, 31),
                                    focusedDay: viewModel.focusedDay,
                                    selectedDayPredicate: (day) =>
                                        isSameDay(viewModel.selectedDay, day),
                                    eventLoader: (day) {
                                      return viewModel.getEventsForDay(day);
                                    },
                                    calendarFormat: CalendarFormat.month,
                                    startingDayOfWeek: StartingDayOfWeek.monday,
                                    headerStyle: HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      titleTextStyle: theme
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      leftChevronIcon: Icon(
                                        Icons.chevron_left,
                                        color: theme.colorScheme.primary,
                                      ),
                                      rightChevronIcon: Icon(
                                        Icons.chevron_right,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      outsideDaysVisible: false,
                                      selectedDecoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      todayDecoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      markerDecoration: BoxDecoration(
                                        color: theme.colorScheme.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    rowHeight: compact ? 38 : 46,
                                    daysOfWeekHeight: compact ? 16 : 20,
                                    onDaySelected: (selectedDay, focusedDay) {
                                      viewModel.onDaySelected(
                                        selectedDay,
                                        focusedDay,
                                      );
                                    },
                                    onPageChanged: (focusedDay) {
                                      viewModel.onPageChanged(focusedDay);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tab View Content
                          Flexible(
                            flex: compact ? 6 : 5,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // All Events List
                                _buildAllEventsList(
                                  context,
                                  viewModel.allEvents,
                                ),

                                // My Events List
                                _buildMyEventsList(context, viewModel),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                final viewModel = context.read<PlanTabViewModel>();
                _showAddEventDialog(viewModel);
              },
              icon: const Icon(Icons.add),
              label: const Text('ADD EVENT'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  // Build All Events List (Astronomical Events)
  Widget _buildAllEventsList(BuildContext context, List<EventModel> events) {
    final theme = Theme.of(context);
    final viewModel = context.read<PlanTabViewModel>();

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshEvents(),
      child: events.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events for selected date',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      event.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event.date,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (event.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                event.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getProbabilityColor(
                          event.probability,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.probability,
                        style: TextStyle(
                          color: _getProbabilityColor(event.probability),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Build My Events List (User Events)
  Widget _buildMyEventsList(BuildContext context, PlanTabViewModel viewModel) {
    final theme = Theme.of(context);
    final events = viewModel.myEvents;

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshEvents(),
      child: events.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                const SizedBox(height: 12),
                const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'No events planned',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap the + button to add your first event',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        event.icon,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      event.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'MMM dd, yyyy - h:mm a',
                                  ).format(event.dateTime),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (event.location != null &&
                              event.location!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (event.description != null &&
                              event.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                event.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _handleDeleteEvent(event, viewModel),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Show Add Event Dialog
  Future<void> _showAddEventDialog(PlanTabViewModel viewModel) async {
    final result = await showDialog<UserEvent>(
      context: context,
      builder: (context) => AddEventDialog(initialDate: viewModel.selectedDay),
    );

    if (result != null && mounted) {
      try {
        await viewModel.addUserEvent(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event added successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add event: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Handle Delete Event with Undo
  void _handleDeleteEvent(UserEvent event, PlanTabViewModel viewModel) async {
    // Store event data for undo
    final deletedEvent = event;

    // Delete the event
    try {
      await viewModel.deleteUserEvent(event);

      if (mounted) {
        // Show snackbar with undo option
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Event deleted'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: () async {
                // Restore the event
                try {
                  await viewModel.restoreUserEvent(deletedEvent);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event restored'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to restore event: $e'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete event: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEventsList(
    BuildContext context,
    List<EventModel> events, {
    required bool showAddButton,
    VoidCallback? onAddEvent,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No events planned',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            event.icon,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          event.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.date,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              if (event.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    event.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getProbabilityColor(
                              event.probability,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.probability,
                            style: TextStyle(
                              color: _getProbabilityColor(event.probability),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Add Event Button (only for My Events tab)
        if (showAddButton)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (onAddEvent != null) {
                    onAddEvent();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add event functionality coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'ADD EVENT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getVisibilityColor(String visibility) {
    final percentage = int.parse(visibility.replaceAll('%', ''));
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }

  Color _getProbabilityColor(String probability) {
    // Handle different probability formats
    if (probability == '100%') return Colors.green;
    if (probability == 'Safe') return Colors.green;
    if (probability == 'Monitor') return Colors.orange;

    // Try to parse percentage
    try {
      final numericValue = probability.replaceAll(RegExp(r'[^0-9]'), '');
      if (numericValue.isNotEmpty) {
        final percentage = int.parse(numericValue);
        if (percentage >= 90) return Colors.green;
        if (percentage >= 75) return Colors.lightGreen;
        if (percentage >= 60) return Colors.orange;
        return Colors.red;
      }
    } catch (e) {
      // If parsing fails, use default
    }

    return Colors.blue; // Default for non-percentage values
  }
}

// ============================================================================
// TRACK TAB - Moon/Aurora Tracking (MVVM)
// ============================================================================
class TrackTab extends StatefulWidget {
  const TrackTab({Key? key}) : super(key: key);

  @override
  State<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends State<TrackTab> {
  @override
  void initState() {
    super.initState();
    // Load tracking data when tab opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<TrackTabViewModel>();
      if (!viewModel.hasLoadedOnce) {
        viewModel.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<TrackTabViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.refreshAllData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Refresh Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TRACK',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          onPressed: () => viewModel.refreshAllData(),
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh tracking data',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Moon Phase Tracker Section
                    _buildSectionCard(
                      context,
                      title: 'MOON PHASE',
                      icon: Icons.nightlight,
                      child: Column(
                        children: [
                          // Moon Phase Visual
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.2),
                                  theme.colorScheme.primary.withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                viewModel.moonPhaseIcon,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            viewModel.moonPhaseName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${viewModel.moonIllumination}% Illuminated',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMoonDetail(
                                context,
                                label: 'Moonrise',
                                value: viewModel.moonrise,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              _buildMoonDetail(
                                context,
                                label: 'Moonset',
                                value: viewModel.moonset,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Aurora Tracker Section
                    _buildSectionCard(
                      context,
                      title: 'AURORA TRACKER',
                      icon: Icons.wb_twilight,
                      child: Column(
                        children: [
                          // KP index display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  viewModel.auroraColor.withOpacity(0.18),
                                  viewModel.auroraColor.withOpacity(0.07),
                                ],
                              ),
                              border: Border.all(
                                color: viewModel.auroraColor.withOpacity(0.35),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KP INDEX',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.75),
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      '${viewModel.kpIndex}',
                                      style: theme.textTheme.displayLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: viewModel.auroraColor,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: viewModel.auroraColor
                                            .withOpacity(0.16),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        viewModel.auroraActivity.toUpperCase(),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: viewModel.auroraColor,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.dividerColor.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Aurora Probability',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        viewModel.auroraProbability,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.dividerColor.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Best Viewing Time',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        viewModel.auroraViewingTime,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              height: 1.25,
                                            ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: viewModel.auroraColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: viewModel.auroraColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: viewModel.auroraColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    viewModel.auroraDescription.isNotEmpty
                                        ? viewModel.auroraDescription
                                        : viewModel.auroraInfo,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMoonDetail(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ============================================================================
// TOOLS TAB - Utility Tools Navigation (Stateless, no ViewModel needed)
// ============================================================================
class ToolsTab extends StatelessWidget {
  const ToolsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'TOOLS',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Tools Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  _buildToolCard(
                    context,
                    title: 'NPF CALCULATOR',
                    icon: Icons.calculate,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NPFCalculatorScreen(),
                        ),
                      );
                    },
                  ),
                  _buildToolCard(
                    context,
                    title: 'DEPTH OF FIELD',
                    icon: Icons.camera_alt,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DepthOfFieldCalculatorScreen(),
                        ),
                      );
                    },
                  ),
                  _buildToolCard(
                    context,
                    title: 'EQUIPMENT & GEAR',
                    icon: Icons.camera,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyEquipmentScreen(),
                        ),
                      );
                    },
                  ),
                  _buildToolCard(
                    context,
                    title: 'SPACE PICTURES',
                    icon: Icons.photo_library,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SpacePicturesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Icon(icon, size: 36, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// YOU TAB - Profile & Settings (MVVM)
// ============================================================================
class YouTab extends StatelessWidget {
  const YouTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<YouTabViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Avatar
                  viewModel.hasProfilePhoto
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            viewModel.userPhotoUrl!,
                          ),
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.1),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.3),
                                theme.colorScheme.primary.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: theme.colorScheme.primary,
                          ),
                        ),

                  const SizedBox(height: 16),

                  // User Info
                  Text(
                    viewModel.userName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.userEmail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Preferences Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PREFERENCES',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Preferences Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return ListTile(
                              leading: Icon(
                                Icons.palette,
                                color: theme.colorScheme.primary,
                              ),
                              title: const Text(
                                'Theme',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                viewModel.getThemeName(
                                  themeProvider.themeMode
                                      .toString()
                                      .split('.')
                                      .last,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                _showThemeSelector(context, themeProvider);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ABOUT',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // About Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.info,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text(
                            'About Nyxia',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text('Version 1.0.0'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Nyxia',
                              applicationVersion: '1.0.0',
                              applicationIcon: Icon(
                                Icons.nights_stay,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                              children: const [
                                Text(
                                  'Your ultimate companion for planning and capturing the perfect astrophotography moments.',
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await _showLogoutDialog(context);
                        if (confirm == true && context.mounted) {
                          await viewModel.logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomeScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                'Light',
                'Bright and vibrant',
                Icons.light_mode,
                AppThemeMode.light,
                themeProvider,
              ),
              _buildThemeOption(
                context,
                'Dark',
                'Easy on the eyes',
                Icons.dark_mode,
                AppThemeMode.dark,
                themeProvider,
              ),
              _buildThemeOption(
                context,
                'Night',
                'Red-shifted for night vision',
                Icons.nightlight_round,
                AppThemeMode.night,
                themeProvider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    AppThemeMode mode,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        themeProvider.setTheme(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
