import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/inventory_bloc.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_snackbar.dart';

class AgregarProductoPage extends StatefulWidget {
  const AgregarProductoPage({super.key});

  @override
  State<AgregarProductoPage> createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AgregarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _categoriaController = TextEditingController();
  String _selectedCategoria = 'General';

  final List<String> _categorias = [
    'General',
    'Electrónicos',
    'Ropa',
    'Alimentos',
    'Hogar',
    'Deportes',
    'Libros',
    'Otros',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('➕ Agregar Producto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/inventory'),
        ),
      ),
      body: BlocListener<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is ProductAdded) {
            AppSnackbar.success(context, '✅ Producto agregado exitosamente');
            context.go('/listado_productos');
          } else if (state is InventoryError) {
            AppSnackbar.error(context, '❌ Error: ${state.message}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información del Producto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del producto *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory_2),
                            ),
                            validator: FormValidators.name,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedCategoria,
                            decoration: const InputDecoration(
                              labelText: 'Categoría *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _categorias.map((categoria) {
                              return DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoria = value!;
                              });
                            },
                            validator: FormValidators.required,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalles de Inventario',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _precioController,
                                  decoration: const InputDecoration(
                                    labelText: 'Precio (S/) *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: FormValidators.price,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _cantidadController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cantidad *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.numbers),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: FormValidators.quantity,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<InventoryBloc, InventoryState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is InventoryLoading
                            ? null
                            : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: state is InventoryLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Guardar Producto',
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<InventoryBloc>().add(AddProduct(
        nombre: _nombreController.text.trim(),
        cantidad: int.parse(_cantidadController.text),
        categoria: _selectedCategoria,
        precio: double.parse(_precioController.text),
      ));
    }
  }
}