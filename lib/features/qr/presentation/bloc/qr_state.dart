part of 'qr_bloc.dart';

abstract class QrState extends Equatable {
  const QrState();

  @override
  List<Object> get props => [];
}

class QrInitial extends QrState {}

class QrLoading extends QrState {}

class QrLoaded extends QrState {
  final String imageUrl;

  const QrLoaded(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class QrError extends QrState {
  final String message;

  const QrError(this.message);

  @override
  List<Object> get props => [message];
} 