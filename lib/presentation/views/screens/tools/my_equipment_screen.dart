import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/equipment_viewmodel.dart';
import '../../../widgets/add_equipment_dialog.dart';

class MyEquipmentScreen extends StatefulWidget {
  const MyEquipmentScreen({Key? key}) : super(key: key);

  @override
  State<MyEquipmentScreen> createState() => _MyEquipmentScreenState();
}

class _MyEquipmentScreenState extends State<MyEquipmentScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to equipment changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EquipmentViewModel>().startListeningToEquipment();
    });
  }

  @override
  void dispose() {
    // Stop listening when screen is disposed
    context.read<EquipmentViewModel>().stopListeningToEquipment();
    super.dispose();
  }

  Future<void> _showAddEquipmentDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddEquipmentDialog(),
    );

    if (result != null && mounted) {
      try {
        await context.read<EquipmentViewModel>().addEquipment(
          name: result['name'] as String,
          type: result['type'] as String,
          icon: result['icon'] as IconData,
          notes: result['notes'] as String?,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result['name']} added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add equipment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteEquipment(equipment) async {
    try {
      await context.read<EquipmentViewModel>().deleteEquipment(equipment);

      if (mounted) {
        // Show snackbar with undo option
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text('${equipment.name} deleted'),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    context.read<EquipmentViewModel>().undoDelete();
                  },
                ),
              ),
            )
            .closed
            .then((reason) {
              // Clear recently deleted after snackbar closes
              if (reason != SnackBarClosedReason.action) {
                context.read<EquipmentViewModel>().clearRecentlyDeleted();
              }
            });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete equipment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'MY EQUIPMENTS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<EquipmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.error!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refreshEquipment(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!viewModel.hasEquipment) {
            return RefreshIndicator(
              onRefresh: () => viewModel.refreshEquipment(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Equipment Yet',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your astronomical equipment\nto keep track of your gear',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refreshEquipment(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.equipment.length,
              itemBuilder: (context, index) {
                final equipment = viewModel.equipment[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        equipment.icon,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      equipment.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      equipment.type,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () => _handleDeleteEquipment(equipment),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _showAddEquipmentDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, size: 24),
                SizedBox(width: 8),
                Text(
                  'ADD EQUIPMENT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
