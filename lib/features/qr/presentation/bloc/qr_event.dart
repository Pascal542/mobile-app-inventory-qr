part of 'qr_bloc.dart';

abstract class QrEvent extends Equatable {
  const QrEvent();

  @override
  List<Object> get props => [];
}

class LoadQr extends QrEvent {}

class PickAndUploadQr extends QrEvent {}

class DeleteQr extends QrEvent {} 