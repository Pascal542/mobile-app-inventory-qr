import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/boleta_bloc.dart';
import '../bloc/factura_bloc.dart';
import '../../../../core/di/dependency_injection.dart';

class SalesProviders {
  static List<BlocProvider> get providers => [
    BlocProvider<BoletaBloc>(
      create: (context) => DependencyInjection.get<BoletaBloc>(),
    ),
    BlocProvider<FacturaBloc>(
      create: (context) => DependencyInjection.get<FacturaBloc>(),
    ),
  ];
} 