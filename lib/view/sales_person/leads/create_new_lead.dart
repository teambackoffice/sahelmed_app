import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/providers/create_lead_provider.dart';
import 'package:sahelmed_app/providers/get_leads_provider.dart';

class CreateNewLead extends StatefulWidget {
  const CreateNewLead({super.key});

  @override
  State<CreateNewLead> createState() => _CreateNewLeadState();
}

class _CreateNewLeadState extends State<CreateNewLead> {
  // 1. Keys and Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  // 2. Variable for the dropdown source
  String? _selectedSource;
  final List<String> _sourceOptions = [
    'Walk In',
    'Campaign',
    'Customer\'s Vendor',
    'Mass Mailing',
    'Supplier Reference',
    'Exhibition',
    'Cold Calling',
    'Advertisement',
    'Reference',
    'Existing Customer',
    'Other',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _orgNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  // 3. Method to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CreateLeadProvider>(context, listen: false);

      await provider.createLead(
        leadName: _firstNameController.text.trim(),
        companyName: _orgNameController.text.trim(),
        email: _emailController.text.trim(),
        mobileNo: _mobileController.text.trim(),
        source: _selectedSource!,
      );

      if (!mounted) return;

      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lead Created Successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form after successful submission
        _firstNameController.clear();
        _orgNameController.clear();
        _emailController.clear();
        _mobileController.clear();
        setState(() {
          _selectedSource = null;
        });

        // Navigate back after successful submission
        Navigator.pop(context);
        context.read<LeadController>().getLeads();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text(
          'Create New Lead',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Consumer<CreateLeadProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- First Name ---
                      _buildLabel('First Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDecoration('Enter first name'),
                        enabled: !provider.isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- Organization Name ---
                      _buildLabel('Organization Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _orgNameController,
                        decoration: _inputDecoration('Enter organization name'),
                        enabled: !provider.isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an organization';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- Email ---
                      _buildLabel('Email'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration('Enter email address'),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !provider.isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          // Basic email validation
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- Mobile Number ---
                      _buildLabel('Mobile Number'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _mobileController,
                        decoration: _inputDecoration('Enter mobile number')
                            .copyWith(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12.0,
                                  right: 8.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      '+971',
                                      style: TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                            ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        enabled: !provider.isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a mobile number';
                          }
                          if (value.length != 9) {
                            return 'Please enter 9 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- Source (Dropdown) ---
                      _buildLabel('Source'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSource,
                        decoration: _inputDecoration('Select source'),
                        items: _sourceOptions.map((String source) {
                          return DropdownMenuItem<String>(
                            value: source,
                            child: Text(source),
                          );
                        }).toList(),
                        onChanged: provider.isLoading
                            ? null
                            : (String? newValue) {
                                setState(() {
                                  _selectedSource = newValue;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a source';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      // --- Submit Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4ED8),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Create Lead',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper widget for input styling
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  // Helper widget for labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
  }
}
