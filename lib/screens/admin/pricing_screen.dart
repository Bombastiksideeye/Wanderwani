import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for non-metal materials
  final TextEditingController _glassController = TextEditingController();
  final TextEditingController _plasticController = TextEditingController();
  final TextEditingController _electronicsController = TextEditingController();

  // Controllers for metal types
  final Map<String, TextEditingController> _metalControllers = {
    'Steel': TextEditingController(),
    'Iron': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentPrices();
  }

  @override
  void dispose() {
    _glassController.dispose();
    _plasticController.dispose();
    _electronicsController.dispose();
    for (var controller in _metalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCurrentPrices() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('pricing')
          .doc('current')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _glassController.text = (data['glass'] ?? 0).toString();
        _plasticController.text = (data['plastic'] ?? 0).toString();
        _electronicsController.text = (data['electronics'] ?? 0).toString();

        final metalPrices = data['metal'] as Map<String, dynamic>?;
        if (metalPrices != null) {
          metalPrices.forEach((key, value) {
            if (_metalControllers.containsKey(key)) {
              _metalControllers[key]!.text = value.toString();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading prices: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePrices() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> metalPrices = {};
      _metalControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          metalPrices[key] = double.parse(controller.text);
        }
      });

      await FirebaseFirestore.instance
          .collection('pricing')
          .doc('current')
          .set({
        'glass': double.parse(_glassController.text),
        'plastic': double.parse(_plasticController.text),
        'electronics': double.parse(_electronicsController.text),
        'metal': metalPrices,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prices updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving prices: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPriceField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText:
              '$label (points per ${label.toLowerCase() == 'glass' ? 'item' : 'kg'})',
          border: const OutlineInputBorder(),
          suffixText: 'points',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a price';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Set Material Prices',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Basic materials
                        _buildPriceField('Glass', _glassController),
                        _buildPriceField('Plastic', _plasticController),
                        _buildPriceField('Electronics', _electronicsController),

                        const SizedBox(height: 24),
                        const Text(
                          'Metal Prices by Type',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Metal types
                        ..._metalControllers.entries.map(
                          (entry) => _buildPriceField(entry.key, entry.value),
                        ),

                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF34A853),
                                Color(0xFF144221),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: _savePrices,
                            child: const Text(
                              'Save Prices',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
