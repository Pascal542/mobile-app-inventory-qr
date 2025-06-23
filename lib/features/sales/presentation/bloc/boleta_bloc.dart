import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app_inventory_qr/features/auth/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/send_boleta_usecase.dart';
import '../../domain/usecases/get_last_document_number_usecase.dart';
import '../../domain/usecases/get_boleta_status_usecase.dart';
import '../../data/models/boleta_request.dart';
import '../../data/models/boleta_response.dart';
import '../../data/datasources/sales_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// Events
abstract class BoletaEvent extends Equatable {
  const BoletaEvent();

  @override
  List<Object> get props => [];
}

class SendBoletaEvent extends BoletaEvent {
  final BoletaRequest request;

  const SendBoletaEvent(this.request);

  @override
  List<Object> get props => [request];
}

class GetLastDocumentNumberEvent extends BoletaEvent {
  final String type;
  final String series;

  const GetLastDocumentNumberEvent({
    required this.type,
    required this.series,
  });

  @override
  List<Object> get props => [type, series];
}

class CheckBoletaStatusEvent extends BoletaEvent {
  final String apiDocumentId;
  final String firestoreDocumentId;

  const CheckBoletaStatusEvent({
    required this.apiDocumentId,
    required this.firestoreDocumentId,
  });

  @override
  List<Object> get props => [apiDocumentId, firestoreDocumentId];
}

// States
abstract class BoletaState extends Equatable {
  const BoletaState();

  @override
  List<Object> get props => [];
}

class BoletaInitial extends BoletaState {}

class BoletaLoading extends BoletaState {}

class BoletaSent extends BoletaState {
  final BoletaResponse response;

  const BoletaSent(this.response);

  @override
  List<Object> get props => [response];
}

class LastDocumentNumberLoaded extends BoletaState {
  final String number;

  const LastDocumentNumberLoaded(this.number);

  @override
  List<Object> get props => [number];
}

class BoletaStatusUpdated extends BoletaState {
  final BoletaDocumentStatus status;

  const BoletaStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}

class BoletaError extends BoletaState {
  final String message;

  const BoletaError(this.message);

  @override
  List<Object> get props => [message];
}

class BoletaStatusChecked extends BoletaState {
  final String status;

  const BoletaStatusChecked(this.status);

  @override
  List<Object> get props => [status];
}

// BLoC
class BoletaBloc extends Bloc<BoletaEvent, BoletaState> {
  final SendBoletaUseCase _sendBoletaUseCase;
  final GetLastDocumentNumberUseCase _getLastDocumentNumberUseCase;
  final GetBoletaStatusUseCase _getBoletaStatusUseCase;
  final AuthBloc _authBloc;

  BoletaBloc({
    required SendBoletaUseCase sendBoletaUseCase,
    required GetLastDocumentNumberUseCase getLastDocumentNumberUseCase,
    required GetBoletaStatusUseCase getBoletaStatusUseCase,
    required AuthBloc authBloc,
  })  : _sendBoletaUseCase = sendBoletaUseCase,
        _getLastDocumentNumberUseCase = getLastDocumentNumberUseCase,
        _getBoletaStatusUseCase = getBoletaStatusUseCase,
        _authBloc = authBloc,
        super(BoletaInitial()) {
    on<SendBoletaEvent>(_onSendBoleta);
    on<GetLastDocumentNumberEvent>(_onGetLastDocumentNumber);
    on<CheckBoletaStatusEvent>(_onCheckBoletaStatus);
  }

  Future<void> _onSendBoleta(
    SendBoletaEvent event,
    Emitter<BoletaState> emit,
  ) async {
    emit(BoletaLoading());
    try {
      final (response, newDocId) = await _sendBoletaUseCase(event.request);
      developer.log('Respuesta de la API al enviar boleta: ${response.toJson()}', name: 'BoletaBloc');
      
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
        developer.log('Datos de boleta guardados en Firestore con ID: $newDocId', name: 'BoletaBloc');

        emit(BoletaSent(response));
      } else {
        emit(const BoletaError('Usuario no autenticado.'));
      }
    } catch (e) {
      developer.log('Error en _onSendBoleta: $e', error: e, name: 'BoletaBloc');
      emit(BoletaError(e.toString()));
    }
  }

  Future<void> _onGetLastDocumentNumber(
    GetLastDocumentNumberEvent event,
    Emitter<BoletaState> emit,
  ) async {
    try {
      emit(BoletaLoading());
      final number = await _getLastDocumentNumberUseCase(
        type: event.type,
        series: event.series,
      );
      emit(LastDocumentNumberLoaded(number));
    } catch (e) {
      emit(BoletaError(e.toString()));
    }
  }

  Future<void> _onCheckBoletaStatus(
    CheckBoletaStatusEvent event,
    Emitter<BoletaState> emit,
  ) async {
    try {
      final status = await _getBoletaStatusUseCase(event.apiDocumentId);
      await SalesFirestoreService.updateSaleStatus(
        event.firestoreDocumentId,
        status.status,
        status.toJson(),
      );
      emit(BoletaStatusChecked(status.status));
    } catch (e) {
      emit(BoletaError('Error al verificar el estado: ${e.toString()}'));
    }
  }
} 