import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_inventory_qr/core/utils/logger.dart';
import '../data/models/report_models.dart';

/// Excepciones personalizadas para el servicio de reportes
class ReportsException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ReportsException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'ReportsException: $message';
}

/// Servicio para obtener datos de reportes desde Firebase
class ReportsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtener estadísticas de ventas para un usuario
  Future<SalesStatistics> getSalesStatistics(String userId, {DateTimeRange? dateRange}) async {
    try {
      AppLogger.info("Obteniendo estadísticas de ventas para usuario: $userId");
      
      // Consultar ventas del usuario
      Query query = _db.collection('sales').where('userId', isEqualTo: userId);
      
      if (dateRange != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
                     .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end));
      }
      
      final salesSnapshot = await query.orderBy('createdAt', descending: true).get();
      final sales = salesSnapshot.docs.map((doc) => SaleReport.fromFirestore(doc)).toList();

      // Calcular estadísticas
      double totalRevenue = 0;
      int totalInvoices = 0;
      int totalReceipts = 0;
      Map<String, double> monthlyRevenue = {};
      Map<String, int> topProducts = {};

      for (final sale in sales) {
        // Quitar filtro de status
        totalRevenue += sale.total;
        // Contar por tipo de documento
        if (sale.type == '01') {
          totalInvoices++;
        } else if (sale.type == '03') {
          totalReceipts++;
        }
        // Agrupar por mes
        final monthKey = '${sale.createdAt.year}-${sale.createdAt.month.toString().padLeft(2, '0')}';
        monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + sale.total;
        // Contar productos vendidos
        for (final item in sale.items) {
          topProducts[item.description] = (topProducts[item.description] ?? 0) + item.quantity;
        }
      }

      // Obtener las ventas más recientes
      final recentSales = sales.take(10).toList();

      // Ordenar productos más vendidos
      final sortedProducts = topProducts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topProductsMap = Map.fromEntries(sortedProducts.take(10));

      AppLogger.success("Estadísticas de ventas obtenidas exitosamente");
      
      return SalesStatistics(
        totalRevenue: totalRevenue,
        totalSales: sales.length,
        totalInvoices: totalInvoices,
        totalReceipts: totalReceipts,
        monthlyRevenue: monthlyRevenue,
        recentSales: recentSales,
        topProducts: topProductsMap,
      );
    } catch (e) {
      AppLogger.error("Error al obtener estadísticas de ventas", e);
      throw ReportsException('Error al obtener estadísticas de ventas: $e', originalError: e);
    }
  }

  /// Obtener estadísticas de inventario para un usuario
  Future<InventoryStatistics> getInventoryStatistics(String userId) async {
    try {
      AppLogger.info("Obteniendo estadísticas de inventario para usuario: $userId");
      
      // Consultar productos del usuario
      final productsSnapshot = await _db
          .collection('inventories')
          .doc(userId)
          .collection('products')
          .orderBy('fechaCreacion', descending: true)
          .get();

      final products = productsSnapshot.docs
          .map((doc) => ProductReport.fromFirestore(doc))
          .toList();

      // Calcular estadísticas
      int totalProducts = products.length;
      int lowStockProducts = products.where((p) => p.isLowStock).length;
      int outOfStockProducts = products.where((p) => p.isOutOfStock).length;
      double totalInventoryValue = products.fold(0, (sum, p) => sum + p.totalValue);

      // Agrupar por categoría
      Map<String, int> productsByCategory = {};
      for (final product in products) {
        productsByCategory[product.categoria] = (productsByCategory[product.categoria] ?? 0) + product.cantidad;
      }

      // Productos con stock bajo
      final lowStockItems = products.where((p) => p.isLowStock).toList();

      // Productos más movidos (por fecha de actualización)
      final topMovingProducts = products
        ..sort((a, b) => (b.fechaActualizacion ?? b.fechaCreacion)
            .compareTo(a.fechaActualizacion ?? a.fechaCreacion));
      final topMoving = topMovingProducts.take(5).toList();

      AppLogger.success("Estadísticas de inventario obtenidas exitosamente");
      
      return InventoryStatistics(
        totalProducts: totalProducts,
        lowStockProducts: lowStockProducts,
        outOfStockProducts: outOfStockProducts,
        totalInventoryValue: totalInventoryValue,
        productsByCategory: productsByCategory,
        lowStockItems: lowStockItems,
        topMovingProducts: topMoving,
      );
    } catch (e) {
      AppLogger.error("Error al obtener estadísticas de inventario", e);
      throw ReportsException('Error al obtener estadísticas de inventario: $e', originalError: e);
    }
  }

  /// Obtener ventas por rango de fechas
  Future<List<SaleReport>> getSalesByDateRange(String userId, DateTimeRange dateRange) async {
    try {
      AppLogger.info("Obteniendo ventas por rango de fechas para usuario: $userId");
      
      final salesSnapshot = await _db
          .collection('sales')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end))
          .orderBy('createdAt', descending: true)
          .get();

      final sales = salesSnapshot.docs.map((doc) => SaleReport.fromFirestore(doc)).toList();
      
      AppLogger.success("Ventas por rango de fechas obtenidas exitosamente");
      return sales;
    } catch (e) {
      AppLogger.error("Error al obtener ventas por rango de fechas", e);
      throw ReportsException('Error al obtener ventas por rango de fechas: $e', originalError: e);
    }
  }

  /// Obtener productos con stock bajo
  Future<List<ProductReport>> getLowStockProducts(String userId) async {
    try {
      AppLogger.info("Obteniendo productos con stock bajo para usuario: $userId");
      
      final productsSnapshot = await _db
          .collection('inventories')
          .doc(userId)
          .collection('products')
          .where('cantidad', isLessThan: 10)
          .orderBy('cantidad', descending: false)
          .get();

      final products = productsSnapshot.docs
          .map((doc) => ProductReport.fromFirestore(doc))
          .toList();
      
      AppLogger.success("Productos con stock bajo obtenidos exitosamente");
      return products;
    } catch (e) {
      AppLogger.error("Error al obtener productos con stock bajo", e);
      throw ReportsException('Error al obtener productos con stock bajo: $e', originalError: e);
    }
  }

  /// Obtener productos agotados
  Future<List<ProductReport>> getOutOfStockProducts(String userId) async {
    try {
      AppLogger.info("Obteniendo productos agotados para usuario: $userId");
      
      final productsSnapshot = await _db
          .collection('inventories')
          .doc(userId)
          .collection('products')
          .where('cantidad', isEqualTo: 0)
          .get();

      final products = productsSnapshot.docs
          .map((doc) => ProductReport.fromFirestore(doc))
          .toList();
      
      AppLogger.success("Productos agotados obtenidos exitosamente");
      return products;
    } catch (e) {
      AppLogger.error("Error al obtener productos agotados", e);
      throw ReportsException('Error al obtener productos agotados: $e', originalError: e);
    }
  }
} 