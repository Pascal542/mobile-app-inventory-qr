import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para representar una venta en los reportes
class SaleReport {
  final String documentId;
  final String type;
  final String status;
  final String customerName;
  final String customerRuc;
  final double total;
  final List<SaleItem> items;
  final DateTime createdAt;
  final String? fileName;

  SaleReport({
    required this.documentId,
    required this.type,
    required this.status,
    required this.customerName,
    required this.customerRuc,
    required this.total,
    required this.items,
    required this.createdAt,
    this.fileName,
  });

  factory SaleReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return SaleReport(
      documentId: doc.id,
      type: data['type']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      customerName: data['customerName']?.toString() ?? '',
      customerRuc: data['customerRuc']?.toString() ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => SaleItem.fromMap(item))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fileName: data['fileName']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'type': type,
      'status': status,
      'customerName': customerName,
      'customerRuc': customerRuc,
      'total': total,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'fileName': fileName,
    };
  }
}

/// Modelo para representar un item de venta
class SaleItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  SaleItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      description: map['description']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}

/// Modelo para estadísticas de ventas
class SalesStatistics {
  final double totalRevenue;
  final int totalSales;
  final int totalInvoices;
  final int totalReceipts;
  final Map<String, double> monthlyRevenue;
  final List<SaleReport> recentSales;
  final Map<String, int> topProducts;

  SalesStatistics({
    required this.totalRevenue,
    required this.totalSales,
    required this.totalInvoices,
    required this.totalReceipts,
    required this.monthlyRevenue,
    required this.recentSales,
    required this.topProducts,
  });
}

/// Modelo para estadísticas de inventario
class InventoryStatistics {
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double totalInventoryValue;
  final Map<String, int> productsByCategory;
  final List<ProductReport> lowStockItems;
  final List<ProductReport> topMovingProducts;

  InventoryStatistics({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalInventoryValue,
    required this.productsByCategory,
    required this.lowStockItems,
    required this.topMovingProducts,
  });
}

/// Modelo para reporte de producto
class ProductReport {
  final String id;
  final String nombre;
  final int cantidad;
  final String categoria;
  final double precio;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  ProductReport({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.categoria,
    required this.precio,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory ProductReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return ProductReport(
      id: doc.id,
      nombre: data['nombre']?.toString() ?? '',
      cantidad: (data['cantidad'] as num?)?.toInt() ?? 0,
      categoria: data['categoria']?.toString() ?? '',
      precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  double get totalValue => cantidad * precio;
  
  bool get isLowStock => cantidad < 10;
  
  bool get isOutOfStock => cantidad == 0;
} 