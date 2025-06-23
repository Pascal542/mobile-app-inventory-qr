import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/delete_qr_usecase.dart';
import '../../domain/usecases/get_qr_image_url_usecase.dart';
import '../../domain/usecases/upload_qr_usecase.dart';

part 'qr_event.dart';
part 'qr_state.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  final AuthBloc _authBloc;
  final GetQrImageUrlUseCase _getQrImageUrlUseCase;
  final UploadQrUseCase _uploadQrUseCase;
  final DeleteQrUseCase _deleteQrUseCase;

  QrBloc({
    required AuthBloc authBloc,
    required GetQrImageUrlUseCase getQrImageUrlUseCase,
    required UploadQrUseCase uploadQrUseCase,
    required DeleteQrUseCase deleteQrUseCase,
  })  : _authBloc = authBloc,
        _getQrImageUrlUseCase = getQrImageUrlUseCase,
        _uploadQrUseCase = uploadQrUseCase,
        _deleteQrUseCase = deleteQrUseCase,
        super(QrInitial()) {
    on<LoadQr>(_onLoadQr);
    on<PickAndUploadQr>(_onPickAndUploadQr);
    on<DeleteQr>(_onDeleteQr);
  }

  String? get _userId {
    final authState = _authBloc.state;
    if (authState is Authenticated) {
      return authState.user.uid;
    }
    return null;
  }

  Future<void> _onLoadQr(LoadQr event, Emitter<QrState> emit) async {
    emit(QrLoading());
    if (_userId == null) {
      emit(const QrError('Usuario no autenticado.'));
      return;
    }
    try {
      final imageUrl = await _getQrImageUrlUseCase(_userId!);
      if (imageUrl != null) {
        emit(QrLoaded(imageUrl));
      } else {
        emit(QrInitial());
      }
    } catch (e) {
      emit(QrError(e.toString()));
    }
  }

  Future<void> _onPickAndUploadQr(PickAndUploadQr event, Emitter<QrState> emit) async {
     if (_userId == null) {
      emit(const QrError('Usuario no autenticado.'));
      return;
    }
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        emit(QrLoading());
        final imageFile = File(pickedFile.path);
        final imageUrl = await _uploadQrUseCase(imageFile, _userId!);
        emit(QrLoaded(imageUrl));
      }
    } catch (e) {
      emit(QrError(e.toString()));
    }
  }

  Future<void> _onDeleteQr(DeleteQr event, Emitter<QrState> emit) async {
    emit(QrLoading());
     if (_userId == null) {
      emit(const QrError('Usuario no autenticado.'));
      return;
    }
    try {
      await _deleteQrUseCase(_userId!);
      emit(QrInitial());
    } catch (e) {
      emit(QrError(e.toString()));
    }
  }
} 