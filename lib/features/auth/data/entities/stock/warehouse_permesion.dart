import 'package:flutter/foundation.dart'; // For debugPrint

// Represents an item within a price list - Define fields based on actual API structure
class PriceListItem {
  final int productId;
  final String? productName; // Assuming product name might be included
  final double price;
  // Add other relevant fields: SKU, unit, etc.

  PriceListItem({
    required this.productId,
    this.productName,
    required this.price,
  });

  factory PriceListItem.fromJson(Map<String, dynamic> json) {
    // Implement parsing based on the actual structure of items in the detail response
    return PriceListItem(
      productId: json['productId'] ?? 0,
      productName: json['productName'], // Might be null or not present
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Handle number parsing
    );
  }
}

// Represents the summary data for a price list from the /list endpoint
class PriceListSummary {
  final int priceListId;
  final String priceListName;
  final int numberOfProducts;
  final bool isActive;

  PriceListSummary({
    required this.priceListId,
    required this.priceListName,
    required this.numberOfProducts,
    required this.isActive,
  });

  factory PriceListSummary.fromJson(Map<String, dynamic> json) {
    return PriceListSummary(
      priceListId: json['priceListId'] ?? 0,
      priceListName: json['priceListName'] ?? 'Unknown Price List',
      numberOfProducts: json['numberOfProducts'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }
}

// Represents the full details for a price list from the /{id} endpoint
class PriceListDetails {
  final int priceListId;
  final String priceListName;
  final bool isActive;
  final List<PriceListItem> priceListItems;

  PriceListDetails({
    required this.priceListId,
    required this.priceListName,
    required this.isActive,
    required this.priceListItems,
  });

  factory PriceListDetails.fromJson(Map<String, dynamic> json) {
     try {
      return PriceListDetails(
        priceListId: json['priceListId'] ?? 0,
        priceListName: json['priceListName'] ?? 'Unknown Price List',
        isActive: json['isActive'] ?? false,
        priceListItems: (json['priceListItems'] as List?)
                ?.map((e) => PriceListItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
     } catch (e) {
      debugPrint("Error parsing PriceListDetails JSON: $e \nJSON: $json");
       // Return a default or throw a custom exception
       return PriceListDetails(
         priceListId: json['priceListId'] ?? 0,
         priceListName: 'Error Parsing Details',
         isActive: false,
         priceListItems: [],
       );
     }
  }
}