import 'package:get_it/get_it.dart';
import '../../features/sales/data/datasources/sales_api_client.dart';
import '../../features/sales/data/repositories/sales_repository_impl.dart';
import '../../features/sales/domain/repositories/sales_repository.dart';
import '../../features/sales/domain/usecases/send_boleta_usecase.dart';
import '../../features/sales/domain/usecases/get_last_document_number_usecase.dart';
import '../../features/sales/domain/usecases/get_boleta_status_usecase.dart';
import '../../features/sales/domain/usecases/send_factura_usecase.dart';
import '../../features/sales/presentation/bloc/boleta_bloc.dart';
import '../../features/sales/presentation/bloc/factura_bloc.dart';
import '../../features/inventory/services/firestore_service.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../core/data/sql.dart';
import '../../features/qr/data/datasources/qr_firestore_service.dart';
import '../../features/qr/data/repositories/qr_repository_impl.dart';
import '../../features/qr/domain/repositories/qr_repository.dart';
import '../../features/qr/domain/usecases/delete_qr_usecase.dart';
import '../../features/qr/domain/usecases/get_qr_image_url_usecase.dart';
import '../../features/qr/domain/usecases/upload_qr_usecase.dart';
import '../../features/qr/presentation/bloc/qr_bloc.dart';
import '../../features/reports/services/reports_service.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';

/// Contenedor global de dependencias usando GetIt
final GetIt getIt = GetIt.instance;

/// Configuración de dependency injection
class DependencyInjection {
  /// Inicializar todas las dependencias
  static Future<void> init() async {
    // Core services
    await _initCoreServices();
    
    // Data sources
    await _initDataSources();
    
    // Repositories
    await _initRepositories();
    
    // Use cases
    await _initUseCases();
    
    // BLoCs
    await _initBlocs();
  }

  /// Inicializar servicios core
  static Future<void> _initCoreServices() async {
    // Database helper
    getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
    
    // Firestore service
    getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
    
    // Reports service
    getIt.registerLazySingleton<ReportsService>(() => ReportsService());
  }

  /// Inicializar data sources
  static Future<void> _initDataSources() async {
    // Sales API Client
    getIt.registerLazySingleton<SalesApiClient>(() => SalesApiClient());

    // QR Firestore Service
    getIt.registerLazySingleton<QrFirestoreService>(() => QrFirestoreService());
  }

  /// Inicializar repositories
  static Future<void> _initRepositories() async {
    // Sales Repository
    getIt.registerLazySingleton<SalesRepository>(
      () => SalesRepositoryImpl(apiClient: getIt<SalesApiClient>()),
    );
    
    // Auth Repository
    getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());

    // QR Repository
    getIt.registerLazySingleton<QrRepository>(
      () => QrRepositoryImpl(getIt<QrFirestoreService>()),
    );
  }

  /// Inicializar use cases
  static Future<void> _initUseCases() async {
    // Sales Use Cases
    getIt.registerLazySingleton<SendBoletaUseCase>(
      () => SendBoletaUseCase(
        getIt<SalesRepository>(),
        getIt<GetLastDocumentNumberUseCase>(),
      ),
    );
    
    getIt.registerLazySingleton<GetLastDocumentNumberUseCase>(
      () => GetLastDocumentNumberUseCase(getIt<SalesRepository>()),
    );
    
    getIt.registerLazySingleton<GetBoletaStatusUseCase>(
      () => GetBoletaStatusUseCase(getIt<SalesRepository>()),
    );
    
    getIt.registerLazySingleton<SendFacturaUseCase>(
      () => SendFacturaUseCase(
        getIt<SalesRepository>(),
        getIt<GetLastDocumentNumberUseCase>(),
      ),
    );

    // QR Use Cases
    getIt.registerLazySingleton<GetQrImageUrlUseCase>(
        () => GetQrImageUrlUseCase(getIt<QrRepository>()));
    getIt.registerLazySingleton<UploadQrUseCase>(
        () => UploadQrUseCase(getIt<QrRepository>()));
    getIt.registerLazySingleton<DeleteQrUseCase>(
        () => DeleteQrUseCase(getIt<QrRepository>()));
  }

  /// Inicializar BLoCs
  static Future<void> _initBlocs() async {
    // Auth BLoC
    getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(
      authRepository: getIt<AuthRepository>(),
    ));
    
    // Sales BLoCs
    getIt.registerFactory<BoletaBloc>(() => BoletaBloc(
      sendBoletaUseCase: getIt<SendBoletaUseCase>(),
      getLastDocumentNumberUseCase: getIt<GetLastDocumentNumberUseCase>(),
      getBoletaStatusUseCase: getIt<GetBoletaStatusUseCase>(),
      authBloc: getIt<AuthBloc>(),
    ));
    
    getIt.registerFactory<FacturaBloc>(() => FacturaBloc(
      sendFacturaUseCase: getIt<SendFacturaUseCase>(),
      getLastDocumentNumberUseCase: getIt<GetLastDocumentNumberUseCase>(),
      getBoletaStatusUseCase: getIt<GetBoletaStatusUseCase>(),
      authBloc: getIt<AuthBloc>(),
    ));
    
    // Inventory BLoC
    getIt.registerFactory<InventoryBloc>(() => InventoryBloc(
      firestoreService: getIt<FirestoreService>(),
      authBloc: getIt<AuthBloc>(),
    ));

    // QR BLoC
    getIt.registerFactory<QrBloc>(() => QrBloc(
          authBloc: getIt<AuthBloc>(),
          getQrImageUrlUseCase: getIt<GetQrImageUrlUseCase>(),
          uploadQrUseCase: getIt<UploadQrUseCase>(),
          deleteQrUseCase: getIt<DeleteQrUseCase>(),
        ));
    
    // Reports BLoC
    getIt.registerFactory<ReportsBloc>(() => ReportsBloc(
      reportsService: getIt<ReportsService>(),
      authBloc: getIt<AuthBloc>(),
    ));
  }

  /// Limpiar todas las dependencias (útil para testing)
  static Future<void> reset() async {
    await getIt.reset();
  }

  /// Verificar si una dependencia está registrada
  static bool isRegistered<T extends Object>() {
    return getIt.isRegistered<T>();
  }

  /// Obtener una dependencia
  static T get<T extends Object>() {
    return getIt<T>();
  }

  /// Obtener una dependencia de forma segura
  static T? getSafe<T extends Object>() {
    if (isRegistered<T>()) {
      return get<T>();
    }
    return null;
  }
}