# ERP App

A comprehensive ERP application built with Flutter to manage various company modules, including inventory, purchases, sales, client management, accounts, and finance.

## Features

*   **Authentication**: Secure login and registration for companies.
*   **Dashboard (Home Screen)**: Central navigation hub providing access to all active modules based on company settings.
*   **Inventory Management (Stock)**:
    *   **Products**: Manage product and service details, including descriptions, pricing, stock levels (for products), and status (for services). View product images and search/paginate through inventory.
    *   **Price Lists**: Manage and view different price lists. Each price list displays its name, number of products, and status (active/inactive). Details include a list of products with their specific prices under that price list. Search functionality is available.
    *   **Warehouses**: Oversee warehouse information. Lists warehouses with names and addresses. Detailed view includes address, counts of stock transactions, receiving and delivery vouchers, and separate tabs to list individual receiving and delivery vouchers with their dates and notes. Search is supported.
*   **Accounts**:
    *   **Chart of Accounts**: View a hierarchical list of company accounts with their balances. Search functionality included.
    *   **Assets**: Track company assets. Displays a list of assets with their account name, creation date, and current balance. Allows searching for assets. Tapping an asset reveals its account sequence (related account names).
    *   **Journal Entries (Daily Entries)**: Manage daily financial journal entries. Lists entries with ID, total debit/credit difference, description, date, and item count. Searchable. Detailed view shows full entry data including line items with account names, debit/credit amounts, and cost centers.
*   **Client Management**:
    *   **Customers**: List, search, and view detailed customer information, including contact details, balance due, transaction history, and payment records.
*   **Purchase Management**:
    *   **Purchase Invoices**: Track and manage purchase invoices. View details, items, amounts, payment status, and print invoices to PDF.
    *   **Purchase Invoice Refunds**: Handle refunds for purchase invoices. Lists refund invoices with ID, payment status, date, and total amount. Searchable. Detailed view includes supplier information, journal entry ID, a list of returned items (product, price, quantity, total), notes, and an option to print the refund as a PDF.
    *   **Debit Notes**: Manage debit notes issued to suppliers. Lists notes with ID, payment status, date, and total amount. Searchable. Detailed view shows supplier, journal entry ID, itemized list (product, price, quantity, total), notes, and overall status.
    *   **Suppliers**: Manage supplier information. Lists suppliers with name, ID, and account ID. Searchable. Detailed view includes tabs for 'Details' (contact info, balance due), 'Transactions' (history of transactions with amounts and balance), and 'Payments' (list of payments made).
*   **Finance Management**:
    *   **Bank Accounts**: Manage bank account details, view permissions (deposit/withdraw) for employees, and filter accounts.
    *   **Expenses**: Track company expenses. Lists expenses with code number, amount, currency, date, and treasury. Searchable. Detailed view includes supplier name and a breakdown of multi-account expense items (account, amount, tax).
    *   **Receipts**: Manage received payments. Lists receipts with code number, amount, currency, date, and treasury. Searchable. Detailed view includes a description and a breakdown of multi-account receipt items (account, tax percentage, amount, tax amount).
*   **Sales Management**:
    *   **Sales Invoices**: Create, list, search, and manage sales invoices. View detailed invoice information with item and payment tabs.
    *   **Recurring Invoices**: Set up and manage invoices that recur automatically. Lists recurring profiles with subscription name, customer, next invoice date, total amount, and status (active/inactive). Searchable. Detailed view includes tabs for 'Details' (frequency, occurrences, payment settings) and 'Items' (products/services included).
    *   **Quotations**: Create and manage sales quotations. Lists quotations with ID, customer name, expiry date, total amount, and status (e.g., Sent, Accepted). Searchable. Detailed view includes tabs for 'Details' (dates, status, totals) and 'Items' (products/services quoted with prices and quantities).
    *   **Sales Invoice Refunds**: Process refunds for sales invoices. Lists refund invoices with ID, payment status, date, and total amount. Searchable. Detailed view includes tabs for 'Items' (notes, overall totals, and list of refunded items with product details) and 'Payments' (list of associated client payments).

## Technology Stack

*   **Flutter & Dart**: For cross-platform mobile application development.
*   **(Potentially) Bloc/Cubit**: For state management (inferred from file contents).
*   **(Potentially) http package**: For making API calls.
*   *(Please add any other relevant technologies or key packages used)*

## Getting Started

### Prerequisites

*   Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
*   Dart SDK: (Comes with Flutter)
*   An IDE like Android Studio or VS Code with Flutter plugins.
*   *(Are there any other specific prerequisites? e.g., backend server setup, API keys)*

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd <your-project-directory>
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

### Running the Application

1.  **Ensure an emulator is running or a device is connected.**
2.  **Run the app:**
    ```bash
    flutter run
    ```
    *(Are there any specific configurations needed before running, like setting up environment variables or a backend endpoint?)*
