import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Depth of Field Calculator for Photography
/// Calculates near limit, far limit, and total depth of field
class DepthOfFieldCalculatorScreen extends StatefulWidget {
  const DepthOfFieldCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<DepthOfFieldCalculatorScreen> createState() =>
      _DepthOfFieldCalculatorScreenState();
}

class _DepthOfFieldCalculatorScreenState
    extends State<DepthOfFieldCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _focalLengthController = TextEditingController(text: '50');
  final _apertureController = TextEditingController(text: '2.8');
  final _subjectDistanceController = TextEditingController(text: '5');

  String _selectedSensorSize = 'Full Frame';
  final Map<String, double> _circleOfConfusion = {
    'Full Frame': 0.030, // 35mm
    'APS-C (Canon)': 0.019,
    'APS-C (Nikon)': 0.020,
    'APS-C (Sony)': 0.020,
    'Micro Four Thirds': 0.015,
    'Medium Format': 0.045,
    '1" Sensor': 0.011,
  };

  Map<String, dynamic>? _results;

  @override
  void dispose() {
    _focalLengthController.dispose();
    _apertureController.dispose();
    _subjectDistanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final focalLength = double.parse(_focalLengthController.text);
    final aperture = double.parse(_apertureController.text);
    final subjectDistance =
        double.parse(_subjectDistanceController.text) * 1000; // convert to mm
    final coc = _circleOfConfusion[_selectedSensorSize]!;

    // Hyperfocal Distance (H) = (f² / (N × c)) + f
    final hyperfocalDistance =
        (focalLength * focalLength) / (aperture * coc) + focalLength;

    // Near Limit = (H × s) / (H + s - f)
    double nearLimit =
        (hyperfocalDistance * subjectDistance) /
        (hyperfocalDistance + subjectDistance - focalLength);

    // Far Limit = (H × s) / (H - s + f)
    // If H < s, far limit is infinity
    double farLimit;
    bool isInfinity = false;

    if (hyperfocalDistance <= subjectDistance) {
      farLimit = double.infinity;
      isInfinity = true;
    } else {
      farLimit =
          (hyperfocalDistance * subjectDistance) /
          (hyperfocalDistance - subjectDistance + focalLength);
    }

    // Total Depth of Field
    final totalDoF = isInfinity ? double.infinity : (farLimit - nearLimit);

    setState(() {
      _results = {
        'hyperfocalDistance': hyperfocalDistance / 1000, // convert to meters
        'nearLimit': nearLimit / 1000, // convert to meters
        'farLimit': isInfinity ? null : farLimit / 1000, // convert to meters
        'isInfinity': isInfinity,
        'totalDoF': isInfinity ? null : totalDoF / 1000, // convert to meters
        'nearDoF': (subjectDistance - nearLimit) / 1000,
        'farDoF': isInfinity ? null : (farLimit - subjectDistance) / 1000,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'DEPTH OF FIELD',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About Depth of Field',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Depth of Field (DoF) is the distance between the nearest and farthest objects that appear acceptably sharp in your photo.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Calculator inputs section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sensor Size Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SENSOR SIZE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSensorSize,
                              isExpanded: true,
                              items: _circleOfConfusion.keys.map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedSensorSize = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Focal Length
                    _buildInputField(
                      label: 'FOCAL LENGTH',
                      controller: _focalLengthController,
                      hint: 'Enter focal length',
                      suffix: 'mm',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Aperture
                    _buildInputField(
                      label: 'APERTURE (F-NUMBER)',
                      controller: _apertureController,
                      hint: 'Enter f-number',
                      suffix: 'f/',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subject Distance
                    _buildInputField(
                      label: 'SUBJECT DISTANCE',
                      controller: _subjectDistanceController,
                      hint: 'Enter subject distance',
                      suffix: 'm',
                      helperText: 'Distance to your subject',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Calculate button
                    ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CALCULATE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Results section
              if (_results != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RESULT:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hyperfocal Distance
                      _buildResultRow(
                        'Hyperfocal Distance:',
                        '${_results!['hyperfocalDistance'].toStringAsFixed(2)} m',
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 12),

                      // Near Limit
                      _buildResultRow(
                        'Near Focus Limit:',
                        '${_results!['nearLimit'].toStringAsFixed(2)} m',
                      ),

                      const SizedBox(height: 8),

                      // Far Limit
                      _buildResultRow(
                        'Far Focus Limit:',
                        _results!['isInfinity']
                            ? 'Infinity (∞)'
                            : '${_results!['farLimit'].toStringAsFixed(2)} m',
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 12),

                      // Total DoF
                      _buildResultRow(
                        'Total Depth of Field:',
                        _results!['isInfinity']
                            ? 'Infinity (∞)'
                            : '${_results!['totalDoF'].toStringAsFixed(2)} m',
                        isHighlight: true,
                      ),

                      const SizedBox(height: 8),

                      // In front and behind subject
                      Text(
                        'In front of subject: ${_results!['nearDoF'].toStringAsFixed(2)} m',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _results!['isInfinity']
                            ? 'Behind subject: Infinity (∞)'
                            : 'Behind subject: ${_results!['farDoF'].toStringAsFixed(2)} m',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? suffix,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            errorStyle: const TextStyle(fontSize: 12),
          ),
          validator: validator,
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isHighlight ? Colors.white : Colors.grey[400],
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
