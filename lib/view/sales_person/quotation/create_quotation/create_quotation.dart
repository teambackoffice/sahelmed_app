import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/modal/get_customer_modal.dart';
import 'package:sahelmed_app/modal/get_leads_modal.dart';
import 'package:sahelmed_app/providers/create_quotation_provider.dart';
import 'package:sahelmed_app/providers/get_customer_provider.dart';
import 'package:sahelmed_app/providers/get_item_list_provider.dart';
import 'package:sahelmed_app/providers/get_leads_provider.dart';
import 'package:sahelmed_app/view/sales_person/quotation/create_quotation/customer_list_dialog.dart';
import 'package:sahelmed_app/view/sales_person/quotation/create_quotation/item_list_dialog.dart';
import 'package:sahelmed_app/view/sales_person/quotation/create_quotation/lead_list_dialog.dart';

// ─── Quotation Item ───────────────────────────────────────────────────────────
class QuotationItem {
  String? id;
  String itemCode;
  String name;
  double quantity;
  double rate;
  String uom;
  File? image;
  String? imageUrl;

  // Description: one text field + multiple images (local files) + network URLs from API
  late final TextEditingController descriptionController;
  List<File> descriptionImages;
  List<String> descriptionImageUrls; // Network image paths/URLs from item API

  // Other controllers
  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController rateController;

  // Available UOM options
  static const List<String> uomOptions = [
    'Nos',
    'Unit',
    'Box',
    'Set',
    'Pair',
    'Kg',
    'Kilogram',
    'Gram',
    'Litre',
    'Millilitre',
    'Meter',
    'Centimeter',
    'Millimeter',
    'Decimeter',
    'Inch',
    'Foot',
    'Hand',
    'Chain',
    'Calibre',
    'Barleycorn',
  ];

  QuotationItem({
    this.id,
    this.itemCode = '',
    this.name = '',
    String description = '',
    this.quantity = 1.0,
    this.rate = 0.0,
    this.uom = 'Nos',
    this.image,
    this.imageUrl,
    List<File>? descriptionImages,
    List<String>? descriptionImageUrls,
  }) : descriptionImages = descriptionImages ?? [],
       descriptionImageUrls = descriptionImageUrls ?? [] {
    nameController = TextEditingController(text: name);
    descriptionController = TextEditingController(text: description);
    quantityController = TextEditingController(
      text: quantity == 0.0 && quantity.toString().endsWith('.0')
          ? quantity.toInt().toString()
          : quantity.toString(),
    );
    rateController = TextEditingController(text: rate.toString());
  }

  double get amount => quantity * rate;

  /// Serializes description text + images (network URLs + local files) into HTML for the API.
  String get descriptionHtml {
    final buffer = StringBuffer();
    final text = descriptionController.text.trim();
    if (text.isNotEmpty) {
      buffer.write('<p>${text.replaceAll('\n', '<br>')}</p>');
    }
    // Network images (from the item's html_description)
    for (final url in descriptionImageUrls) {
      buffer.write(
        '<img src="$url" '
        'style="max-width:100%;border-radius:8px;margin:8px 0;" />',
      );
    }
    // Local images picked by the user
    for (final img in descriptionImages) {
      final bytes = img.readAsBytesSync();
      final b64 = base64Encode(bytes);
      buffer.write(
        '<img src="data:image/jpeg;base64,$b64" '
        'style="max-width:100%;border-radius:8px;margin:8px 0;" />',
      );
    }
    return buffer.toString();
  }

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    rateController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'item_name': name,
      'custom_html_description': descriptionHtml,
      'qty': quantity,
      'rate': rate,
      'uom': uom,
      'amount': amount,
      if (image != null) 'image': image!.path.split('/').last,
      if (image != null) 'image_file': image,
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

  // Store actual DateTime for valid_till to format correctly
  DateTime? validTillDate;

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
  }

  @override
  void dispose() {
    for (var item in items) {
      item.dispose();
    }
    nameController.dispose();
    companyController.dispose();
    dateController.dispose();
    validTillController.dispose();
    super.dispose();
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

  double get grandTotal => subtotal;

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
      setState(() {
        validTillDate = picked; // Store the DateTime object
        validTillController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage(int index) async {
    try {
      // Show bottom sheet to choose between camera and gallery
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Drag handle
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 16),

                /// Title
                const Text(
                  'Add Product Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 24),

                /// Camera option
                _ImagePickerTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take Photo',
                  subtitle: 'Capture using camera',
                  color: const Color(0xFF6366F1),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),

                const SizedBox(height: 12),

                /// Gallery option
                _ImagePickerTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  subtitle: 'Select from your photos',
                  color: const Color(0xFF3B82F6),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),

                const SizedBox(height: 24),

                /// Cancel
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      // If user selected a source, pick the image
      if (source != null) {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            items[index].image = File(pickedFile.path);
          });
        }
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
      items[index].dispose();
      setState(() {
        items.removeAt(index);
      });
    }
  }

  void _showCustomerSearchDialog() {
    final customers = context.read<GetCustomerProvider>().customers;

    showDialog(
      context: context,
      builder: (context) => CustomerSearchDialog(
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
      builder: (context) => LeadSearchDialog(
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

  /// Extracts image src paths from an HTML string (e.g. html_description from the API).
  List<String> _extractImageUrlsFromHtml(String? html) {
    if (html == null || html.isEmpty) return [];
    final urls = <String>[];
    // Match src attribute values: src="..." or src='...'
    final regExp = RegExp("src=[\"'](.*?)[\"']", caseSensitive: false);
    for (final match in regExp.allMatches(html)) {
      final src = match.group(1) ?? '';
      if (src.isNotEmpty && !src.startsWith('data:')) {
        urls.add(src);
      }
    }
    return urls;
  }

  /// Converts Quill-editor HTML (html_description) to a clean, readable plain text string.
  /// Handles: paragraphs, ordered list items, unordered lists, img removal, entity decoding.
  String _htmlToPlainText(String? html) {
    if (html == null || html.isEmpty) return '';

    String text = html;

    // 1. Remove ql-ui spans entirely (they are empty UI markers in Quill editor)
    // Using a non-raw string so we can mix quote types safely
    text = text.replaceAll(
      RegExp(
        "(<span[^>]*class=[^>]*ql-ui[^>]*>.*?</span>)",
        caseSensitive: false,
        dotAll: true,
      ),
      "",
    );

    // 2. Convert <ol> ordered lists to numbered lines
    final olRegExp = RegExp(
      "<ol[^>]*>(.*?)</ol>",
      caseSensitive: false,
      dotAll: true,
    );
    text = text.replaceAllMapped(olRegExp, (match) {
      final olContent = match.group(1) ?? '';
      final liRegExp = RegExp(
        "<li[^>]*>(.*?)</li>",
        caseSensitive: false,
        dotAll: true,
      );
      int counter = 0;
      final result = olContent.replaceAllMapped(liRegExp, (liMatch) {
        counter++;
        final liText = liMatch.group(1) ?? '';
        final cleaned = liText.replaceAll(RegExp("<[^>]+>"), "").trim();
        return '$counter. $cleaned';
      });
      return '\n$result';
    });

    // 3. Convert <ul> unordered lists to bullet lines
    final ulRegExp = RegExp(
      "<ul[^>]*>(.*?)</ul>",
      caseSensitive: false,
      dotAll: true,
    );
    text = text.replaceAllMapped(ulRegExp, (match) {
      final ulContent = match.group(1) ?? '';
      final liRegExp = RegExp(
        "<li[^>]*>(.*?)</li>",
        caseSensitive: false,
        dotAll: true,
      );
      final result = ulContent.replaceAllMapped(liRegExp, (liMatch) {
        final liText = liMatch.group(1) ?? '';
        final cleaned = liText.replaceAll(RegExp("<[^>]+>"), "").trim();
        return '• $cleaned';
      });
      return '\n$result';
    });

    // 4. Convert <p> and <br> to newlines
    text = text.replaceAll(RegExp("<p[^>]*>", caseSensitive: false), "");
    text = text.replaceAll(RegExp("</p>", caseSensitive: false), "\n");
    text = text.replaceAll(RegExp("<br\\s*/?>", caseSensitive: false), "\n");

    // 5. Remove <img> tags (images are shown separately in the UI)
    text = text.replaceAll(RegExp("<img[^>]*>", caseSensitive: false), "");

    // 6. Strip all remaining HTML tags
    text = text.replaceAll(RegExp("<[^>]+>"), "");

    // 7. Decode common HTML entities
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll("&quot;", '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');

    // 8. Collapse excessive blank lines (3+ in a row -> 1 blank line)
    text = text.replaceAll(RegExp("\n{3,}"), "\n\n");

    return text.trim();
  }

  void _showItemSearchDialog(int index) {
    final itemsList = context.read<ItemsProvider>().items;

    showDialog(
      context: context,
      builder: (context) => ItemSearchDialog(
        items: itemsList,
        onItemSelected: (item) {
          setState(() {
            items[index].id = item.id;
            items[index].itemCode = item.itemCode;
            items[index].name = item.itemName;
            items[index].nameController.text = item.itemName;
            items[index].imageUrl = item.image;

            // ── Populate description from the item ──────────────────────────
            // Parse html_description into readable plain text (handles lists, paragraphs, etc)
            // Fall back to plain_description only if html_description is absent
            final parsedText =
                item.htmlDescription != null && item.htmlDescription!.isNotEmpty
                ? _htmlToPlainText(item.htmlDescription)
                : (item.plainDescription ?? '');
            items[index].descriptionController.text = parsedText;

            // Extract image URLs embedded in html_description
            final imageUrls = _extractImageUrlsFromHtml(item.htmlDescription);
            items[index].descriptionImageUrls = imageUrls;
            // Clear any previously picked local description images
            items[index].descriptionImages.clear();

            double rate = 0.0;
            if (item.prices.isNotEmpty) {
              rate = item.prices.first.rate.toDouble();
            } else {
              rate = item.standardRate.toDouble();
            }
            items[index].rate = rate;
            items[index].rateController.text = rate.toString();
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
                                    // _buildSummaryRow('Subtotal', subtotal),
                                    // const Divider(),
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
              controller: item.nameController,
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

            // Rich Description Editor
            _buildDescriptionField(index),

            const SizedBox(height: 16),

            // UOM Selection - Modern Dropdown Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unit of Measure',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.05),
                        const Color(0xFF3B82F6).withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showUOMPicker(context, index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6366F1,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.straighten_rounded,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selected Unit',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF9CA3AF),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.uom,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.unfold_more_rounded,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quantity and Rate Row
            Row(
              children: [
                // Quantity
                Expanded(
                  child: TextFormField(
                    controller: item.quantityController,
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
                      labelText: 'Quantity',
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
                    controller: item.rateController,
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

  // ─── Description field: single text area + multiple images ──────────────────

  Widget _buildDescriptionField(int itemIndex) {
    final item = items[itemIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──────────────────────────────────────────────────────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF2563EB),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Text area ──────────────────────────────────────────────────────────
        TextFormField(
          controller: item.descriptionController,
          maxLines: 4,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: 'Enter product description…',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            alignLabelWithHint: true,
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
            contentPadding: const EdgeInsets.all(14),
          ),
        ),

        const SizedBox(height: 10),

        // ── Image thumbnails + Add chip ────────────────────────────────────────
        // Combine: network URLs (from API) first, then local picked files, then "Add Photo".
        Builder(
          builder: (context) {
            final urlCount = item.descriptionImageUrls.length;
            final fileCount = item.descriptionImages.length;
            final totalCount = urlCount + fileCount + 1; // +1 for "Add Photo"

            return SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: totalCount,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  // ── "Add Photo" button (last slot) ────────────────────────
                  if (i == urlCount + fileCount) {
                    return GestureDetector(
                      onTap: () => _pickDescriptionImage(itemIndex),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6366F1,
                                ).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 20,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Add Photo',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ── Network image (from API html_description) ──────────────
                  if (i < urlCount) {
                    final rawUrl = item.descriptionImageUrls[i];
                    // Build full URL: paths like "/files/..." need the base URL prepended
                    final fullUrl = rawUrl.startsWith('http')
                        ? rawUrl
                        : 'https://uat-alsahel.tbo365.cloud$rawUrl';
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            fullUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, _) => Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF9CA3AF),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        // Small "from item" badge
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Item',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                items[itemIndex].descriptionImageUrls.removeAt(
                                  i,
                                );
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // ── Local file image (picked by user) ──────────────────────
                  final fileIdx = i - urlCount;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          item.descriptionImages[fileIdx],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              items[itemIndex].descriptionImages.removeAt(
                                fileIdx,
                              );
                            });
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _pickDescriptionImage(int itemIndex) async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Image to Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 24),
                _ImagePickerTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take Photo',
                  subtitle: 'Capture using camera',
                  color: const Color(0xFF6366F1),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                const SizedBox(height: 12),
                _ImagePickerTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  subtitle: 'Select from your photos',
                  color: const Color(0xFF3B82F6),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? picked = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );
        if (picked != null) {
          setState(() {
            items[itemIndex].descriptionImages.add(File(picked.path));
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
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

  Future<void> _showUOMPicker(BuildContext context, int index) async {
    final selectedUOM = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 16),

              /// Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.straighten_rounded,
                        color: Color(0xFF2563EB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Unit of Measure',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Choose the measurement unit',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// UOM List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: QuotationItem.uomOptions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, i) {
                    final uom = QuotationItem.uomOptions[i];
                    final isSelected = uom == items[index].uom;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, uom),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFF6366F1,
                                        ).withOpacity(0.15)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    uom.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  uom,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF1F2937)
                                        : const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
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

              const SizedBox(height: 16),

              /// Cancel Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedUOM != null) {
      setState(() {
        items[index].uom = selectedUOM;
      });
    }
  }

  Future<void> _submitQuotation(CreateQuotationController controller) async {
    // Validation: Ensure valid name
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter name')));
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

    // Determine party name: Use Selected ID if available, otherwise use Text Input (Manual Entry)
    String partyName = nameController.text.trim();

    if (quotationTo == 'Customer' && selectedCustomer != null) {
      partyName = selectedCustomer!.id;
    } else if (quotationTo == 'Lead' && selectedLead != null) {
      partyName = selectedLead!.id;
    }

    // Convert valid_till date to YYYY-MM-DD format
    String? validTillFormatted;
    if (validTillDate != null) {
      validTillFormatted = DateFormat('yyyy-MM-dd').format(validTillDate!);
    }

    // Submit quotation
    await controller.createQuotation(
      quotationTo: quotationTo,
      partyName: partyName,
      validTill: validTillFormatted ?? '',
      items: itemsData,
    );

    if (controller.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${controller.error}')));
    } else if (controller.quotationResponse != null) {
      final quotationId =
          controller.quotationResponse!.quotationId ??
          controller.quotationResponse!.message ??
          'Success';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quotation Created: $quotationId'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or to quotation details
      Navigator.pop(context);
    }
  }
}

class _ImagePickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ImagePickerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
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
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
