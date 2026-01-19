import 'package:flutter/material.dart';

class CreateMaterialRequest extends StatefulWidget {
  const CreateMaterialRequest({Key? key}) : super(key: key);

  @override
  State<CreateMaterialRequest> createState() => _CreateMaterialRequestState();
}

class _CreateMaterialRequestState extends State<CreateMaterialRequest> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _uomController = TextEditingController();

  // Dropdown values
  String? _selectedPurpose;
  DateTime _transactionDate = DateTime.now();
  DateTime _requiredByDate = DateTime.now().add(const Duration(days: 7));

  // Dummy data for dropdowns
  final List<String> purposes = [
    'Purchase',
    'Material Transfer',
    'Material Issue',
    'Manufacture',
    'Customer Provided',
  ];

  final List<String> uomList = [
    'Nos',
    'Box',
    'Pcs',
    'Kg',
    'Ltr',
    'Meter',
    'Sheets',
    'Sets',
    'Carton',
    'Roll',
  ];

  // Items list
  List<Map<String, dynamic>> items = [];

  void _addItem() {
    if (_itemCodeController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _uomController.text.isNotEmpty) {
      setState(() {
        items.add({
          'itemCode': _itemCodeController.text,
          'qty': _quantityController.text,
          'uom': _uomController.text,
        });
        _itemCodeController.clear();
        _quantityController.clear();
        _uomController.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Future<void> _selectTransactionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _transactionDate) {
      setState(() {
        _transactionDate = picked;
      });
    }
  }

  Future<void> _selectRequiredByDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _requiredByDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _requiredByDate) {
      setState(() {
        _requiredByDate = picked;
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate() && items.isNotEmpty) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Material request created successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Material Request'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Request Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Purpose Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedPurpose,
                        decoration: InputDecoration(
                          labelText: 'Purpose *',
                          prefixIcon: const Icon(Icons.assignment),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: purposes.map((String purpose) {
                          return DropdownMenuItem(
                            value: purpose,
                            child: Text(purpose),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPurpose = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a purpose';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Transaction Date Picker
                      InkWell(
                        onTap: () => _selectTransactionDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Transaction Date *',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          child: Text(
                            '${_transactionDate.day}/${_transactionDate.month}/${_transactionDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Required By Date Picker
                      InkWell(
                        onTap: () => _selectRequiredByDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Required By *',
                            prefixIcon: const Icon(Icons.event_available),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          child: Text(
                            '${_requiredByDate.day}/${_requiredByDate.month}/${_requiredByDate.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Add Items Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Item Code
                      TextFormField(
                        controller: _itemCodeController,
                        decoration: InputDecoration(
                          labelText: 'Item Code',
                          prefixIcon: const Icon(Icons.qr_code),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quantity
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: const Icon(Icons.shopping_cart),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // UOM Dropdown
                      DropdownButtonFormField<String>(
                        value: _uomController.text.isEmpty
                            ? null
                            : _uomController.text,
                        decoration: InputDecoration(
                          labelText: 'UOM (Unit of Measure)',
                          prefixIcon: const Icon(Icons.straighten),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: uomList.map((String uom) {
                          return DropdownMenuItem(value: uom, child: Text(uom));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _uomController.text = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Add Item Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Items List
              if (items.isNotEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items (${items.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade100,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                item['itemCode'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Qty: ${item['qty']} ${item['uom']}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeItem(index),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _itemCodeController.dispose();
    _quantityController.dispose();
    _uomController.dispose();
    super.dispose();
  }
}
