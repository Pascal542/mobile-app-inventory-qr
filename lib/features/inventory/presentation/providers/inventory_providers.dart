import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/inventory_bloc.dart';
import '../../../../core/di/dependency_injection.dart';

class InventoryProviders {
  static List<BlocProvider> get providers => [
    BlocProvider<InventoryBloc>(
      create: (context) => DependencyInjection.get<InventoryBloc>(),
    ),
  ];
} 