import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/producto.dart';
import '../bloc/inventory_bloc.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ModificarProductoPage extends StatefulWidget {
  final Producto producto;
  const ModificarProductoPage({super.key, required this.producto});

  @override
  State<ModificarProductoPage> createState() => _ModificarProductoPageState();
}

class _ModificarProductoPageState extends State<ModificarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _cantidadController;
  late TextEditingController _precioController;
  late String _categoria;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _cantidadController = TextEditingController(text: widget.producto.cantidad.toString());
    _precioController = TextEditingController(text: widget.producto.precio.toString());
    _categoria = widget.producto.categoria;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (widget.producto.id == null) {
      AppSnackbar.error(context, 'Error: ID de producto no encontrado.');
      return;
    }
    if (_formKey.currentState!.validate()) {
      context.read<InventoryBloc>().add(UpdateProduct(
        productId: widget.producto.id!,
        nuevoNombre: _nombreController.text.trim(),
        nuevaCantidad: int.parse(_cantidadController.text),
        nuevoPrecio: double.parse(_precioController.text),
        nuevaCategoria: _categoria, // Asumiendo que la categoría no se puede cambiar en esta UI
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Producto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/inventory'),
        ),
      ),
      body: BlocListener<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is ProductUpdated) {
            AppSnackbar.success(context, '✅ Producto actualizado exitosamente');
            context.go('/listado_productos');
          } else if (state is InventoryError) {
            AppSnackbar.error(context, '❌ Error al actualizar: ${state.message}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: FormValidators.name,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                  validator: FormValidators.nonNegative,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precioController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: FormValidators.price,
                ),
                const SizedBox(height: 20),
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is InventoryLoading ? null : _submitForm,
                      child: state is InventoryLoading 
                          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          : const Text('Guardar Cambios'),
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