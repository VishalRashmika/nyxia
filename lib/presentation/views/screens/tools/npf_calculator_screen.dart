import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// NPF Rule Calculator for Astrophotography
/// Calculates maximum exposure time before star trailing
class NPFCalculatorScreen extends StatefulWidget {
  const NPFCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<NPFCalculatorScreen> createState() => _NPFCalculatorScreenState();
}

class _NPFCalculatorScreenState extends State<NPFCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _focalLengthController = TextEditingController(text: '50');
  final _apertureController = TextEditingController(text: '2.8');
  final _pixelPitchController = TextEditingController(text: '4.3');
  final _declinationController = TextEditingController(text: '0');

  double? _maxExposureTime;
  String? _recommendation;

  @override
  void dispose() {
    _focalLengthController.dispose();
    _apertureController.dispose();
    _pixelPitchController.dispose();
    _declinationController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final focalLength = double.parse(_focalLengthController.text);
    final aperture = double.parse(_apertureController.text);
    final pixelPitch = double.parse(_pixelPitchController.text);
    final declination = double.parse(_declinationController.text);

    // NPF Rule Formula:
    // Exposure Time = (35 × Aperture + 30 × Pixel Pitch) / (Focal Length × cos(Declination))
    final declinationRad = declination * (math.pi / 180);
    final cosDeclination = math.cos(declinationRad);

    final numerator = (35 * aperture) + (30 * pixelPitch);
    final denominator = focalLength * cosDeclination;

    final exposureTime = numerator / denominator;

    setState(() {
      _maxExposureTime = exposureTime;
      _recommendation = _getRecommendation(exposureTime);
    });
  }

  String _getRecommendation(double exposureTime) {
    if (exposureTime < 5) {
      return 'Very short exposure. Consider using a star tracker or wider aperture.';
    } else if (exposureTime < 15) {
      return 'Good for handheld or tripod shots. Stack multiple exposures for better results.';
    } else if (exposureTime < 30) {
      return 'Excellent exposure time. Perfect for Milky Way photography.';
    } else {
      return 'Long exposure possible. Great for deep sky objects. Use a sturdy tripod.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'NPF CALCULATOR',
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
                          'About NPF Rule',
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
                      'The NPF rule calculates the maximum exposure time for astrophotography before stars begin to trail. It accounts for focal length, aperture, pixel size, and declination.',
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

                    // Aperture (f-number)
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

                    // Pixel Pitch
                    _buildInputField(
                      label: 'PIXEL PITCH',
                      controller: _pixelPitchController,
                      hint: 'Enter pixel pitch',
                      suffix: 'μm',
                      helperText: 'Typical: 4-6μm. Check camera specs.',
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

                    // Declination
                    _buildInputField(
                      label: 'DECLINATION',
                      controller: _declinationController,
                      hint: 'Enter declination',
                      suffix: '°',
                      helperText: '0° = equator, ±90° = poles',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num < -90 || num > 90) {
                          return '-90° to 90°';
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
              if (_maxExposureTime != null) ...[
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
                      Text(
                        'Max Exposure: ${_maxExposureTime!.toStringAsFixed(1)} seconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        _recommendation!,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          height: 1.5,
                        ),
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
            FilteringTextInputFormatter.allow(RegExp(r'^\-?\d*\.?\d*')),
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
}
