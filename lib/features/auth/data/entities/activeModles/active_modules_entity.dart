class CompanyEntity {
  final int companyID;
  final String companyName;
  final String? companyAddress;
  final String companyEmail;
  final String? domain;
  final String? logoImagePath;
  final String password;
  final String tenantId;
  final List<CompanySubscriptionEntity> companySubscriptions;
  final List<CompanyModuleEntity> companyModules;

  CompanyEntity({
    required this.companyID,
    required this.companyName,
    this.companyAddress,
    required this.companyEmail,
    this.domain,
    this.logoImagePath,
    required this.password,
    required this.tenantId,
    required this.companySubscriptions,
    required this.companyModules,
  });

  factory CompanyEntity.fromJson(Map<String, dynamic> json) {
    return CompanyEntity(
      companyID: json['companyID'],
      companyName: json['companyName'],
      companyAddress: json['companyAddress'],
      companyEmail: json['companyEmail'],
      domain: json['domain'],
      logoImagePath: json['logoImagePath'],
      password: json['password'],
      tenantId: json['tenantId'],
      companySubscriptions: (json['companySubscriptions'] as List<dynamic>?)
          ?.map((e) => CompanySubscriptionEntity.fromJson(e))
          .toList() ?? [],
      companyModules: (json['companyModules'] as List<dynamic>?)
          ?.map((e) => CompanyModuleEntity.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyID': companyID,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyEmail': companyEmail,
      'domain': domain,
      'logoImagePath': logoImagePath,
      'password': password,
      'tenantId': tenantId,
      'companySubscriptions': companySubscriptions.map((e) => e.toJson()).toList(),
      'companyModules': companyModules.map((e) => e.toJson()).toList(),
    };
  }
}
class CompanyModuleEntity {
  final int moduleId;
  final dynamic module; // This is null in the response, adjust type if needed
  final int companyId;
  final bool isActive;

  CompanyModuleEntity({
    required this.moduleId,
    this.module,
    required this.companyId,
    required this.isActive,
  });

  factory CompanyModuleEntity.fromJson(Map<String, dynamic> json) {
    return CompanyModuleEntity(
      moduleId: json['moduleId'],
      module: json['module'],
      companyId: json['companyId'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'module': module,
      'companyId': companyId,
      'isActive': isActive,
    };
  }
}
class CompanySubscriptionEntity {
  // Add properties based on what you expect in subscriptions
  // Since the array is empty in the example, I'm leaving this basic
  // You'll need to update this based on your actual subscription data structure

  CompanySubscriptionEntity();

  factory CompanySubscriptionEntity.fromJson(Map<String, dynamic> json) {
    return CompanySubscriptionEntity();
    // Add parsing logic when you know the subscription structure
  }

  Map<String, dynamic> toJson() {
    return {};
    // Add serialization logic when you know the subscription structure
  }
}