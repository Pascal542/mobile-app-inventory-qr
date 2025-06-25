import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/bloc/auth_bloc.dart';
import '../../services/reports_service.dart';
import '../../data/models/report_models.dart';

// Events
abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesStatistics extends ReportsEvent {
  final DateTimeRange? dateRange;

  const LoadSalesStatistics({this.dateRange});

  @override
  List<Object?> get props => [dateRange];
}

class LoadInventoryStatistics extends ReportsEvent {}

class LoadSalesByDateRange extends ReportsEvent {
  final DateTimeRange dateRange;

  const LoadSalesByDateRange(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

class LoadLowStockProducts extends ReportsEvent {}

class LoadOutOfStockProducts extends ReportsEvent {}

// States
abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class SalesStatisticsLoaded extends ReportsState {
  final SalesStatistics statistics;

  const SalesStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class InventoryStatisticsLoaded extends ReportsState {
  final InventoryStatistics statistics;

  const InventoryStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class SalesByDateRangeLoaded extends ReportsState {
  final List<SaleReport> sales;

  const SalesByDateRangeLoaded(this.sales);

  @override
  List<Object?> get props => [sales];
}

class LowStockProductsLoaded extends ReportsState {
  final List<ProductReport> products;

  const LowStockProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class OutOfStockProductsLoaded extends ReportsState {
  final List<ProductReport> products;

  const OutOfStockProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// BLoC para manejar la lógica de negocio de los reportes
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsService _reportsService;
  final AuthBloc _authBloc;

  ReportsBloc({
    required ReportsService reportsService,
    required AuthBloc authBloc,
  })  : _reportsService = reportsService,
        _authBloc = authBloc,
        super(ReportsInitial()) {
    on<LoadSalesStatistics>(_onLoadSalesStatistics);
    on<LoadInventoryStatistics>(_onLoadInventoryStatistics);
    on<LoadSalesByDateRange>(_onLoadSalesByDateRange);
    on<LoadLowStockProducts>(_onLoadLowStockProducts);
    on<LoadOutOfStockProducts>(_onLoadOutOfStockProducts);
  }

  String? get _userId {
    final authState = _authBloc.state;
    if (authState is Authenticated) {
      return authState.user.uid.split('_').last;
    }
    return null;
  }

  Future<void> _onLoadSalesStatistics(
    LoadSalesStatistics event,
    Emitter<ReportsState> emit,
  ) async {
    if (_userId == null) {
      emit(const ReportsError('Usuario no autenticado'));
      return;
    }

    try {
      emit(ReportsLoading());
      final statistics = await _reportsService.getSalesStatistics(
        _userId!,
        dateRange: event.dateRange,
      );
      emit(SalesStatisticsLoaded(statistics));
    } catch (e) {
      emit(ReportsError('Error al cargar estadísticas de ventas: $e'));
    }
  }

  Future<void> _onLoadInventoryStatistics(
    LoadInventoryStatistics event,
    Emitter<ReportsState> emit,
  ) async {
    if (_userId == null) {
      emit(const ReportsError('Usuario no autenticado'));
      return;
    }

    try {
      emit(ReportsLoading());
      final statistics = await _reportsService.getInventoryStatistics(_userId!);
      emit(InventoryStatisticsLoaded(statistics));
    } catch (e) {
      emit(ReportsError('Error al cargar estadísticas de inventario: $e'));
    }
  }

  Future<void> _onLoadSalesByDateRange(
    LoadSalesByDateRange event,
    Emitter<ReportsState> emit,
  ) async {
    if (_userId == null) {
      emit(const ReportsError('Usuario no autenticado'));
      return;
    }

    try {
      emit(ReportsLoading());
      final sales = await _reportsService.getSalesByDateRange(_userId!, event.dateRange);
      emit(SalesByDateRangeLoaded(sales));
    } catch (e) {
      emit(ReportsError('Error al cargar ventas por rango de fechas: $e'));
    }
  }

  Future<void> _onLoadLowStockProducts(
    LoadLowStockProducts event,
    Emitter<ReportsState> emit,
  ) async {
    if (_userId == null) {
      emit(const ReportsError('Usuario no autenticado'));
      return;
    }

    try {
      emit(ReportsLoading());
      final products = await _reportsService.getLowStockProducts(_userId!);
      emit(LowStockProductsLoaded(products));
    } catch (e) {
      emit(ReportsError('Error al cargar productos con stock bajo: $e'));
    }
  }

  Future<void> _onLoadOutOfStockProducts(
    LoadOutOfStockProducts event,
    Emitter<ReportsState> emit,
  ) async {
    if (_userId == null) {
      emit(const ReportsError('Usuario no autenticado'));
      return;
    }

    try {
      emit(ReportsLoading());
      final products = await _reportsService.getOutOfStockProducts(_userId!);
      emit(OutOfStockProductsLoaded(products));
    } catch (e) {
      emit(ReportsError('Error al cargar productos agotados: $e'));
    }
  }
} 