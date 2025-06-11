import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/send_factura_usecase.dart';
import '../../data/models/boleta_request.dart';
import '../../data/models/boleta_response.dart';
import '../../domain/usecases/get_last_document_number_usecase.dart';
import '../../data/datasources/sales_firestore_service.dart';

// Events
abstract class FacturaEvent extends Equatable {
  const FacturaEvent();
  @override
  List<Object> get props => [];
}

class SendFacturaEvent extends FacturaEvent {
  final BoletaRequest request;
  const SendFacturaEvent(this.request);
  @override
  List<Object> get props => [request];
}

class GetLastDocumentNumberEvent extends FacturaEvent {
  final String type;
  final String series;

  const GetLastDocumentNumberEvent({
    required this.type,
    required this.series,
  });

  @override
  List<Object> get props => [type, series];
}

// States
abstract class FacturaState extends Equatable {
  const FacturaState();
  @override
  List<Object> get props => [];
}

class FacturaInitial extends FacturaState {}
class FacturaLoading extends FacturaState {}
class FacturaSent extends FacturaState {
  final BoletaResponse response;
  const FacturaSent(this.response);
  @override
  List<Object> get props => [response];
}
class FacturaError extends FacturaState {
  final String message;
  const FacturaError(this.message);
  @override
  List<Object> get props => [message];
}

class LastDocumentNumberLoaded extends FacturaState {
  final String number;
  const LastDocumentNumberLoaded(this.number);
  @override
  List<Object> get props => [number];
}

// BLoC
class FacturaBloc extends Bloc<FacturaEvent, FacturaState> {
  final SendFacturaUseCase _sendFacturaUseCase;
  final GetLastDocumentNumberUseCase _getLastDocumentNumberUseCase;
  FacturaBloc({
    required SendFacturaUseCase sendFacturaUseCase,
    required GetLastDocumentNumberUseCase getLastDocumentNumberUseCase,
  })  : _sendFacturaUseCase = sendFacturaUseCase,
        _getLastDocumentNumberUseCase = getLastDocumentNumberUseCase,
        super(FacturaInitial()) {
    on<SendFacturaEvent>(_onSendFactura);
    on<GetLastDocumentNumberEvent>(_onGetLastDocumentNumber);
  }

  Future<void> _onSendFactura(
    SendFacturaEvent event,
    Emitter<FacturaState> emit,
  ) async {
    try {
      emit(FacturaLoading());
      final response = await _sendFacturaUseCase(event.request);

      // Save sale metadata to Firestore (like boleta)
      final fileName = event.request.fileName;
      final docId = fileName.split('-').sublist(2).join('-');
      final data = response.toJson();
      data.remove('status');
      await SalesFirestoreService.saveSale({
        ...data,
        'fileName': fileName,
        'type': event.request.documentBody.invoiceTypeCode,
        'issueTime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      }, docId);

      emit(FacturaSent(response));
    } catch (e) {
      emit(FacturaError(e.toString()));
    }
  }

  Future<void> _onGetLastDocumentNumber(
    GetLastDocumentNumberEvent event,
    Emitter<FacturaState> emit,
  ) async {
    try {
      emit(FacturaLoading());
      final number = await _getLastDocumentNumberUseCase(
        type: event.type,
        series: event.series,
      );
      emit(LastDocumentNumberLoaded(number));
    } catch (e) {
      emit(FacturaError(e.toString()));
    }
  }
} 