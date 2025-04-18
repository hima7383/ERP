// bank_account.dart
class BankAccount {
  final int bankAccountID;
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String currency;
  final int status; // 0 or 1
  final int depositPermission; // 0, 1, or 2
  final int withdrawPermission; // 0, 1, or 2
  final List<Employee>? employeesWithDepositPermission;
  final List<Employee>? employeesWithWithdrawPermission;
  final List<dynamic>? rolesWithDepositPermission;
  final List<dynamic>? rolesWithWithdrawPermission;

  BankAccount({
    required this.bankAccountID,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.currency,
    required this.status,
    required this.depositPermission,
    required this.withdrawPermission,
    this.employeesWithDepositPermission,
    this.employeesWithWithdrawPermission,
    this.rolesWithDepositPermission,
    this.rolesWithWithdrawPermission,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      bankAccountID: json['bankAccountID'] as int? ?? 0,
      accountHolderName: json['accountHolderName'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      depositPermission: json['depositPermission'] as int? ?? 0,
      withdrawPermission: json['withdrawPermission'] as int? ?? 0,
      employeesWithDepositPermission:
          json['employeesWhoHaveDepositPermessions'] != null
              ? List<Employee>.from(
                  (json['employeesWhoHaveDepositPermessions'] as List).map(
                    (x) => Employee.fromJson(x as Map<String, dynamic>),
                  ),
                )
              : null,
      employeesWithWithdrawPermission:
          json['employeesWhoHaveWithdrawPermessions'] != null
              ? List<Employee>.from(
                  (json['employeesWhoHaveWithdrawPermessions'] as List).map(
                    (x) => Employee.fromJson(x as Map<String, dynamic>),
                  ),
                )
              : null,
      rolesWithDepositPermission: json['rolesWhoHaveDepositPermessions'] != null
          ? List<dynamic>.from(json['rolesWhoHaveDepositPermessions'] as List)
          : null,
      rolesWithWithdrawPermission: json['rolesWhoHaveWithdrawPermessions'] !=
              null
          ? List<dynamic>.from(json['rolesWhoHaveWithdrawPermessions'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankAccountID': bankAccountID,
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'currency': currency,
      'status': status,
      'depositPermission': depositPermission,
      'withdrawPermission': withdrawPermission,
      'employeesWhoHaveDepositPermessions':
          employeesWithDepositPermission?.map((e) => e.toJson()).toList(),
      'employeesWhoHaveWithdrawPermessions':
          employeesWithWithdrawPermission?.map((e) => e.toJson()).toList(),
      'rolesWhoHaveDepositPermessions': rolesWithDepositPermission,
      'rolesWhoHaveWithdrawPermessions': rolesWithWithdrawPermission,
    };
  }
}

class BankAccountSummary {
  final int bankAccountID;
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String currency;
  final int status;
  final int depositPermission;
  final int withdrawPermission;

  BankAccountSummary({
    required this.bankAccountID,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.currency,
    required this.status,
    required this.depositPermission,
    required this.withdrawPermission,
  });

  factory BankAccountSummary.fromJson(Map<String, dynamic> json) {
    return BankAccountSummary(
      bankAccountID: json['bankAccountID'] as int? ?? 0,
      accountHolderName: json['accountHolderName'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      depositPermission: json['depositPermission'] as int? ?? 0,
      withdrawPermission: json['withdrawPermission'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankAccountID': bankAccountID,
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'currency': currency,
      'status': status,
      'depositPermission': depositPermission,
      'withdrawPermission': withdrawPermission,
    };
  }
}

// employee.dart
class Employee {
  final int employeeID;
  final String firstName;
  final String lastName;
  final String? notes;
  final String? imagePath;
  final dynamic imageFile;
  final String email;
  final int status;
  final String roleID;
  final DateTime dateOfBirth;
  final int gender;
  final String country;
  final String? phoneNumber;
  final String? landline;
  final String? privateEmail;
  final String? address1;
  final String? address2;
  final String? city;
  final String? zone;
  final String? postcode;
  final dynamic jobTypeID;
  final dynamic departmentID;
  final DateTime hireDate;
  final dynamic employmentLevelId;
  final dynamic employmentTypeId;
  final dynamic directManagerId;
  final bool useDefaultFinancialHistory;
  final dynamic role;
  final dynamic department;
  final dynamic jobType;
  final dynamic employmentLevel;
  final dynamic employmentType;
  final dynamic directManager;
  final String tenantId;

  Employee({
    required this.employeeID,
    required this.firstName,
    required this.lastName,
    this.notes,
    this.imagePath,
    this.imageFile,
    required this.email,
    required this.status,
    required this.roleID,
    required this.dateOfBirth,
    required this.gender,
    required this.country,
    this.phoneNumber,
    this.landline,
    this.privateEmail,
    this.address1,
    this.address2,
    this.city,
    this.zone,
    this.postcode,
    this.jobTypeID,
    this.departmentID,
    required this.hireDate,
    this.employmentLevelId,
    this.employmentTypeId,
    this.directManagerId,
    required this.useDefaultFinancialHistory,
    this.role,
    this.department,
    this.jobType,
    this.employmentLevel,
    this.employmentType,
    this.directManager,
    required this.tenantId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeID: json['employeeID'] as int? ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      notes: json['notes'] as String?,
      imagePath: json['imagePath'] as String?,
      imageFile: json['imageFile'],
      email: json['email'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      roleID: json['roleID'] as String? ?? '',
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] as String? ?? '') ??
          DateTime.now(),
      gender: json['gender'] as int? ?? 0,
      country: json['country'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      landline: json['landline'] as String?,
      privateEmail: json['privateEmail'] as String?,
      address1: json['address1'] as String?,
      address2: json['address2'] as String?,
      city: json['city'] as String?,
      zone: json['zone'] as String?,
      postcode: json['postcode'] as String?,
      jobTypeID: json['jobTypeID'],
      departmentID: json['departmentID'],
      hireDate: DateTime.tryParse(json['hireDate'] as String? ?? '') ??
          DateTime.now(),
      employmentLevelId: json['employmentLevelId'],
      employmentTypeId: json['employmentTypeId'],
      directManagerId: json['directManagerId'],
      useDefaultFinancialHistory:
          json['useDefaultFinancialHistory'] as bool? ?? false,
      role: json['role'],
      department: json['department'],
      jobType: json['jobType'],
      employmentLevel: json['employmentLevel'],
      employmentType: json['employmentType'],
      directManager: json['directManager'],
      tenantId: json['tenantId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeID': employeeID,
      'firstName': firstName,
      'lastName': lastName,
      'notes': notes,
      'imagePath': imagePath,
      'imageFile': imageFile,
      'email': email,
      'status': status,
      'roleID': roleID,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'country': country,
      'phoneNumber': phoneNumber,
      'landline': landline,
      'privateEmail': privateEmail,
      'address1': address1,
      'address2': address2,
      'city': city,
      'zone': zone,
      'postcode': postcode,
      'jobTypeID': jobTypeID,
      'departmentID': departmentID,
      'hireDate': hireDate.toIso8601String(),
      'employmentLevelId': employmentLevelId,
      'employmentTypeId': employmentTypeId,
      'directManagerId': directManagerId,
      'useDefaultFinancialHistory': useDefaultFinancialHistory,
      'role': role,
      'department': department,
      'jobType': jobType,
      'employmentLevel': employmentLevel,
      'employmentType': employmentType,
      'directManager': directManager,
      'tenantId': tenantId,
    };
  }

  String get fullName => '$firstName $lastName';
}
