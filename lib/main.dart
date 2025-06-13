import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase Core
import 'firebase_options.dart';  // Importa las configuraciones de Firebase generadas automáticamente
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/pages/login.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/pages/signup.dart';
import 'package:mobile_app_inventory_qr/features/inventory/presentation/pages/listado_productos_page.dart';
import 'package:mobile_app_inventory_qr/features/qr/presentation/pages/qr_page.dart';
import 'package:mobile_app_inventory_qr/features/reports/presentation/pages/report_screen.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/boletas_facturas_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/home_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/boleta_form_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/factura_form_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/providers/sales_providers.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/sales_list_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUp()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
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
        path: '/inventory',
        builder: (context, state) => ListadoProductosPage()),
    GoRoute(path: '/qr', builder: (context, state) => const QRPage()),
    GoRoute(
        path: '/reports', builder: (context, state) => const ReporteScreen()),
    GoRoute(
        path: '/sales_list', builder: (context, state) => const SalesListPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: SalesProviders.providers,
      child: MaterialApp.router(
        title: 'Vendify',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Colors.deepPurple,
            secondary: Colors.deepPurple,
            background: const Color(0xFFF8F3FF),
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
          cardTheme: CardTheme(
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
            canPop:
                _router.routerDelegate.currentConfiguration.uri.path == '/login',
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

