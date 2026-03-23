import 'package:flutter/material.dart';

class AddEquipmentDialog extends StatefulWidget {
  const AddEquipmentDialog({Key? key}) : super(key: key);

  @override
  State<AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<AddEquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _notesController = TextEditingController();

  IconData _selectedIcon = Icons.camera;

  // Common equipment icons
  final List<IconData> _equipmentIcons = [
    Icons.camera,
    Icons.camera_alt,
    Icons.camera_enhance,
    Icons.explore, // telescope
    Icons.biotech,
    Icons.filter_center_focus,
    Icons.photo_camera,
    Icons.photo_camera_back,
    Icons.photo_camera_front,
    Icons.videocam,
    Icons.flashlight_on,
    Icons.light_mode,
    Icons.nights_stay,
    Icons.wb_incandescent,
    Icons.laptop,
    Icons.phone_android,
    Icons.devices_other, // tripod/mount
    Icons.battery_charging_full,
    Icons.power,
    Icons.usb,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _equipmentIcons.length,
            itemBuilder: (context, index) {
              final icon = _equipmentIcons[index];
              final isSelected = icon == _selectedIcon;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'type': _typeController.text.trim(),
        'icon': _selectedIcon,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Equipment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon selector
              Row(
                children: [
                  const Text(
                    'Icon:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: _showIconPicker,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Icon(_selectedIcon, size: 32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Equipment name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Equipment Name *',
                  hintText: 'e.g., Canon EOS R6',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter equipment name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Equipment type
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  hintText: 'e.g., Camera, Telescope, Lens',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter equipment type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes (optional)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional details...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _handleSave, child: const Text('Add')),
      ],
    );
  }
}
