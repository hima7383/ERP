class ApiEndpoints {
  static const String baseUrl = 'https://erpdevelopment.runasp.net';

  static String getMainAccountsList() => '$baseUrl/Api/Accounts/Account/MainAccountsList';
  static String getAccountTypeById(String accountId) => '$baseUrl/Api/Accounts/Account/GetAccountTypeById/$accountId';
  static String getPrimaryAccountById(String accountId) => '$baseUrl/Api/Accounts/Account/GetPrimaryAccountById/$accountId';
}