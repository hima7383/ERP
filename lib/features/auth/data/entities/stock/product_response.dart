import 'package:erp/features/auth/data/entities/stock/prdouct.dart';

class ProductResponse {
  final List<Product> products;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final List<String> messages;
  final bool succeeded;

  ProductResponse({
    required this.products,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.messages,
    required this.succeeded,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      products: (json['data'] as List)
          .map((product) => Product.fromJson(product))
          .toList(),
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalCount: json['totalCount'],
      pageSize: json['pageSize'],
      hasPreviousPage: json['hasPreviousPage'],
      hasNextPage: json['hasNextPage'],
      messages: List<String>.from(json['messages'] ?? []),
      succeeded: json['succeeded'],
    );
  }
}