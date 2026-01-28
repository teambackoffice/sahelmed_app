import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/modal/get_customer_modal.dart';
import 'package:sahelmed_app/modal/get_item_list_modal.dart';
import 'package:sahelmed_app/modal/get_leads_modal.dart';
import 'package:sahelmed_app/providers/create_quotation_provider.dart';
import 'package:sahelmed_app/providers/get_customer_provider.dart';
import 'package:sahelmed_app/providers/get_item_list_provider.dart';
import 'package:sahelmed_app/providers/get_leads_provider.dart';

class QuotationItem {
  String? id;
  String itemCode;
  String name;
  String description;
  double quantity;
  double rate;
  File? image;
  String? imageUrl;

  QuotationItem({
    this.id,
    this.itemCode = '',
    this.name = '',
    this.description = '',
    this.quantity = 1.0,
    this.rate = 0.0,
    this.image,
    this.imageUrl,
  });

  double get amount => quantity * rate;

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'item_name': name,
      'description': description,
      'qty': quantity,
      'rate': rate,
      'amount': amount,
    };
  }
}

class CreateQuotation extends StatefulWidget {
  const CreateQuotation({super.key});

  @override
  State<CreateQuotation> createState() => _CreateQuotationState();
}

class _CreateQuotationState extends State<CreateQuotation> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController validTillController = TextEditingController();

  String quotationTo = 'Customer';
  String orderType = 'Sales';
  List<QuotationItem> items = [QuotationItem()];

  Customer? selectedCustomer;
  Lead? selectedLead;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load customers, leads, and items on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetCustomerProvider>().loadCustomers();
      context.read<ItemsProvider>().fetchItems();
      context.read<LeadController>().getLeads();
    });

    // Set today's date
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Set default valid till date (30 days from now)
    validTillController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now().add(const Duration(days: 30)));
  }

  String get nameLabel {
    switch (quotationTo) {
      case 'Lead':
        return 'Lead Name';
      default:
        return 'Customer Name';
    }
  }

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.amount);

  double get taxAmount => subtotal * 0.18; // 18% tax

  double get grandTotal => subtotal + taxAmount;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dateController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Future<void> _selectValidTillDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      validTillController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          items[index].image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _addNewItem() {
    setState(() {
      items.add(QuotationItem());
    });
  }

  void _removeItem(int index) {
    if (items.length > 1) {
      setState(() {
        items.removeAt(index);
      });
    }
  }

  void _showCustomerSearchDialog() {
    final customers = context.read<GetCustomerProvider>().customers;

    showDialog(
      context: context,
      builder: (context) => _CustomerSearchDialog(
        customers: customers,
        onCustomerSelected: (customer) {
          setState(() {
            selectedCustomer = customer;
            selectedLead = null;
            nameController.text = customer.customerName;
            companyController.clear();
          });
        },
      ),
    );
  }

  void _showLeadSearchDialog() {
    final leads = context.read<LeadController>().leads;

    showDialog(
      context: context,
      builder: (context) => _LeadSearchDialog(
        leads: leads,
        onLeadSelected: (lead) {
          setState(() {
            selectedLead = lead;
            selectedCustomer = null;
            nameController.text = lead.leadName;
            companyController.text = lead.companyName ?? '';
          });
        },
      ),
    );
  }

  void _showItemSearchDialog(int index) {
    final itemsList = context.read<ItemsProvider>().items;

    showDialog(
      context: context,
      builder: (context) => _ItemSearchDialog(
        items: itemsList,
        onItemSelected: (item) {
          setState(() {
            items[index].id = item.id;
            items[index].itemCode = item.itemCode;
            items[index].name = item.itemName;
            items[index].description = item.description;
            items[index].rate = item.valuationRate;
            items[index].imageUrl = item.image;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body:
          Consumer4<
            GetCustomerProvider,
            ItemsProvider,
            CreateQuotationController,
            LeadController
          >(
            builder:
                (
                  context,
                  customerProvider,
                  itemsProvider,
                  quotationController,
                  leadController,
                  _,
                ) {
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),

                            // Back Button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                  color: Color(0xFF6366F1),
                                  size: 24,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Header Section
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF3B82F6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'New Quotation',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Fill in the details below',
                                          style: TextStyle(
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

                            // Form Card
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
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section: Basic Information
                                    _buildSectionLabel('Basic Information'),
                                    const SizedBox(height: 16),

                                    /// Quotation To
                                    _buildDropdownField(
                                      label: 'Quotation To',
                                      value: quotationTo,
                                      icon: Icons.person_outline,
                                      items: ['Lead', 'Customer'],
                                      onChanged: (value) {
                                        setState(() {
                                          quotationTo = value!;
                                          nameController.clear();
                                          companyController.clear();
                                          selectedCustomer = null;
                                          selectedLead = null;
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    /// Customer/Lead Name with Search
                                    if (quotationTo == 'Customer')
                                      _buildCustomerSearchField(
                                        customerProvider,
                                      )
                                    else if (quotationTo == 'Lead')
                                      _buildLeadSearchField(leadController),

                                    const SizedBox(height: 20),

                                    /// Company Name (Only for Lead, read-only)

                                    /// Date
                                    _buildTextField(
                                      controller: dateController,
                                      label: 'Date',
                                      icon: Icons.calendar_today_outlined,
                                      hint: 'Select date',
                                      readOnly: true,
                                      onTap: () => _selectDate(context),
                                    ),

                                    const SizedBox(height: 20),

                                    /// Valid Till Date
                                    _buildTextField(
                                      controller: validTillController,
                                      label: 'Valid Till',
                                      icon: Icons.event_available_outlined,
                                      hint: 'Select valid till date',
                                      readOnly: true,
                                      onTap: () =>
                                          _selectValidTillDate(context),
                                    ),

                                    const SizedBox(height: 20),

                                    /// Order Type
                                    _buildDropdownField(
                                      label: 'Order Type',
                                      value: orderType,
                                      icon: Icons.category_outlined,
                                      items: [
                                        'Sales',
                                        'Maintenance',
                                        'Shopping Cart',
                                      ],
                                      onChanged: (value) {
                                        setState(() => orderType = value!);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Items Section
                            _buildSectionLabel('Items'),
                            const SizedBox(height: 16),

                            // Items List
                            ...List.generate(items.length, (index) {
                              return _buildItemCard(index, itemsProvider);
                            }),

                            const SizedBox(height: 16),

                            // Add Item Button
                            InkWell(
                              onTap: _addNewItem,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.3),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF6366F1,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Color(0xFF6366F1),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Add Another Item',
                                      style: TextStyle(
                                        color: Color(0xFF6366F1),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Summary Card
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
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _buildSummaryRow('Subtotal', subtotal),
                                    const SizedBox(height: 12),
                                    _buildSummaryRow('Tax (18%)', taxAmount),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 12),
                                    _buildSummaryRow(
                                      'Grand Total',
                                      grandTotal,
                                      isTotal: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            /// Submit Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF3B82F6),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: quotationController.isLoading
                                    ? null
                                    : () =>
                                          _submitQuotation(quotationController),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Create Quotation',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),

                      // Loading Overlay
                      if (quotationController.isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
          ),
    );
  }

  Widget _buildCustomerSearchField(GetCustomerProvider customerProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nameLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: customerProvider.isLoading ? null : _showCustomerSearchDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_circle_outlined,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCustomer?.customerName ?? 'Select Customer',
                    style: TextStyle(
                      fontSize: 15,
                      color: selectedCustomer != null
                          ? const Color(0xFF1F2937)
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (customerProvider.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF2563EB)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadSearchField(LeadController leadController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nameLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: leadController.isLoading ? null : _showLeadSearchDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_search_outlined,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedLead?.leadName ?? 'Select Lead',
                    style: TextStyle(
                      fontSize: 15,
                      color: selectedLead != null
                          ? const Color(0xFF1F2937)
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (leadController.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF2563EB)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(int index, ItemsProvider itemsProvider) {
    final item = items[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Item ${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (items.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                    onPressed: () => _removeItem(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Search Item Button
            InkWell(
              onTap: itemsProvider.isLoading
                  ? null
                  : () => _showItemSearchDialog(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.name.isEmpty ? 'Search & Select Item' : item.name,
                      style: TextStyle(
                        color: item.name.isEmpty
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF1F2937),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (itemsProvider.isLoading) ...[
                      const Spacer(),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Product Image
            InkWell(
              onTap: () => _pickImage(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: item.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(item.image!, fit: BoxFit.cover),
                      )
                    : item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),

            const SizedBox(height: 16),

            // Item Name (Read-only if selected from API)
            TextFormField(
              initialValue: item.name,
              readOnly: item.id != null,
              onChanged: (value) {
                setState(() => item.name = value);
              },
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Product Name',
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
                hintText: 'Enter product name',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              initialValue: item.description,
              onChanged: (value) {
                setState(() => item.description = value);
              },
              maxLines: 3,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
                hintText: 'Enter product description',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                alignLabelWithHint: true,
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quantity and Rate Row
            Row(
              children: [
                // Quantity
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item.quantity = double.tryParse(value) ?? 1.0;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                      hintText: '1',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.numbers,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Rate
                Expanded(
                  child: TextFormField(
                    initialValue: item.rate.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item.rate = double.tryParse(value) ?? 0.0;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Rate',
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                      hintText: '0.00',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.currency_rupee,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Amount Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.1),
                    const Color(0xFF3B82F6).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    '₹${item.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            size: 40,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tap to add product image',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFF2563EB) : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          iconEnabledColor: const Color(0xFF2563EB),
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _submitQuotation(CreateQuotationController controller) async {
    // Validation
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer/lead name')),
      );
      return;
    }

    if (items.isEmpty || items.first.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    // Prepare items data
    final itemsData = items.map((item) => item.toJson()).toList();

    // Determine party name based on selection
    String partyName = '';
    if (quotationTo == 'Customer' && selectedCustomer != null) {
      partyName = selectedCustomer!.id;
    } else if (quotationTo == 'Lead' && selectedLead != null) {
      partyName = selectedLead!.id;
    } else {
      partyName = nameController.text;
    }

    // Submit quotation
    await controller.createQuotation(partyName: partyName, items: itemsData);

    if (controller.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${controller.error}')));
    } else if (controller.quotationResponse != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Quotation Created: ${controller.quotationResponse!.quotationId}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or to quotation details
      Navigator.pop(context);
    }
  }
}

// Customer Search Dialog
class _CustomerSearchDialog extends StatefulWidget {
  final List<Customer> customers;
  final Function(Customer) onCustomerSelected;

  const _CustomerSearchDialog({
    required this.customers,
    required this.onCustomerSelected,
  });

  @override
  State<_CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<_CustomerSearchDialog> {
  final TextEditingController searchController = TextEditingController();
  List<Customer> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    filteredCustomers = widget.customers;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = widget.customers;
      } else {
        filteredCustomers = widget.customers
            .where(
              (customer) => customer.customerName.toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Customer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterCustomers,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by customer name...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              searchController.clear();
                              _filterCustomers('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Results count
            if (filteredCustomers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${filteredCustomers.length} customer${filteredCustomers.length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // Customer List
            Expanded(
              child: filteredCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No customers found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: filteredCustomers.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[200],
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onCustomerSelected(customer);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF3B82F6,
                                          ).withOpacity(0.1),
                                          const Color(
                                            0xFF2563EB,
                                          ).withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        customer.customerName
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Customer Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.customerName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF3B82F6,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                customer.customerType,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF3B82F6),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow Icon
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadSearchDialog extends StatefulWidget {
  final List<Lead> leads;
  final Function(Lead) onLeadSelected;

  const _LeadSearchDialog({required this.leads, required this.onLeadSelected});

  @override
  State<_LeadSearchDialog> createState() => _LeadSearchDialogState();
}

class _LeadSearchDialogState extends State<_LeadSearchDialog> {
  final TextEditingController searchController = TextEditingController();
  List<Lead> filteredLeads = [];

  @override
  void initState() {
    super.initState();
    filteredLeads = widget.leads;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterLeads(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredLeads = widget.leads;
      } else {
        filteredLeads = widget.leads
            .where(
              (lead) =>
                  lead.leadName.toLowerCase().contains(query.toLowerCase()) ||
                  (lead.companyName?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF10B981);
      case 'replied':
        return const Color(0xFF3B82F6);
      case 'opportunity':
        return const Color(0xFFF59E0B);
      case 'quotation':
        return const Color(0xFF8B5CF6);
      case 'lost':
        return const Color(0xFFEF4444);
      case 'interested':
        return const Color(0xFF06B6D4);
      case 'converted':
        return const Color(0xFF059669);
      case 'do not contact':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Lead',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterLeads,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by name or company...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              searchController.clear();
                              _filterLeads('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Results count
            if (filteredLeads.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${filteredLeads.length} lead${filteredLeads.length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // Lead List
            Expanded(
              child: filteredLeads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No leads found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: filteredLeads.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[200],
                        indent: 72,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final lead = filteredLeads[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onLeadSelected(lead);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF3B82F6,
                                          ).withOpacity(0.1),
                                          const Color(
                                            0xFF2563EB,
                                          ).withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        lead.leadName
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Lead Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lead.leadName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.business,
                                              size: 14,
                                              color: Colors.grey[500],
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                lead.companyName ??
                                                    'No company',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        lead.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _getStatusColor(
                                          lead.status,
                                        ).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      lead.status,
                                      style: TextStyle(
                                        color: _getStatusColor(lead.status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemSearchDialog extends StatefulWidget {
  final List<Item> items;
  final Function(Item) onItemSelected;

  const _ItemSearchDialog({required this.items, required this.onItemSelected});

  @override
  State<_ItemSearchDialog> createState() => _ItemSearchDialogState();
}

class _ItemSearchDialogState extends State<_ItemSearchDialog> {
  final TextEditingController searchController = TextEditingController();
  List<Item> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items
            .where(
              (item) =>
                  item.itemName.toLowerCase().contains(query.toLowerCase()) ||
                  item.itemCode.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Item',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterItems,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by item name or code...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              searchController.clear();
                              _filterItems('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Results count
            if (filteredItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${filteredItems.length} item${filteredItems.length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // Item List
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[200],
                        indent: 72,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onItemSelected(item);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Item Image/Icon
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: item.image != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              11,
                                            ),
                                            child: Image.network(
                                              item.image!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                const Color(
                                                                  0xFF3B82F6,
                                                                ).withOpacity(
                                                                  0.1,
                                                                ),
                                                                const Color(
                                                                  0xFF2563EB,
                                                                ).withOpacity(
                                                                  0.1,
                                                                ),
                                                              ],
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              11,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .inventory_2_outlined,
                                                        color: Color(
                                                          0xFF2563EB,
                                                        ),
                                                        size: 28,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(
                                                    0xFF3B82F6,
                                                  ).withOpacity(0.1),
                                                  const Color(
                                                    0xFF2563EB,
                                                  ).withOpacity(0.1),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                            ),
                                            child: const Icon(
                                              Icons.inventory_2_outlined,
                                              color: Color(0xFF2563EB),
                                              size: 28,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Item Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.itemName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.itemCode,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF10B981,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '₹${item.valuationRate.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF2563EB),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow Icon
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
