import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/app_snackbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        } else if (state is AuthError) {
          AppSnackbar.error(context, '❌ ${state.message}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vendify'),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<AuthBloc>().add(AuthSignOutRequested());
                            },
                            child: const Text('Cerrar Sesión'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFeatureButton(
                context,
                title: 'Ventas',
                subtitle: 'Gestionar boletas y facturas',
                icon: Icons.receipt_long,
                color: Colors.blue,
                onTap: () => context.go('/boletas_facturas'),
              ),
              const SizedBox(height: 16),
              _buildFeatureButton(
                context,
                title: 'Inventario',
                subtitle: 'Gestionar productos y stock',
                icon: Icons.inventory_2,
                color: Colors.green,
                onTap: () => context.go('/inventory'),
              ),
              const SizedBox(height: 16),
              _buildFeatureButton(
                context,
                title: 'QR',
                subtitle: 'Escanear códigos QR',
                icon: Icons.qr_code_scanner,
                color: Colors.purple,
                onTap: () => context.go('/qr'),
              ),
              const SizedBox(height: 16),
              _buildFeatureButton(
                context,
                title: 'Reportes',
                subtitle: 'Ver estadísticas y reportes',
                icon: Icons.bar_chart,
                color: Colors.orange,
                onTap: () => context.go('/reports'),
              ),
              const SizedBox(height: 16),
              _buildFeatureButton(
                context,
                title: 'Datos del Negocio',
                subtitle: 'Configurar información comercial',
                icon: Icons.business,
                color: Colors.deepPurple,
                onTap: () => context.go('/user_details'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
