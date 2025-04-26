import 'package:erp/Core/widgets/genricori_dialogbox.dart';
import 'package:erp/Core/widgets/modern_loading_overlay.dart';
import 'package:erp/features/auth/data/entities/clients/clients.dart';
import 'package:erp/features/auth/logic/clients/clients_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (state is CustomerError) {
           Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No internet connection",
                            style: TextStyle(color: Colors.grey[400], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please check your connection",
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                            ),
                            ),
                            onPressed: () => context.read<CustomerCubit>().fetchCustomers(),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          
                          )
                        ],
                      ),
                    );
        }
        if (state is CustomerListLoaded && state.selectedCustomer != null) {
          _showCustomerDetailsPopup(context, state.selectedCustomer!);
          context.read<CustomerCubit>().resetSelectedCustomer();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text(
              'Customers',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0.0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CustomerState state) {
    if (state is CustomerLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (state is CustomerError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (state is CustomerLoadingById || state is CustomerListLoaded) {
      final customers = (state is CustomerListLoaded)
          ? state.filteredCustomers
          : (state as CustomerLoadingById).filteredCustomers;

      final nameCache = (state is CustomerListLoaded)
          ? state.nameCache
          : (state as CustomerLoadingById).nameCache;

      return Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by ID, Phone, or Email',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (query) {
                    context.read<CustomerCubit>().searchCustomers(query);
                  },
                ),
              ),
              Expanded(
                child: customers.isEmpty
                    ? Center(
                        child: Text(
                          'No customers found',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context.read<CustomerCubit>().fetchCustomers();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: customers.length,
                          separatorBuilder: (context, index) => const Gap(8),
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return Card(
                              color: Colors.grey[900],
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                onTap: () {
                                  context
                                      .read<CustomerCubit>()
                                      .fetchCustomerById(customer.customerId);
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical:
                                      8, // Reduced from 12 to 8 for compactness
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom:
                                          4), // Space between title and subtitle
                                  child: Text(
                                    nameCache[customer.customerId] ??
                                        'Customer #${customer.customerId}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          16, // Explicit font size for consistency
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  customer.phoneNumber,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14, // Explicit font size
                                  ),
                                ),
                                minVerticalPadding:
                                    0, // Removes extra ListTile padding
                                dense: true, // Makes ListTile more compact
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
          if (state is CustomerLoadingById)
            const ModernLoadingOverlay(msg: "Customer"),
        ],
      );
    }
    return Center(
      child: Text(
        'No data available',
        style: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  void _showCustomerDetailsPopup(
      BuildContext context, CustomerDetails customer) {
    OrientationAwareDialog.show(
      context: context,
      title: customer.fullName,
      subtitle: customer.phoneNumber,
      statusWidget: Text(
        '\$${customer.balanceDue.toStringAsFixed(2)}',
        style: TextStyle(
          color: customer.balanceDue < 0 ? Colors.red[300] : Colors.green[300],
          fontWeight: FontWeight.bold,
        ),
      ),
      tabCount: 3,
      tabLabels: ['Details', 'Transactions', 'Payments'],
      tabViews: [
        _buildDetailsTab(customer),
        _buildTransactionsTab(customer),
        _buildPaymentsTab(customer),
      ],
    );
  }

  Widget _buildDetailsTab(CustomerDetails customer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Phone', customer.phoneNumber),
          _buildDetailRow('Landline', customer.landline),
          _buildDetailRow('Email', customer.fullName),
          _buildDetailRow(
            'Address',
            '${customer.streetAddress1}, ${customer.streetAddress2}\n'
                '${customer.city}, ${customer.zone}\n'
                '${customer.postcode}, ${customer.country}',
          ),
          _buildDetailRow('Total', '\$${customer.total.toStringAsFixed(2)}'),
          _buildDetailRow(
              'Paid', '\$${customer.paidToDate.toStringAsFixed(2)}'),
          _buildDetailRow(
              'Balance', '\$${customer.balanceDue.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          const Text(
            'Contacts',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          ...customer.contacts
              .map((contact) => Card(
                    color: Colors.grey[800],
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      title: Text(
                        '${contact.firstName} ${contact.lastName}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.phoneNumber,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Text(
                            contact.email,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(CustomerDetails customer) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: customer.transactions.length,
      itemBuilder: (context, index) {
        final transaction = customer.transactions[index];
        return Card(
          color: Colors.grey[800],
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              transaction.transaction,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              transaction.dateTime.toString().split(' ')[0],
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.amount < 0
                    ? Colors.red[300]
                    : Colors.green[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab(CustomerDetails customer) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: customer.payments.length,
      itemBuilder: (context, index) {
        final payment = customer.payments[index];
        return Card(
          color: Colors.grey[800],
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              'Payment #${payment.id}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.paymentMethod,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                Text(
                  payment.createdDate.toString().split(' ')[0],
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
            trailing: Text(
              '\$${payment.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
