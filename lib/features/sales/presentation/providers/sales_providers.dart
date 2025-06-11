import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/boleta_bloc.dart';
import '../bloc/factura_bloc.dart';
import '../../data/datasources/sales_api_client.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/usecases/send_boleta_usecase.dart';
import '../../domain/usecases/get_last_document_number_usecase.dart';
import '../../domain/usecases/get_boleta_status_usecase.dart';
import '../../domain/usecases/get_boleta_pdf_usecase.dart';
import '../../domain/usecases/send_factura_usecase.dart';

class SalesProviders {
  static List<BlocProvider> providers = [
    BlocProvider<BoletaBloc>(
      create: (context) {
        final apiClient = SalesApiClient();
        final repository = SalesRepositoryImpl(apiClient: apiClient);
        return BoletaBloc(
          sendBoletaUseCase: SendBoletaUseCase(repository),
          getLastDocumentNumberUseCase: GetLastDocumentNumberUseCase(repository),
          getBoletaStatusUseCase: GetBoletaStatusUseCase(repository),
          getBoletaPdfUseCase: GetBoletaPdfUseCase(repository),
        );
      },
    ),
    BlocProvider<FacturaBloc>(
      create: (context) {
        final apiClient = SalesApiClient();
        final repository = SalesRepositoryImpl(apiClient: apiClient);
        return FacturaBloc(
          sendFacturaUseCase: SendFacturaUseCase(repository),
          getLastDocumentNumberUseCase: GetLastDocumentNumberUseCase(repository),
        );
      },
    ),
  ];
} 