import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reports_bloc.dart';
import '../../../../core/di/dependency_injection.dart';

/// Providers para el módulo de reportes
class ReportsProviders {
  /// Lista de providers para el módulo de reportes
  static List<BlocProvider> get providers => [
    BlocProvider<ReportsBloc>(
      create: (context) => DependencyInjection.get<ReportsBloc>(),
    ),
  ];
} 