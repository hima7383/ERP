import 'package:erp/Core/widgets/genricori_dialogbox.dart';
import 'package:erp/features/auth/data/entities/clients/clients.dart';
import 'package:erp/features/auth/logic/clients/clients_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Customers', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0.0,
      ),
      body: BlocConsumer<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerListLoaded && state.selectedCustomer != null) {
            context.read<CustomerCubit>().resetSelectedCustomer();
            _showCustomerDetailsPopup(context, state.selectedCustomer!);
          }
        },
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ));
          }
          if (state is CustomerError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is! CustomerListLoaded) {
            return const Center(
                child: Text(
              'No customers found',
              style: TextStyle(color: Colors.white),
            ));
          }

          return Column(
            children: [
              _buildSearchBar(context),
              Expanded(child: _buildCustomerList(state,context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by ID, Phone, or Email',
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[900],
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (query) {
          context.read<CustomerCubit>().searchCustomers(query);
        },
      ),
    );
  }

  Widget _buildCustomerList(CustomerListLoaded state, BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CustomerCubit>().fetchCustomers();
      },
      child: ListView.builder(
        itemCount: state.filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = state.filteredCustomers[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              title: Text(
                state.nameCache[customer.customerId] ??
                    'Customer #${customer.customerId}',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                customer.phoneNumber,
                style: TextStyle(color: Colors.grey[400]),
              ),
              onTap: () {
                context
                    .read<CustomerCubit>()
                    .fetchCustomerById(customer.customerId);
              },
            ),
          );
        },
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
