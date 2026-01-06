import 'package:flutter/material.dart';

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

  // 2. Variable for the dropdown source
  String? _selectedSource;
  final List<String> _sourceOptions = [
    'LinkedIn',
    'Website',
    'Referral',
    'Cold Call',
    'Advertisement',
    'Other',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _orgNameController.dispose();
    super.dispose();
  }

  // 3. Method to handle form submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Call your API or Provider here
      print("Name: ${_firstNameController.text}");
      print("Org: ${_orgNameController.text}");
      print("Source: $_selectedSource");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead Created Successfully')),
      );
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
        // Using standard back button color to match text
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
      body: SingleChildScrollView(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an organization';
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
                onChanged: (String? newValue) {
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
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
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
        borderSide: BorderSide.none, // Clean look without borders by default
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
    );
  }

  // Helper widget for labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B), // Slate gray for labels
      ),
    );
  }
}
