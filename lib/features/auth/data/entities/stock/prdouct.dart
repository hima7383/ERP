class Product {
  final int id;
  final String name;
  final String description;
  final String internalNotes;
  final double purchasePrice;
  final double sellPrice;
  final double lowestSellingPrice;
  final int status; // 0 for inactive, 1 for active
  final List<int> categoriesIds;
  final String? imagePath;
  final int productOrService; // 0 for product, 1 for service
  final int? stockQuantity;
  final int? minAmountBeforeNotify; // Corrected field name
  final int? supplierId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.internalNotes,
    required this.purchasePrice,
    required this.sellPrice,
    required this.lowestSellingPrice,
    required this.status,
    required this.categoriesIds,
    this.imagePath,
    required this.productOrService,
    this.stockQuantity,
    this.minAmountBeforeNotify,
    this.supplierId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0, // Fallback for null id
      name: json['name'] ?? 'Unknown Product', // Fallback for null name
      description: json['description'] ?? '', // Fallback for null description
      internalNotes:
          json['internalNotes'] ?? '', // Fallback for null internalNotes
      purchasePrice: json['purchasePrice']?.toDouble() ??
          0.0, // Fallback for null purchasePrice
      sellPrice:
          json['sellPrice']?.toDouble() ?? 0.0, // Fallback for null sellPrice
      lowestSellingPrice: json['lowestSellingPrice']?.toDouble() ??
          0.0, // Fallback for null lowestSellingPrice
      status: json['status'] ?? 0, // Fallback for null status
      categoriesIds: List<int>.from(
          json['categoriesIds'] ?? []), // Fallback for null categoriesIds
      imagePath: json['imagePath'], // Nullable field
      productOrService:
          json['productOrService'] ?? 0, // Fallback for null productOrService
      stockQuantity: json['stockQuantity'], // Nullable field
      minAmountBeforeNotify:
          json['minAmountBeforNotefy'], // Match API response field name
      supplierId: json['supplierId'], // Nullable field
    );
  }
}

class ProductDetailEntity {
  final int productId; // Match API response field name
  final String productName; // Match API response field name
  final String description;
  final double purchasePrice;
  final double sellPrice;
  final double lowestSellingPrice;
  final int stockQuantity;
  final int minAmountBeforNotefy; // Match API response field name
  final bool isActive; // Match API response field name
  final String? imagePath;
  final List<dynamic> categories; // Match API response field name
  final String imageFile; // Match API response field name

  ProductDetailEntity({
    required this.productId,
    required this.productName,
    required this.description,
    required this.purchasePrice,
    required this.sellPrice,
    required this.lowestSellingPrice,
    required this.stockQuantity,
    required this.minAmountBeforNotefy,
    required this.isActive,
    this.imagePath,
    required this.categories,
    required this.imageFile,
  });

  factory ProductDetailEntity.fromJson(Map<String, dynamic> json) {
    return ProductDetailEntity(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? 'Unknown Product',
      description: json['description'] ?? '',
      purchasePrice: json['purchasePrice']?.toDouble() ?? 0.0,
      sellPrice: json['sellPrice']?.toDouble() ?? 0.0,
      lowestSellingPrice: json['lowestSellingPrice']?.toDouble() ?? 0.0,
      stockQuantity: json['stockQuantity'] ?? 0,
      minAmountBeforNotefy: json['minAmountBeforNotefy'] ?? 0,
      isActive: json['isActive'] ?? false,
      imagePath: json['imagePath'],
      categories: json['categories'] ?? [],
      imageFile: json['imageFile'] ?? '',
    );
  }
}
