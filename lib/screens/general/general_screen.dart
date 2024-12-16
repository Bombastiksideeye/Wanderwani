import 'package:ecoearn/screens/general/general_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';

class GeneralScreen extends StatefulWidget {
  final String materialType;

  const GeneralScreen({
    super.key,
    required this.materialType,
  });

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _selectedMetalType;
  File? _image;
  bool _isLoading = false;

  final List<String> _metalTypes = [
    'Steel',
    'Iron',
  ];

  Future<void> _uploadImage() async {
    final picker = ImagePicker();

    // Show dialog to choose between gallery and camera
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> _submitRecycling() async {
    // Validate based on material type
    if (widget.materialType.toLowerCase() == 'glass') {
      // Glass validation - only quantity required
      if (_quantityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in the quantity')),
        );
        return;
      }
    } else {
      // Non-glass validation - only weight required
      if (_weightController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in the weight')),
        );
        return;
      }
    }

    // Metal-specific validation
    if (widget.materialType.toLowerCase() == 'metal' &&
        _selectedMetalType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a metal type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final timestamp = DateTime.now();

      // Initialize data map with common fields
      Map<String, dynamic> recyclingData = {
        'userId': user!.uid,
        'userName': user.displayName,
        'materialType': widget.materialType.toLowerCase(),
        'status': 'pending',
        'timestamp': timestamp,
      };

      // Add material-specific fields
      if (widget.materialType.toLowerCase() == 'glass') {
        recyclingData['quantity'] = int.parse(_quantityController.text);
      } else {
        recyclingData['weight'] = double.parse(_weightController.text);
      }

      // Add metal type for metal materials
      if (widget.materialType.toLowerCase() == 'metal') {
        recyclingData['metalType'] = _selectedMetalType;
      }

      // Add image if provided
      if (_image != null) {
        recyclingData['imageData'] = await _imageToBase64(_image!);
      }

      // Create recycling record in Firestore
      await FirebaseFirestore.instance
          .collection('recycling_requests')
          .add(recyclingData);

      // Update user's recycling stats
      if (widget.materialType.toLowerCase() == 'glass') {
        final quantity = int.parse(_quantityController.text);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'totalItems': FieldValue.increment(quantity),
          'lastUpdated': timestamp,
        }, SetOptions(merge: true));
      }

      // Update material-specific stats
      if (widget.materialType.toLowerCase() != 'glass') {
        final weight = double.parse(_weightController.text);
        await FirebaseFirestore.instance
            .collection('recycling_stats')
            .doc(user.uid)
            .set({
          '${widget.materialType.toLowerCase()}_weight_month':
              FieldValue.increment(weight),
          '${widget.materialType.toLowerCase()}_weight_total':
              FieldValue.increment(weight),
        }, SetOptions(merge: true));
      } else {
        // For glass, update items count
        final quantity = int.parse(_quantityController.text);
        await FirebaseFirestore.instance
            .collection('recycling_stats')
            .doc(user.uid)
            .set({
          'glass_items_month': FieldValue.increment(quantity),
          'glass_items_total': FieldValue.increment(quantity),
        }, SetOptions(merge: true));
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recycling submitted successfully')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  final _controller = Get.put(GeneralController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF009951),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 90),
                  const Center(
                    child: Text(
                      'General',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Material Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: widget.materialType,
                  suffixIcon: Container(
                    margin: const EdgeInsets.only(top: 5, right: 15),
                    child: Obx(() {
                      _controller.fetchPricing();
                      return Text(
                          'Points\n ${widget.materialType != 'Metal' ? _controller.pricing[widget.materialType.toLowerCase()] : _controller.pricing[widget.materialType.toLowerCase()][_selectedMetalType] ?? 'Select Option'}');
                    }),
                  ),
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              if (widget.materialType.toLowerCase() == 'metal') ...[
                const SizedBox(height: 16),
                const Text(
                  'Metal Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedMetalType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: const Text('Select metal type'),
                  items: _metalTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMetalType = newValue;
                    });
                  },
                ),
              ],
              const SizedBox(height: 16),
              widget.materialType.toLowerCase() != 'glass'
                  ? const SizedBox.shrink()
                  : const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              widget.materialType.toLowerCase() != 'glass'
                  ? const SizedBox.shrink()
                  : TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      keyboardType: TextInputType.number,
                    ),
              if (widget.materialType.toLowerCase() != 'glass') ...[
                const Text(
                  'Weight (kg)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _uploadImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : const Column(
                          children: [
                            SizedBox(
                              height: 60,
                            ),
                            Icon(
                              Icons.add_circle_outline_sharp,
                              color: Color(0xFF009951),
                              size: 50,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                'Click to Upload Photo',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 111, 114, 112),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF009951),
                  borderRadius:
                      BorderRadius.circular(8), // Optional: for rounded corners
                ),
                child: InkWell(
                  onTap: _isLoading ? null : _submitRecycling,
                  borderRadius:
                      BorderRadius.circular(8), // Optional: for rounded corners
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: double.infinity, // To take up the full width
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          8), // Ensures rounded corners for the child
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
