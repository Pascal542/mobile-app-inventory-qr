import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/send_boleta_usecase.dart';
import '../../domain/usecases/get_last_document_number_usecase.dart';
import '../../domain/usecases/get_boleta_status_usecase.dart';
import '../../domain/usecases/get_boleta_pdf_usecase.dart';
import '../../data/models/boleta_request.dart';
import '../../data/models/boleta_response.dart';
import '../../data/datasources/sales_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class GetBoletaStatusEvent extends BoletaEvent {
  final String documentId;

  const GetBoletaStatusEvent(this.documentId);

  @override
  List<Object> get props => [documentId];
}

class GetBoletaPdfEvent extends BoletaEvent {
  final String documentId;
  final String format;
  final String fileName;

  const GetBoletaPdfEvent({
    required this.documentId,
    required this.format,
    required this.fileName,
  });

  @override
  List<Object> get props => [documentId, format, fileName];
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

class BoletaStatusLoaded extends BoletaState {
  final BoletaDocumentStatus status;

  const BoletaStatusLoaded(this.status);

  @override
  List<Object> get props => [status];
}

class BoletaPdfLoaded extends BoletaState {
  final String pdf;

  const BoletaPdfLoaded(this.pdf);

  @override
  List<Object> get props => [pdf];
}

class BoletaError extends BoletaState {
  final String message;

  const BoletaError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class BoletaBloc extends Bloc<BoletaEvent, BoletaState> {
  final SendBoletaUseCase _sendBoletaUseCase;
  final GetLastDocumentNumberUseCase _getLastDocumentNumberUseCase;
  final GetBoletaStatusUseCase _getBoletaStatusUseCase;
  final GetBoletaPdfUseCase _getBoletaPdfUseCase;

  BoletaBloc({
    required SendBoletaUseCase sendBoletaUseCase,
    required GetLastDocumentNumberUseCase getLastDocumentNumberUseCase,
    required GetBoletaStatusUseCase getBoletaStatusUseCase,
    required GetBoletaPdfUseCase getBoletaPdfUseCase,
  })  : _sendBoletaUseCase = sendBoletaUseCase,
        _getLastDocumentNumberUseCase = getLastDocumentNumberUseCase,
        _getBoletaStatusUseCase = getBoletaStatusUseCase,
        _getBoletaPdfUseCase = getBoletaPdfUseCase,
        super(BoletaInitial()) {
    on<SendBoletaEvent>(_onSendBoleta);
    on<GetLastDocumentNumberEvent>(_onGetLastDocumentNumber);
    on<GetBoletaStatusEvent>(_onGetBoletaStatus);
    on<GetBoletaPdfEvent>(_onGetBoletaPdf);
  }

  Future<void> _onSendBoleta(
    SendBoletaEvent event,
    Emitter<BoletaState> emit,
  ) async {
    try {
      emit(BoletaLoading());
      final response = await _sendBoletaUseCase(event.request);

      // Save sale metadata to Firestore (keep this)
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

      // Get the PDF (do not save to Firestore)
      final pdf = await _getBoletaPdfUseCase(
        response.documentId,
        'A4',
        fileName,
      );

      emit(BoletaSent(response));
    } catch (e) {
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

  Future<void> _onGetBoletaStatus(
    GetBoletaStatusEvent event,
    Emitter<BoletaState> emit,
  ) async {
    try {
      emit(BoletaLoading());
      final status = await _getBoletaStatusUseCase(event.documentId);
      emit(BoletaStatusLoaded(status));
    } catch (e) {
      emit(BoletaError(e.toString()));
    }
  }

  Future<void> _onGetBoletaPdf(
    GetBoletaPdfEvent event,
    Emitter<BoletaState> emit,
  ) async {
    try {
      emit(BoletaLoading());
      final pdf = await _getBoletaPdfUseCase(
        event.documentId,
        event.format,
        event.fileName,
      );
      emit(BoletaPdfLoaded(pdf));
    } catch (e) {
      emit(BoletaError(e.toString()));
    }
  }
} 