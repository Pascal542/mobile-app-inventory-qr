import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/pages/boleta_form_page.dart';
import 'package:mobile_app_inventory_qr/features/sales/presentation/bloc/boleta_bloc.dart';
import 'package:mobile_app_inventory_qr/features/sales/data/models/boleta_response.dart';
import 'package:mobile_app_inventory_qr/features/sales/domain/usecases/get_last_document_number_usecase.dart';
import 'boleta_form_page_test.mocks.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

@GenerateMocks([
  BoletaBloc,
  GetLastDocumentNumberUseCase,
])
void main() {
  late MockBoletaBloc mockBoletaBloc;
  late MockGetLastDocumentNumberUseCase mockGetLastDocumentNumberUseCase;

  setUp(() {
    mockBoletaBloc = MockBoletaBloc();
    mockGetLastDocumentNumberUseCase = MockGetLastDocumentNumberUseCase();

    when(mockBoletaBloc.state).thenReturn(BoletaInitial());
    when(mockBoletaBloc.stream)
        .thenAnswer((_) => Stream.value(BoletaInitial()));
    when(mockGetLastDocumentNumberUseCase.call(
            type: anyNamed('type'), series: anyNamed('series')))
        .thenAnswer((_) async => '000001');
  });

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<BoletaBloc>.value(
            value: mockBoletaBloc,
            child: BoletaFormPage(
                getLastDocumentNumberUseCase: mockGetLastDocumentNumberUseCase),
          ),
        ),
        GoRoute(
          path: '/boletas_facturas',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('BoletaFormPage Tests', () {
    testWidgets('TC-01: Validar campos requeridos',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Enviar Boleta'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Obligatorio'), findsNWidgets(5)); // 5 campos requeridos
    });

    testWidgets('TC-02: Ingresar datos válidos', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(
          find.widgetWithText(TextFormField, 'DNI'), '12345678');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre Cliente'), 'Juan Pérez');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Cantidad'), '2');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio Unitario'), '100');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Producto'), 'Laptop');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('12345678'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
    });

    testWidgets('TC-03: Validar formato de DNI', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(
          find.widgetWithText(TextFormField, 'DNI'), '123'); // DNI inválido
      await tester.tap(find.text('Enviar Boleta'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('El DNI debe tener 8 dígitos'), findsOneWidget);
    });

    testWidgets('TC-04: Validar cantidad positiva',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Cantidad'), '-1');
      await tester.tap(find.text('Enviar Boleta'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('La cantidad debe ser mayor a 0'), findsOneWidget);
    });

    testWidgets('TC-05: Validar precio positivo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio Unitario'), '0');
      await tester.tap(find.text('Enviar Boleta'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('El precio debe ser mayor a 0'), findsOneWidget);
    });

    testWidgets('TC-06: Verificar navegación al enviar boleta exitosa',
        (WidgetTester tester) async {
      // Arrange
      final response = BoletaResponse(
        status: 'ACEPTADO',
        documentId: '123456',
      );
      // Estado inicial
      when(mockBoletaBloc.state).thenReturn(BoletaInitial());
      when(mockBoletaBloc.stream)
          .thenAnswer((_) => Stream.value(BoletaInitial()));
      await tester.pumpWidget(createWidgetUnderTest());

      // Verificar que el formulario se construye correctamente
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Act
      await tester.enterText(
          find.widgetWithText(TextFormField, 'DNI'), '72699727');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre Cliente'), 'Juan Pérez');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Cantidad'), '2');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio Unitario'), '100');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Producto'), 'Laptop');

      // Verificar que los campos tienen los valores correctos
      expect(find.text('72699727'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);

      // Buscar el botón y hacer tap
      final buttonFinder = find.byType(ElevatedButton);
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Cambiar el estado después del tap
      when(mockBoletaBloc.state).thenReturn(BoletaSent(response));
      when(mockBoletaBloc.stream)
          .thenAnswer((_) => Stream.value(BoletaSent(response)));

      // Tap en el botón
      await tester.tap(buttonFinder, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Assert
      expect(mockBoletaBloc.state, isA<BoletaSent>());
    });

    testWidgets('TC-07: Verificar mensaje de error',
        (WidgetTester tester) async {
      // Arrange
      when(mockBoletaBloc.state)
          .thenReturn(BoletaError('Error al enviar boleta'));
      when(mockBoletaBloc.stream).thenAnswer(
          (_) => Stream.value(BoletaError('Error al enviar boleta')));
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(
          find.widgetWithText(TextFormField, 'DNI'), '12345678');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre Cliente'), 'Juan Pérez');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Cantidad'), '2');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio Unitario'), '100');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Producto'), 'Laptop');

      // Hacer scroll manualmente
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap en el botón
      await tester.tap(find.text('Enviar Boleta'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Assert
      expect(mockBoletaBloc.state, isA<BoletaError>());
    });
  });
}
