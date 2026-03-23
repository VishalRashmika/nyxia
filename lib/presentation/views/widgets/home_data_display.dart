import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';

/// sample widget for home data display
class HomeDataDisplay extends StatefulWidget {
  const HomeDataDisplay({super.key});

  @override
  State<HomeDataDisplay> createState() => _HomeDataDisplayState();
}

class _HomeDataDisplayState extends State<HomeDataDisplay> {
  @override
  void initState() {
    super.initState();
    // load data on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().refreshHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${viewModel.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.refreshHomeData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.refreshHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // location section
                _buildSection(
                  title: 'Location',
                  icon: Icons.location_on,
                  children: [
                    _buildDataRow('City', viewModel.location.city ?? 'Unknown'),
                    _buildDataRow(
                      'Country',
                      viewModel.location.country ?? 'Unknown',
                    ),
                    _buildDataRow(
                      'Coordinates',
                      viewModel.location.coordinates,
                    ),
                    _buildDataRow('Elevation', viewModel.elevationString),
                  ],
                ),

                const SizedBox(height: 24),

                // weather section
                _buildSection(
                  title: 'Weather',
                  icon: Icons.wb_sunny,
                  children: [
                    _buildDataRow(
                      'Temperature',
                      viewModel.weather.temperatureString,
                    ),
                    _buildDataRow('Humidity', viewModel.weather.humidityString),
                    _buildDataRow(
                      'Cloud Cover',
                      viewModel.weather.cloudCoverString,
                    ),
                    _buildDataRow('Conditions', viewModel.weather.description),
                  ],
                ),

                const SizedBox(height: 24),

                // light pollution section
                _buildSection(
                  title: 'Light Pollution',
                  icon: Icons.light_mode,
                  children: [
                    _buildDataRow(
                      'Bortle Scale',
                      viewModel.lightPollution.bortleString,
                    ),
                    _buildDataRow(
                      'Description',
                      viewModel.lightPollution.description,
                    ),
                    _buildDataRow('SQM', viewModel.lightPollution.sqmString),
                  ],
                ),

                const SizedBox(height: 24),

                // last updated
                Center(
                  child: Text(
                    'Last updated: ${viewModel.lastUpdatedString}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),

                const SizedBox(height: 16),

                // manual refresh button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => viewModel.refreshHomeData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Data'),
                  ),
                ),

                const SizedBox(height: 16),

                // manual coordinates input
                Center(
                  child: TextButton(
                    onPressed: () => _showManualCoordinatesDialog(context),
                    child: const Text('Use Manual Coordinates'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showManualCoordinatesDialog(BuildContext context) {
    final latController = TextEditingController();
    final lonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Coordinates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., 40.7128',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lonController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., -74.0060',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lon = double.tryParse(lonController.text);

              if (lat != null && lon != null) {
                Navigator.pop(context);
                context.read<HomeViewModel>().refreshHomeDataWithCoordinates(
                  lat,
                  lon,
                );
              }
            },
            child: const Text('Fetch Data'),
          ),
        ],
      ),
    );
  }
}
