import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/qr_bloc.dart';

class QRPage extends StatelessWidget {
  const QRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<QrBloc>()..add(LoadQr()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Módulo de Pago'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: BlocConsumer<QrBloc, QrState>(
          listener: (context, state) {
            if (state is QrError) {
              AppSnackbar.error(context, 'Error: ${state.message}');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Tu Código QR de Pago',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state is QrLoaded
                        ? 'Este es tu QR cargado para recibir pagos.'
                        : 'Aún no has cargado un código QR. Puedes seleccionar uno de tu galería.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildQrView(context, state),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: state is QrLoading
                              ? null
                              : () => context.read<QrBloc>().add(PickAndUploadQr()),
                          icon: const Icon(Icons.image_search),
                          label: const Text('Seleccionar o Cambiar QR'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                        if (state is QrLoaded) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => context.read<QrBloc>().add(DeleteQr()),
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar QR'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context, QrState state) {
    if (state is QrLoading) {
      return const SizedBox(
        height: 250,
        width: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is QrLoaded) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          state.imageUrl,
          height: 250,
          width: 250,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              height: 250,
              width: 250,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              children: [
                Icon(Icons.error, size: 100, color: Colors.red),
                SizedBox(height: 12),
                Text(
                  'No se pudo cargar el QR',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            );
          },
        ),
      );
    }
    
    // QrInitial or QrError state
    return const Column(
      children: [
        Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
        SizedBox(height: 12),
        Text(
          'Sin QR cargado',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    );
  }
}
