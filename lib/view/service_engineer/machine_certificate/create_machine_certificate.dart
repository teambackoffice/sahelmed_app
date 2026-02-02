import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/modal/get_mv_modal.dart';
import 'package:sahelmed_app/providers/create_service_cert_provider.dart';

class CreateMachineCertificate extends StatefulWidget {
  final Visit? visitObject;
  const CreateMachineCertificate({super.key, this.visitObject});

  @override
  State<CreateMachineCertificate> createState() =>
      _CreateMachineCertificateState();
}

class _CreateMachineCertificateState extends State<CreateMachineCertificate> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _visitReferenceController = TextEditingController();

  File? _signatureImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _populateFieldsFromVisit();
  }

  void _populateFieldsFromVisit() {
    if (widget.visitObject != null) {
      _customerController.text = widget.visitObject!.customer;
      _visitReferenceController.text = widget.visitObject!.id;
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _visitReferenceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (image != null) {
        setState(() {
          _signatureImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add Signature',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildImageSourceOption(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Capture signature using camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _buildImageSourceOption(
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                subtitle: 'Select existing signature photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Error converting image to base64: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_signatureImage == null) {
      _showSnackBar('Please add signature', isError: true);
      return;
    }

    if (widget.visitObject == null) {
      _showSnackBar('Visit object is required', isError: true);
      return;
    }

    final controller = Provider.of<CreateMachineServiceCertificateController>(
      context,
      listen: false,
    );

    try {
      // Call API with File object directly
      await controller.generateCertificate(
        visitId: widget.visitObject!.id,
        customerImageFile: _signatureImage!,
      );

      if (!mounted) return;

      if (controller.errorMessage != null) {
        // ❌ ERROR - Show error and stay on page
        _showSnackBar(controller.errorMessage!, isError: true);
        // ❌ Do NOT pop - user stays on page to retry
      } else {
        // ✅ SUCCESS - Show success message and return true
        _showSnackBar('Machine Certificate created successfully!');

        // Wait a moment for the snackbar to show
        await Future.delayed(const Duration(milliseconds: 500));

        // ✅ CRITICAL: Return true to indicate successful creation
        if (mounted) {
          Navigator.pop(
            context,
            true,
          ); // <-- Changed from just pop() to pop(context, true)
        }
      }
    } catch (e) {
      // ❌ ERROR - Show error and stay on page
      if (mounted) {
        _showSnackBar('Error creating certificate: $e', isError: true);
        // ❌ Do NOT pop - user stays on page to retry
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateMachineServiceCertificateController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_sharp,
                color: Colors.white,
              ),
              onPressed: controller.isLoading
                  ? null
                  : () => Navigator.pop(context),
            ),
            backgroundColor: AppColors.darkNavy,
            title: const Text(
              'Create Machine Certificate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.splashGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'New Certificate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.visitObject != null
                                    ? 'Visit: ${widget.visitObject!.id}'
                                    : 'Fill in the details below',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form Fields Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Basic Information'),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _customerController,
                            label: 'Customer Name',
                            hint: 'Enter customer name',
                            icon: Icons.person_outline,
                            readOnly: widget.visitObject != null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _visitReferenceController,
                            label: 'Visit Reference',
                            hint: 'Enter visit reference number',
                            icon: Icons.numbers,
                            readOnly: widget.visitObject != null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter visit reference';
                              }
                              return null;
                            },
                          ),

                          // Show machines/items list if available
                          if (widget.visitObject != null &&
                              widget.visitObject!.purposes.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildSectionTitle('Machines & Equipment'),
                            const SizedBox(height: 16),
                            _buildMachinesList(),
                          ],

                          const SizedBox(height: 24),
                          _buildSectionTitle('Signature'),
                          const SizedBox(height: 16),

                          // Signature Section
                          InkWell(
                            onTap: controller.isLoading
                                ? null
                                : _showImageSourceDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _signatureImage == null
                                        ? Colors.grey[300]!
                                        : Theme.of(context).primaryColor,
                                    width: _signatureImage == null ? 1 : 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                ),
                                child: _signatureImage == null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Add Signature',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap to capture or select photo',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.file(
                                              _signatureImage!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                onPressed: controller.isLoading
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _signatureImage =
                                                              null;
                                                        });
                                                      },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkNavy,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: AppColors.darkNavy.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Create Certificate',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMachinesList() {
    return Column(
      children: widget.visitObject!.purposes.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == widget.visitObject!.purposes.length - 1;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.splashGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: AppColors.darkNavy, size: 24),
                ],
              ),
            ),
            if (!isLast) const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
      ),
    );
  }
}
