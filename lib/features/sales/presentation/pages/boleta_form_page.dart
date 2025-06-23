import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_inventory_qr/features/inventory/data/models/producto.dart';
import 'package:mobile_app_inventory_qr/features/inventory/services/firestore_service.dart';
import '../../core/constants/sales_api_constants.dart';
import '../bloc/boleta_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/boleta_request.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_snackbar.dart';

class BoletaFormPage extends StatefulWidget {
  const BoletaFormPage({super.key});

  @override
  State<BoletaFormPage> createState() => _BoletaFormPageState();
}

class _BoletaFormPageState extends State<BoletaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final String _series = 'B001';
  String _correlative = '00000001';
  
  // Customer controllers
  final TextEditingController _customerIdCtrl = TextEditingController();
  final TextEditingController _customerNameCtrl = TextEditingController();

  // Item form controllers
  final TextEditingController _quantityCtrl = TextEditingController();
  
  // State variables
  List<Producto> _inventoryProducts = [];
  List<InvoiceLine> _invoiceLines = [];
  bool _isLoadingInventory = true;
  Producto? _selectedProduct;
  String? _selectedCategory;
  double _currentPrice = 0.0;

  // Get unique categories from products
  List<String> get _categories {
    final categories = _inventoryProducts.map((p) => p.categoria).toSet().toList();
    categories.sort();
    print('DEBUG: Productos cargados: ${_inventoryProducts.length}');
    print('DEBUG: Categorías encontradas: $categories');
    print('DEBUG: Productos con categorías:');
    for (var producto in _inventoryProducts) {
      print('  - ${producto.nombre}: categoria="${producto.categoria}"');
    }
    return categories.where((cat) => cat.isNotEmpty).toList();
  }

  // Get products filtered by selected category
  List<Producto> get _filteredProducts {
    if (_selectedCategory == null) {
      // Si no hay categoría seleccionada, mostrar todos los productos con stock
      return _inventoryProducts.where((p) => p.cantidad > 0).toList();
    }
    return _inventoryProducts
        .where((p) => p.categoria == _selectedCategory && p.cantidad > 0)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    final authState = context.read<AuthBloc>().state;
    print('DEBUG: Estado de autenticación: $authState');
    if (authState is Authenticated) {
      final userId = authState.user.uid.split('_').last;
      print('DEBUG: Usuario autenticado con UID original: ${authState.user.uid}');
      print('DEBUG: Usuario autenticado con UID procesado: $userId');
      await _fetchInventory(userId);
    } else {
      print('DEBUG: Usuario NO autenticado');
    }
    _getLastDocumentNumber();
  }

  Future<void> _fetchInventory(String userId) async {
    setState(() => _isLoadingInventory = true);
    print('DEBUG: Iniciando carga de inventario para usuario: $userId');
    final service = FirestoreService();
    final productsStream = service.obtenerProductos(userId);
    productsStream.listen(
      (products) {
        if (mounted) {
          print('DEBUG: Productos recibidos del stream: ${products.length}');
          setState(() {
            _inventoryProducts = products;
            _isLoadingInventory = false;
          });
        }
      },
      onError: (error) {
        print('DEBUG: Error en stream de productos: $error');
        if (mounted) {
          setState(() => _isLoadingInventory = false);
        }
      },
    );
  }

  void _getLastDocumentNumber() {
    context.read<BoletaBloc>().add(
          GetLastDocumentNumberEvent(type: '03', series: _series),
        );
  }

  @override
  void dispose() {
    _customerIdCtrl.dispose();
    _customerNameCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  void _selectProduct(Producto product) {
    setState(() {
      _selectedProduct = product;
      _currentPrice = product.precio;
    });
  }

  void _addItem() {
    if (_selectedProduct == null || _quantityCtrl.text.isEmpty) {
      AppSnackbar.error(context, 'Seleccione un producto y una cantidad.');
      return;
    }

    final quantity = int.tryParse(_quantityCtrl.text);
    if (quantity == null || quantity <= 0) {
      AppSnackbar.error(context, 'La cantidad debe ser un número positivo.');
      return;
    }
    
    if (quantity > _selectedProduct!.cantidad) {
      AppSnackbar.error(context, 'Stock insuficiente. Disponibles: ${_selectedProduct!.cantidad}');
      return;
    }
    
    final price = _currentPrice;
    final priceWithIgv = round2(price * 1.18);
    final subtotal = round2(quantity * price);
    
    final newLine = InvoiceLine(
      id: _invoiceLines.length + 1,
      invoicedQuantity: quantity,
      lineExtensionAmount: subtotal,
      pricingReference: PricingReference(priceAmount: priceWithIgv, priceTypeCode: '01'),
      taxTotal: TaxTotal(
        taxAmount: round2(subtotal * 0.18),
        taxSubtotals: [
          TaxSubtotal(
            taxableAmount: subtotal,
            taxAmount: round2(subtotal * 0.18),
            taxCategory: TaxCategory(
              percent: 18,
              taxExemptionReasonCode: '10',
              taxScheme: TaxScheme(id: '1000', name: 'IGV', taxTypeCode: 'VAT'),
            ),
          ),
        ],
      ),
      item: Item(description: _selectedProduct!.nombre, sellersItemId: _selectedProduct!.id ?? 'N/A'),
      price: Price(priceAmount: price),
    );

    setState(() {
      _invoiceLines.add(newLine);
      _quantityCtrl.clear();
      _selectedProduct = null;
      _currentPrice = 0.0;
    });
  }

  Future<void> _submit() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      AppSnackbar.error(context, 'Error: Usuario no autenticado.');
      return;
    }
    
    if (!_formKey.currentState!.validate() || _invoiceLines.isEmpty) {
      AppSnackbar.error(context, 'Por favor, complete los datos del cliente y añada al menos un producto.');
      return;
    }

    // Stock check before submitting
    for (var line in _invoiceLines) {
      final productInInventory = _inventoryProducts.firstWhere((p) => p.id == line.item.sellersItemId);
      if (productInInventory.cantidad < line.invoicedQuantity) {
        AppSnackbar.error(context, 'Stock insuficiente para ${line.item.description}.');
        return;
      }
    }
    
    _formKey.currentState!.save();
    
    final grandTotal = _invoiceLines.fold<double>(0.0, (sum, item) => sum + item.lineExtensionAmount);
    final totalIgv = round2(grandTotal * 0.18);
    final totalPayable = round2(grandTotal + totalIgv);
    final fileName = '${ApiConstants.rucEmisor}-03-$_series-$_correlative';
    final now = DateTime.now();
    final dateStr = "${now.year}-${'${now.month}'.padLeft(2, '0')}-${'${now.day}'.padLeft(2, '0')}";
    final timeStr = "${'${now.hour}'.padLeft(2, '0')}:${'${now.minute}'.padLeft(2, '0')}:${'${now.second}'.padLeft(2, '0')}";
    
    final request = BoletaRequest(
      personaId: ApiConstants.personaId,
      personaToken: ApiConstants.personaToken,
      fileName: fileName,
      documentBody: BoletaDocumentBody(
        ublVersionId: '2.1',
        customizationId: '2.0',
        id: '$_series-$_correlative',
        issueDate: dateStr,
        issueTime: timeStr,
        invoiceTypeCode: '03',
        notes: [Note(text: '${totalPayable.toStringAsFixed(2)} SOLES', languageLocaleId: '1000')],
        documentCurrencyCode: 'PEN',
        accountingSupplierParty: AccountingSupplierParty(
          id: ApiConstants.rucEmisor,
          registrationName: ApiConstants.registrationName,
          partyName: ApiConstants.partyName,
          address: ApiConstants.address,
        ),
        accountingCustomerParty: AccountingCustomerParty(
          id: _customerIdCtrl.text,
          registrationName: _customerNameCtrl.text,
          schemeId: _customerIdCtrl.text.length == 8 ? '1' : '6',
        ),
        taxTotal: TaxTotal(
          taxAmount: totalIgv,
          taxSubtotals: [
            TaxSubtotal(
              taxableAmount: grandTotal,
              taxAmount: totalIgv,
              taxCategory: TaxCategory(
                percent: 18,
                taxExemptionReasonCode: '10',
                taxScheme: TaxScheme(id: '1000', name: 'IGV', taxTypeCode: 'VAT'),
              ),
            ),
          ],
        ),
        legalMonetaryTotal: LegalMonetaryTotal(
          lineExtensionAmount: grandTotal,
          taxInclusiveAmount: totalPayable,
          payableAmount: totalPayable,
        ),
        invoiceLines: _invoiceLines,
      ),
    );

    context.read<BoletaBloc>().add(SendBoletaEvent(request));
  }
  
  double round2(double value) => double.parse(value.toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Boleta'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/boletas_facturas'),
        ),
      ),
      body: BlocConsumer<BoletaBloc, BoletaState>(
        listener: (context, state) async {
          if (state is BoletaSent) {
            AppSnackbar.success(context, '✅ Boleta enviada exitosamente');
            // Decrease stock after successful sale
            final authState = context.read<AuthBloc>().state;
            if(authState is Authenticated){
              final userId = authState.user.uid.split('_').last;
              final service = FirestoreService();
              for (var line in _invoiceLines) {
                await service.decreaseProductStock(userId, line.item.sellersItemId, line.invoicedQuantity);
              }
            }
            context.go('/boletas_facturas');
          } else if (state is BoletaError) {
            AppSnackbar.error(context, '❌ Error: ${state.message}');
          } else if (state is LastDocumentNumberLoaded) {
             if(mounted){
                setState(() => _correlative = state.number);
             }
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCustomerCard(),
                  const SizedBox(height: 16),
                  if (_categories.isNotEmpty) ...[
                    _buildCategorySelectionCard(),
                    if (_selectedCategory != null) ...[
                      const SizedBox(height: 16),
                      _buildProductsGrid(),
                      const SizedBox(height: 16),
                      _buildAddItemCard(),
                    ],
                  ] else ...[
                    _buildProductsGrid(),
                    const SizedBox(height: 16),
                    _buildAddItemCard(),
                  ],
                  const SizedBox(height: 16),
                  _buildItemsList(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is BoletaLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state is BoletaLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Guardar y Enviar a SUNAT', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos del Cliente', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerIdCtrl,
              decoration: const InputDecoration(labelText: 'DNI', prefixIcon: Icon(Icons.person)),
              validator: FormValidators.dni,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre Cliente', prefixIcon: Icon(Icons.person_outline)),
              validator: FormValidators.name,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seleccionar Categoría', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_isLoadingInventory)
              const Center(child: CircularProgressIndicator())
            else if (_categories.isEmpty)
              const Text('No hay categorías disponibles', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                        _selectedProduct = null;
                        _currentPrice = 0.0;
                      });
                    },
                    selectedColor: Colors.deepPurple.withOpacity(0.2),
                    checkmarkColor: Colors.deepPurple,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_filteredProducts.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No hay productos disponibles en la categoría "$_selectedCategory"',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Productos - ${_selectedCategory ?? "Todos los productos"}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final isSelected = _selectedProduct?.id == product.id;
                
                return Card(
                  elevation: isSelected ? 4 : 2,
                  color: isSelected ? Colors.deepPurple.withOpacity(0.1) : null,
                  child: InkWell(
                    onTap: () => _selectProduct(product),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Stock: ${product.cantidad}',
                                  style: TextStyle(
                                    color: product.cantidad > 0 ? Colors.green : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'S/ ${product.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemCard() {
    if (_selectedProduct == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Añadir Producto', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedProduct!.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Stock: ${_selectedProduct!.cantidad} | S/ ${_selectedProduct!.precio.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedProduct = null;
                        _currentPrice = 0.0;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityCtrl,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                prefixIcon: Icon(Icons.confirmation_number),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => FormValidators.quantity(value),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Añadir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    if (_invoiceLines.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Añada productos a la boleta.', textAlign: TextAlign.center),
        ),
      );
    }
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items de la Boleta', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _invoiceLines.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final line = _invoiceLines[index];
                return ListTile(
                  title: Text(line.item.description),
                  subtitle: Text('Cantidad: ${line.invoicedQuantity} - P.U: S/ ${line.price.priceAmount.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('S/ ${line.lineExtensionAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _invoiceLines.removeAt(index)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(thickness: 1, height: 20),
            _buildTotalRow('SUBTOTAL', _invoiceLines.fold(0.0, (sum, item) => sum + item.lineExtensionAmount)),
            _buildTotalRow('IGV (18%)', _invoiceLines.fold(0.0, (sum, item) => sum + item.lineExtensionAmount) * 0.18),
            _buildTotalRow('TOTAL', _invoiceLines.fold(0.0, (sum, item) => sum + item.lineExtensionAmount) * 1.18, isTotal: true),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
          Text('S/ ${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
        ],
      ),
    );
  }
}
