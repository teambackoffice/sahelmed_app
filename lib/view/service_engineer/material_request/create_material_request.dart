import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/core/app_colors.dart';
import 'package:sahelmed_app/providers/get_warehouse_provider.dart';

class CreateMaterialRequest extends StatefulWidget {
  const CreateMaterialRequest({super.key});

  @override
  State<CreateMaterialRequest> createState() => _CreateMaterialRequestState();
}

class _CreateMaterialRequestState extends State<CreateMaterialRequest> {
  final _formKey = GlobalKey<FormState>();
  final _addItemFormKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // State Variables
  String? _selectedPurpose;
  String? _selectedWarehouse;
  String? _selectedUom;
  DateTime _transactionDate = DateTime.now();
  DateTime _requiredByDate = DateTime.now().add(const Duration(days: 7));

  // Data
  final List<String> purposes = ['Purchase', 'Material Issue'];

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

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    // Fetch warehouses when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetWarehouseProvider>().fetchWarehouses();
    });
  }

  // --- Logic Methods ---

  void _addItem() {
    if (_addItemFormKey.currentState!.validate()) {
      setState(() {
        items.add({
          'itemCode': _itemCodeController.text,
          'qty': _quantityController.text,
          'uom': _selectedUom,
        });
        _itemCodeController.clear();
        _quantityController.clear();
        _selectedUom = null;
      });
      Navigator.pop(context);
    }
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isTransaction) async {
    final initialDate = isTransaction ? _transactionDate : _requiredByDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        if (isTransaction) {
          _transactionDate = picked;
        } else {
          _requiredByDate = picked;
        }
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate() && items.isNotEmpty) {
      // TODO: Implement actual API submission
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('Success'),
          content: const Text('Material request created successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                ..pop()
                ..pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please add at least one item'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add_shopping_cart,
                color: Colors.indigo.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add New Item',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _addItemFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _itemCodeController,
                  decoration: InputDecoration(
                    labelText: 'Item Name / Code',
                    labelStyle: const TextStyle(fontSize: 14),
                    hintText: 'Enter item name or code',
                    hintStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Item name is required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: const TextStyle(fontSize: 14),
                          hintText: '0.00',
                          hintStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedUom,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'Select unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        items: uomList
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedUom = v),
                        validator: (v) => v == null ? 'Unit is required' : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _itemCodeController.clear();
              _quantityController.clear();
              setState(() => _selectedUom = null);
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: _addItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('ADD ITEM'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'New Material Request',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<GetWarehouseProvider>(
        builder: (context, warehouseProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedPurpose,
                          decoration: InputDecoration(
                            labelText: 'Purpose',
                            prefixIcon: Icon(
                              Icons.assignment_ind_outlined,
                              color: Colors.indigo.shade300,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: purposes
                              .map(
                                (p) =>
                                    DropdownMenuItem(value: p, child: Text(p)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedPurpose = v),
                          validator: (v) =>
                              v == null ? 'Please select a purpose' : null,
                        ),
                        const SizedBox(height: 16),

                        // 🔥 INTEGRATED WAREHOUSE DROPDOWN
                        DropdownButtonFormField<String>(
                          value: _selectedWarehouse,
                          decoration: InputDecoration(
                            labelText: 'Warehouse',
                            prefixIcon: Icon(
                              Icons.warehouse_outlined,
                              color: Colors.indigo.shade300,
                            ),
                            suffixIcon: warehouseProvider.isLoading
                                ? Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.indigo.shade300,
                                      ),
                                    ),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: warehouseProvider.warehouses
                              .where((w) => !w.disabled && !w.isGroup)
                              .map(
                                (w) => DropdownMenuItem(
                                  value: w.id,
                                  child: Text(
                                    w.warehouseName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: warehouseProvider.isLoading
                              ? null
                              : (v) => setState(() => _selectedWarehouse = v),
                          validator: (v) =>
                              v == null ? 'Please select a warehouse' : null,
                        ),

                        // Show error if warehouse fetch failed
                        if (warehouseProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Failed to load warehouses',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<GetWarehouseProvider>()
                                        .fetchWarehouses();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context, true),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Transaction Date',
                                    prefixIcon: Icon(
                                      Icons.calendar_today,
                                      color: Colors.indigo.shade300,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  child: Text(_formatDate(_transactionDate)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context, false),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Required By',
                                    prefixIcon: Icon(
                                      Icons.event_available,
                                      color: Colors.orange.shade300,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  child: Text(_formatDate(_requiredByDate)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items List',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddItemDialog,
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.darkNavy,
                        ),
                        label: const Text(
                          'Add Item',
                          style: TextStyle(color: AppColors.darkNavy),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (items.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.checklist_rtl_rounded,
                            size: 60,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items added yet',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showAddItemDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade50,
                              foregroundColor: Colors.indigo,
                              elevation: 0,
                            ),
                            child: const Text('Add First Item'),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Dismissible(
                          key: Key('${item['itemCode']}_$index'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _removeItem(index),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red.shade700,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                item['itemCode'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${item['qty']} ${item['uom']}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _removeItem(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkNavy,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'SUBMIT REQUEST',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _itemCodeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
