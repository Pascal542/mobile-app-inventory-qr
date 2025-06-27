import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase configuration
import 'core/config/firebase_config.dart';

// Environment configuration
import 'core/config/env_config.dart';
import 'core/utils/logger.dart';

// Dependency injection
import 'core/di/dependency_injection.dart';

// Auth features
import 'package:mobile_app_inventory_qr/features/auth/presentation/pages/login.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/pages/signup_page.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/pages/user_details_form.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/pages/referral_page.dart';

// Inventory features
import 'package:mobile_app_inventory_qr/features/inventory/presentation/pages/agregar_producto_page.dart';
import 'package:mobile_app_inventory_qr/features/inventory/presentation/pages/inventory_page.dart';
import 'package:mobile_app_inventory_qr/features/inventory/presentation/pages/listado_productos_page.dart';
import 'package:mobile_app_inventory_qr/features/inventory/presentation/pages/modificar_producto_page.dart';
import 'package:mobile_app_inventory_qr/features/inventory/data/models/producto.dart';
import 'package:mobile_app_inventory_qr/features/inventory/presentation/pages/inventory_shell.dart';

// Sales features
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/home_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/boletas_facturas_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/boleta_form_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/factura_form_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/sales_list_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/feedback_webview_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/providers/sales_providers.dart';

// QR features
import 'package:mobile_app_inventory_qr/features/qr/presentation/pages/qr_page.dart';

// Reports features
import 'package:mobile_app_inventory_qr/features/reports/presentation/pages/report_page.dart';
import 'package:mobile_app_inventory_qr/features/reports/data/general.dart';
import 'package:mobile_app_inventory_qr/features/reports/data/inventario.dart';
import 'package:mobile_app_inventory_qr/features/reports/data/pagos.dart';
import 'package:mobile_app_inventory_qr/features/reports/data/generar_pdf.dart';
import 'package:mobile_app_inventory_qr/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:mobile_app_inventory_qr/features/reports/presentation/providers/reports_providers.dart';

Future<void> actualizarReferidosParaUsuariosAntiguos() async {
  final users = await FirebaseFirestore.instance.collection('users').get();
  for (final doc in users.docs) {
    final data = doc.data();
    if (!data.containsKey('referralCode')) {
      await doc.reference.update({
        'referralCode': data['uid'] ?? doc.id,
        'referralCount': 0,
      });
    }
  }
}

Future<void> corregirCodigosDeReferidoExistentes() async {
  final users = await FirebaseFirestore.instance.collection('users').get();
  for (final doc in users.docs) {
    final data = doc.data();
    final currentReferralCode = data['referralCode'] as String?;
    final uid = data['uid'] as String?;

    if (currentReferralCode != null &&
        uid != null &&
        currentReferralCode != uid) {
      print(
          '[DEBUG] Corrigiendo código de referido para usuario: ${data['email']}');
      print('[DEBUG] Código actual: $currentReferralCode');
      print('[DEBUG] Nuevo código (UID): $uid');

      await doc.reference.update({
        'referralCode': uid,
      });
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await EnvConfig.load();
    AppLogger.success("Environment variables loaded successfully");
  } catch (e) {
    AppLogger.warning("Could not load .env file, using default values: $e");
  }

  // Initialize dependency injection
  try {
    await DependencyInjection.init();
    AppLogger.success("Dependency injection initialized successfully");
  } catch (e) {
    AppLogger.error("Error initializing dependency injection", e);
  }

  // Initialize Firebase with dynamic configuration
  try {
    await FirebaseConfig.initializeApp();
    AppLogger.success("Firebase initialized successfully");

    // Log Firebase configuration info for debugging
    final firebaseInfo = FirebaseConfig.debugInfo;
    AppLogger.info("Firebase configuration: $firebaseInfo");
  } catch (e) {
    AppLogger.error("Error initializing Firebase", e);
    // Continue app execution even if Firebase fails
  }

  await actualizarReferidosParaUsuariosAntiguos();
  await corregirCodigosDeReferidoExistentes();

  runApp(const MyApp());
}

// GoRouter configuration
final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth routes
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordPage()),
    GoRoute(
        path: '/user_details',
        builder: (context, state) => const UserDetailsForm()),

    // Main routes
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),

    // Sales routes
    GoRoute(
        path: '/boletas_facturas',
        builder: (context, state) => const BoletasFacturasPage()),
    GoRoute(
        path: '/boleta_form',
        builder: (context, state) => const BoletaFormPage()),
    GoRoute(
        path: '/factura_form',
        builder: (context, state) => const FacturaFormPage()),
    GoRoute(
        path: '/sales_list',
        builder: (context, state) => const SalesListPage()),

    // Inventory routes
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider(
          create: (context) => DependencyInjection.get<InventoryBloc>(),
          child: InventoryShell(child: child),
        );
      },
      routes: [
        GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryPage()),
        GoRoute(
            path: '/agregar_producto',
            builder: (context, state) => const AgregarProductoPage()),
        GoRoute(
            path: '/listado_productos',
            builder: (context, state) => const ListadoProductosPage()),
        GoRoute(
            path: '/modificar_producto',
            builder: (context, state) {
              final producto = state.extra as Producto;
              return ModificarProductoPage(producto: producto);
            }),
      ],
    ),

    // QR routes
    GoRoute(path: '/qr', builder: (context, state) => const QRPage()),

    // Reports routes
    GoRoute(path: '/reports', builder: (context, state) => const ReportPage()),
    GoRoute(
        path: '/reporte_general',
        builder: (context, state) => const ReporteGeneral()),
    GoRoute(
        path: '/reporte_inventario',
        builder: (context, state) => const ReporteInventario()),
    GoRoute(
        path: '/reporte_pagos',
        builder: (context, state) => const ReportePagos()),
    GoRoute(
        path: '/reporte_pdf', builder: (context, state) => const GenerarPDF()),
    GoRoute(
      path: '/referidos',
      builder: (context, state) => const ReferralPage(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackWebViewPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC - disponible globalmente
        BlocProvider<AuthBloc>(
          create: (context) => DependencyInjection.get<AuthBloc>(),
        ),
        // Sales providers
        ...SalesProviders.providers,
        // Reports providers
        ...ReportsProviders.providers,
      ],
      child: MaterialApp.router(
        title: 'Vendify',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Colors.deepPurple,
            secondary: Colors.deepPurple,
            surface: const Color(0xFFF8F3FF),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F3FF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple),
            ),
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
            headlineMedium: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
        routerConfig: _router,
        builder: (context, child) {
          return PopScope(
            canPop: _router.routerDelegate.currentConfiguration.uri.path ==
                '/login',
            onPopInvoked: (didPop) async {
              if (!didPop) {
                context.go('/home');
              }
            },
            child: child!,
          );
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', ''),
        ],
      ),
    );
  }
}
