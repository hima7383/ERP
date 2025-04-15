import 'package:dio/dio.dart';
import 'package:erp/features/auth/data/entities/clients/clients.dart';
import 'package:erp/features/auth/data/entities/sales/sendata/salesinvoicecreate_entity.dart';
import 'package:erp/features/auth/data/entities/stock/prdouct.dart';
import 'package:erp/features/auth/data/repos/sales/sendata/salesinvoicecreate_repo.dart';
import 'package:erp/features/auth/logic/clients/clients_cubit.dart';
import 'package:erp/features/auth/logic/sales/sendata/Salesinvoicecreation_cubit.dart';
import 'package:erp/features/auth/logic/stock/product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';

class SalesInvoiceScreencreate extends StatefulWidget {
  const SalesInvoiceScreencreate({super.key});

  @override
  State<SalesInvoiceScreencreate> createState() =>
      _SalesInvoiceScreencreateState();
}

class _SalesInvoiceScreencreateState extends State<SalesInvoiceScreencreate> {
  @override
  void initState() {
    context.read<CustomerCubit>().fetchCustomers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesInvoiceCubitcreate(
        SalesInvoiceRepositoryImpl(Dio()),
      ),
      child: const _SalesInvoiceView(),
    );
  }
}

class _SalesInvoiceView extends StatefulWidget {
  const _SalesInvoiceView();

  @override
  State<_SalesInvoiceView> createState() => _SalesInvoiceViewState();
}

class _SalesInvoiceViewState extends State<_SalesInvoiceView> {
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  DateTime _invoiceDate = DateTime.now();
  DateTime _releaseDate = DateTime.now();
  final _paymentTermsController = TextEditingController(text: '0');
  bool _alreadyPaid = false;
  final _amountPaidController = TextEditingController(text: '0.0');
  final List<InvoiceItemDTO> _invoiceItems = [];
  Product? _selectedProductToAdd;
  final _quantityController = TextEditingController(text: '1');
  final _itemDescriptionController = TextEditingController();
  final _itemDiscountController = TextEditingController(text: '0.0');
  final _itemTaxController = TextEditingController(text: '0.0');
  double _subtotal = 0.0;
  double _totalTax = 0.0;
  double _totalDiscount = 0.0;
  double _grandTotal = 0.0;

  void _calculateTotals() {
    double subtotal = 0;
    double totalTax = 0;
    double totalDiscount = 0;

    for (var item in _invoiceItems) {
      subtotal += item.unitPrice * item.quantity;
      totalTax += item.tax;
      totalDiscount += item.discount;
    }

    double grandTotal = subtotal - totalDiscount + totalTax;

    setState(() {
      _subtotal = subtotal;
      _totalTax = totalTax;
      _totalDiscount = totalDiscount;
      _grandTotal = grandTotal;
    });
  }

  void _addInvoiceItem() {
    if (_selectedProductToAdd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product.')),
      );
      return;
    }
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity (> 0).')),
      );
      return;
    }

    final unitPrice = _selectedProductToAdd!.sellPrice;
    final itemDiscount = double.tryParse(_itemDiscountController.text) ?? 0.0;
    final itemTax = double.tryParse(_itemTaxController.text) ?? 0.0;
    final itemTotalPrice = (quantity * unitPrice) - itemDiscount + itemTax;

    final newItem = InvoiceItemDTO(
      productId: _selectedProductToAdd!.id,
      quantity: quantity,
      description: _itemDescriptionController.text.isNotEmpty
          ? _itemDescriptionController.text
          : _selectedProductToAdd!.description,
      discount: itemDiscount,
      tax: itemTax,
      unitPrice: unitPrice,
      totalPrice: itemTotalPrice,
    );

    setState(() {
      _invoiceItems.add(newItem);
      _selectedProductToAdd = null;
      _quantityController.text = '1';
      _itemDescriptionController.clear();
      _itemDiscountController.text = '0.0';
      _itemTaxController.text = '0.0';
      _calculateTotals();
    });
    FocusScope.of(context).unfocus();
  }

  void _removeInvoiceItem(int index) {
    setState(() {
      _invoiceItems.removeAt(index);
      _calculateTotals();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isInvoiceDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInvoiceDate ? _invoiceDate : _releaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );
    if (picked != null &&
        picked != (isInvoiceDate ? _invoiceDate : _releaseDate)) {
      setState(() {
        if (isInvoiceDate) {
          _invoiceDate = picked;
        } else {
          _releaseDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer.')),
        );
        return;
      }
      if (_invoiceItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one invoice item.')),
        );
        return;
      }

      final invoiceData = InvoiceCreateDTO(
        customerID: _selectedCustomer!.customerId,
        invoiceDate: _invoiceDate,
        releaseDate: _releaseDate,
        paymentTerms: int.tryParse(_paymentTermsController.text) ?? 0,
        tax: _totalTax,
        discount: _totalDiscount,
        total: _grandTotal,
        alreadyPaid: _alreadyPaid,
        amountPaid: double.tryParse(_amountPaidController.text) ?? 0.0,
        invoiceItemDT0s: _invoiceItems,
      );

      context.read<SalesInvoiceCubitcreate>().submitInvoice(invoiceData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form.')),
      );
    }
  }

  @override
  void dispose() {
    _paymentTermsController.dispose();
    _amountPaidController.dispose();
    _quantityController.dispose();
    _itemDescriptionController.dispose();
    _itemDiscountController.dispose();
    _itemTaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
        title: const Text(
          'Create Sales Invoice',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<SalesInvoiceCubitcreate, SalesInvoiceState>(
        listener: (context, state) {
          if (state is SalesInvoiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invoice created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is SalesInvoiceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create invoice: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Selection
                _buildSectionHeader('Customer Information'),
                const Gap(8),
                BlocBuilder<CustomerCubit, CustomerState>(
                  builder: (context, state) {
                    if (state is CustomerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CustomerListLoaded) {
                      return _buildDropdown<Customer>(
                        value: _selectedCustomer,
                        hint: 'Select Customer',
                        items: state.customers,
                        displayText: (customer) => state.nameCache[customer.customerId] ?? 'Unknown Customer',
                        onChanged: (value) => setState(() => _selectedCustomer = value),
                        validator: (value) => value == null ? 'Please select a customer' : null,
                      );
                    } else if (state is CustomerError) {
                      return Text('Error: ${state.message}', style: const TextStyle(color: Colors.red));
                    }
                    return const Text('Loading customers...');
                  },
                ),
                const Gap(16),

                // Dates
                _buildSectionHeader('Invoice Dates'),
                const Gap(8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Invoice Date',
                        date: _invoiceDate,
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: _buildDateField(
                        label: 'Release Date',
                        date: _releaseDate,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const Gap(16),

                // Payment Terms
                _buildSectionHeader('Payment Terms'),
                const Gap(8),
                _buildTextField(
                  controller: _paymentTermsController,
                  label: 'Payment Terms (days)',
                  hint: 'e.g., 0 for Net 0, 30 for Net 30',
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty || int.tryParse(value) == null 
                      ? 'Enter valid payment terms' 
                      : null,
                ),
                const Gap(24),

                // Invoice Items Section
                _buildSectionHeader('Invoice Items'),
                const Divider(color: Colors.grey, height: 20),

                // Display Added Items
                if (_invoiceItems.isNotEmpty) ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _invoiceItems.length,
                    itemBuilder: (context, index) {
                      final item = _invoiceItems[index];
                      String productName = "Product ID: ${item.productId}";
                      try {
                        final productState = context.read<ProductCubit>().state;
                        if (productState is ProductLoaded) {
                          final product = productState.products
                              .firstWhere((p) => p.id == item.productId);
                          productName = product.name;
                        }
                      } catch (e) {}

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qty: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              if (item.description.isNotEmpty)
                                Text(
                                  'Desc: ${item.description}',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              Text(
                                'Total: \$${item.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeInvoiceItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                  const Gap(16),
                ],

                // Add New Item Form
                _buildSectionHeader('Add New Item'),
                const Gap(8),
                BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const LinearProgressIndicator();
                    } else if (state is ProductLoaded) {
                      return _buildDropdown<Product>(
                        value: _selectedProductToAdd,
                        hint: 'Select Product',
                        items: state.products,
                        displayText: (product) => 
                            '${product.name} (\$${product.sellPrice.toStringAsFixed(2)})',
                        onChanged: (value) {
                          setState(() {
                            _selectedProductToAdd = value;
                            if (value != null) {
                              _itemDescriptionController.text = value.description;
                            }
                          });
                        },
                      );
                    } else if (state is ProductError) {
                      return Text('Error: ${state.message}', style: const TextStyle(color: Colors.red));
                    }
                    return const Text('Loading products...');
                  },
                ),
                const Gap(8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _quantityController,
                        label: 'Quantity',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _itemDiscountController,
                        label: 'Discount (Amount)',
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _itemTaxController,
                        label: 'Tax (Amount)',
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                _buildTextField(
                  controller: _itemDescriptionController,
                  label: 'Item Description (Optional)',
                  maxLines: 2,
                ),
                const Gap(12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _addInvoiceItem,
                  ),
                ),
                const Gap(24),

                // Totals Section
                _buildSectionHeader('Invoice Summary'),
                const Divider(color: Colors.grey, height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal:', _subtotal),
                      _buildTotalRow('Discount:', -_totalDiscount),
                      _buildTotalRow('Tax:', _totalTax),
                      const Divider(color: Colors.grey),
                      _buildTotalRow(
                        'Grand Total:',
                        _grandTotal,
                        isBold: true,
                        textColor: Colors.teal,
                      ),
                    ],
                  ),
                ),
                const Gap(16),

                // Payment Status
                _buildSectionHeader('Payment Status'),
                const Gap(8),
                SwitchListTile(
                  title: const Text(
                    'Already Paid',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _alreadyPaid,
                  onChanged: (bool value) {
                    setState(() {
                      _alreadyPaid = value;
                    });
                  },
                  activeColor: Colors.teal,
                  inactiveTrackColor: Colors.grey[700],
                  contentPadding: EdgeInsets.zero,
                ),
                if (_alreadyPaid) ...[
                  const Gap(8),
                  _buildTextField(
                    controller: _amountPaidController,
                    label: 'Amount Paid',
                    prefixIcon: Icon(Icons.attach_money),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (_alreadyPaid) {
                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                          return 'Enter valid amount';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be positive';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                const Gap(24),

                // Submit Button
                BlocBuilder<SalesInvoiceCubitcreate, SalesInvoiceState>(
                  builder: (context, state) {
                    final isLoading = state is SalesInvoiceLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLoading ? Colors.grey[700] : Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'CREATE INVOICE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) displayText,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(
        hint,
        style: TextStyle(color: Colors.grey[400]),
      ),
      dropdownColor: Colors.grey[900],
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        filled: true,
        fillColor: Colors.grey[900],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            displayText(item),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        const Gap(4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[400]),
                const Gap(12),
                Text(
                  DateFormat('yyyy-MM-dd').format(date),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int? maxLines,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        filled: true,
        fillColor: Colors.grey[900],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: prefixIcon != null
            ? IconTheme(
                data: IconThemeData(color: Colors.grey[400]),
                child: prefixIcon,
              )
            : null,
      ),
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildTotalRow(String label, double value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[300],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value),
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}