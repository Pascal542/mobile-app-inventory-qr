import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_snackbar.dart';

class UserDetailsForm extends StatefulWidget {
  const UserDetailsForm({super.key});

  @override
  State<UserDetailsForm> createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreComercialCtrl = TextEditingController();
  final _nombrePropietarioCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessRucController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _taxCategoryController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessWebsiteController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreComercialCtrl.dispose();
    _nombrePropietarioCtrl.dispose();
    _rucCtrl.dispose();
    _ubicacionCtrl.dispose();
    _businessNameController.dispose();
    _businessRucController.dispose();
    _businessAddressController.dispose();
    _ownerNameController.dispose();
    _businessTypeController.dispose();
    _taxCategoryController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _businessWebsiteController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  void _handleUpdateBusinessInfo() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Obtener el usuario actual del BLoC
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final businessInfo = {
        'businessName': _nombreComercialCtrl.text.trim(),
        'ownerName': _nombrePropietarioCtrl.text.trim(),
        'businessRuc': _rucCtrl.text.trim(),
        'businessAddress': _ubicacionCtrl.text.trim(),
      };

      context.read<AuthBloc>().add(
        AuthUpdateBusinessInfoRequested(
          uid: authState.user.uid,
          businessInfo: businessInfo,
        ),
      );
    } else {
      AppSnackbar.error(context, '❌ Usuario no autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del Negocio'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            AppSnackbar.success(context, '✅ Datos guardados correctamente');
            context.go('/home');
          } else if (state is AuthError) {
            AppSnackbar.error(context, '❌ ${state.message}');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return TextFormField(
                      controller: _nombreComercialCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Comercial',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                      ),
                      validator: FormValidators.required,
                      enabled: state is! AuthLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return TextFormField(
                      controller: _nombrePropietarioCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Propietario',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: FormValidators.required,
                      enabled: state is! AuthLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return TextFormField(
                      controller: _rucCtrl,
                      decoration: const InputDecoration(
                        labelText: 'RUC',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: FormValidators.ruc,
                      enabled: state is! AuthLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return TextFormField(
                      controller: _ubicacionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: FormValidators.required,
                      enabled: state is! AuthLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading ? null : _handleUpdateBusinessInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Guardar Información',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
