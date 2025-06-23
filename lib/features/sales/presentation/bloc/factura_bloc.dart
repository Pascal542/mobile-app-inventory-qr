import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/send_factura_usecase.dart';
import '../../data/models/boleta_request.dart';
import '../../data/models/boleta_response.dart';
import '../../domain/usecases/get_last_document_number_usecase.dart';
import '../../domain/usecases/get_boleta_status_usecase.dart';
import '../../data/datasources/sales_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

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

class CheckFacturaStatusEvent extends FacturaEvent {
  final String apiDocumentId;
  final String firestoreDocumentId;

  const CheckFacturaStatusEvent({
    required this.apiDocumentId,
    required this.firestoreDocumentId,
  });

  @override
  List<Object> get props => [apiDocumentId, firestoreDocumentId];
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

class FacturaSuccess extends FacturaState {
  final String message;
  const FacturaSuccess(this.message);
  @override
  List<Object> get props => [message];
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

class FacturaStatusUpdated extends FacturaState {
  final BoletaDocumentStatus status;
  const FacturaStatusUpdated(this.status);
  @override
  List<Object> get props => [status];
}

class FacturaStatusChecked extends FacturaState {
  final String status;
  const FacturaStatusChecked(this.status);
  @override
  List<Object> get props => [status];
}

// BLoC
class FacturaBloc extends Bloc<FacturaEvent, FacturaState> {
  final SendFacturaUseCase _sendFacturaUseCase;
  final GetLastDocumentNumberUseCase _getLastDocumentNumberUseCase;
  final GetBoletaStatusUseCase _getBoletaStatusUseCase;
  final AuthBloc _authBloc;

  FacturaBloc({
    required SendFacturaUseCase sendFacturaUseCase,
    required GetLastDocumentNumberUseCase getLastDocumentNumberUseCase,
    required GetBoletaStatusUseCase getBoletaStatusUseCase,
    required AuthBloc authBloc,
  })  : _sendFacturaUseCase = sendFacturaUseCase,
        _getLastDocumentNumberUseCase = getLastDocumentNumberUseCase,
        _getBoletaStatusUseCase = getBoletaStatusUseCase,
        _authBloc = authBloc,
        super(FacturaInitial()) {
    on<SendFacturaEvent>(_onSendFactura);
    on<GetLastDocumentNumberEvent>(_onGetLastDocumentNumber);
    on<CheckFacturaStatusEvent>(_onCheckFacturaStatus);
  }

  Future<void> _onSendFactura(
    SendFacturaEvent event,
    Emitter<FacturaState> emit,
  ) async {
    emit(FacturaLoading());
    try {
      final (response, newDocId) = await _sendFacturaUseCase(event.request);
      developer.log('Respuesta de la API al enviar factura: ${response.toJson()}', name: 'FacturaBloc');

      final state = _authBloc.state;
      if (state is Authenticated) {
        final userId = state.user.uid.split('_').last;
        final docBody = event.request.documentBody;
        final saleData = {
          'documentId': newDocId,
          'type': docBody.invoiceTypeCode,
          'status': 'APROBADO',
          'sunatResponse': response.toJson(),
          'isCancelled': false,
          'cancellationReason': '',
          'customerName': docBody.accountingCustomerParty.registrationName,
          'customerRuc': docBody.accountingCustomerParty.id,
          'total': docBody.legalMonetaryTotal.payableAmount,
          'items': docBody.invoiceLines.map((line) => line.toJson()).toList(),
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'fileName': event.request.fileName,
        };

        await SalesFirestoreService.saveSale(saleData, newDocId);
        developer.log('Datos de factura guardados en Firestore con ID: $newDocId', name: 'FacturaBloc');
        
        emit(FacturaSent(response));

      } else {
        emit(const FacturaError('Usuario no autenticado.'));
      }
    } catch (e) {
      developer.log('Error en _onSendFactura: $e', error: e, name: 'FacturaBloc');
      emit(FacturaError(e.toString()));
    }
  }

  Future<void> _onCheckFacturaStatus(
    CheckFacturaStatusEvent event,
    Emitter<FacturaState> emit,
  ) async {
    try {
      final status = await _getBoletaStatusUseCase(event.apiDocumentId);
      await SalesFirestoreService.updateSaleStatus(
        event.firestoreDocumentId,
        status.status,
        status.toJson(),
      );
      emit(FacturaStatusChecked(status.status));
    } catch (e) {
      emit(FacturaError('Error al verificar el estado: ${e.toString()}'));
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