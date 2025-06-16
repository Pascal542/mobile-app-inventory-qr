import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/sales_api_constants.dart';
import '../bloc/boleta_bloc.dart';
import '../../data/models/boleta_request.dart';
import '../../domain/usecases/get_last_document_number_usecase.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../data/datasources/sales_api_client.dart';

class BoletaFormPage extends StatefulWidget {
  final GetLastDocumentNumberUseCase? getLastDocumentNumberUseCase;
  const BoletaFormPage({super.key, this.getLastDocumentNumberUseCase});

  @override
  State<BoletaFormPage> createState() => _BoletaFormPageState();
}

class _BoletaFormPageState extends State<BoletaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final String _series = 'B001';
  String _correlative = '00000001';
  final TextEditingController _customerIdCtrl = TextEditingController();
  final TextEditingController _customerNameCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  double round2(double value) => double.parse(value.toStringAsFixed(2));

  @override
  void initState() {
    super.initState();
    _getLastDocumentNumber();
  }

  void _getLastDocumentNumber() {
    context.read<BoletaBloc>().add(
          GetLastDocumentNumberEvent(
            type: '03', // Boleta type
            series: _series,
          ),
        );
  }

  @override
  void dispose() {
    _customerIdCtrl.dispose();
    _customerNameCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Usar el usecase inyectado si está presente
      final getLastDocumentNumberUseCase =
          widget.getLastDocumentNumberUseCase ??
              GetLastDocumentNumberUseCase(
                  SalesRepositoryImpl(apiClient: SalesApiClient()));
      final lastNumber =
          await getLastDocumentNumberUseCase(type: '03', series: _series);
      setState(() {
        _correlative = lastNumber;
      });

      final now = DateTime.now();
      final dateStr =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final timeStr =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final quantity = int.parse(_quantityCtrl.text);
      final price = round2(double.parse(_priceCtrl.text));
      final priceWithIgv = round2(price * 1.18);
      final subtotal = round2(quantity * price);
      final igv = round2(subtotal * 0.18);
      final total = round2(subtotal + igv);

      final fileName = '${ApiConstants.rucEmisor}-03-$_series-$_correlative';

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
          notes: [
            Note(
              text: '${total.toStringAsFixed(2)} SOLES',
              languageLocaleId: '1000',
            ),
          ],
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
            taxAmount: igv,
            taxSubtotals: [
              TaxSubtotal(
                taxableAmount: subtotal,
                taxAmount: igv,
                taxCategory: TaxCategory(
                  percent: 18,
                  taxExemptionReasonCode: '10',
                  taxScheme: TaxScheme(
                    id: '1000',
                    name: 'IGV',
                    taxTypeCode: 'VAT',
                  ),
                ),
              ),
            ],
          ),
          legalMonetaryTotal: LegalMonetaryTotal(
            lineExtensionAmount: subtotal,
            taxInclusiveAmount: total,
            payableAmount: total,
          ),
          invoiceLines: [
            InvoiceLine(
              id: 1,
              invoicedQuantity: quantity,
              lineExtensionAmount: subtotal,
              pricingReference: PricingReference(
                priceAmount: priceWithIgv,
                priceTypeCode: '01',
              ),
              taxTotal: TaxTotal(
                taxAmount: igv,
                taxSubtotals: [
                  TaxSubtotal(
                    taxableAmount: subtotal,
                    taxAmount: igv,
                    taxCategory: TaxCategory(
                      percent: 18,
                      taxExemptionReasonCode: '10',
                      taxScheme: TaxScheme(
                        id: '1000',
                        name: 'IGV',
                        taxTypeCode: 'VAT',
                      ),
                    ),
                  ),
                ],
              ),
              item: Item(
                description: _descriptionCtrl.text,
                sellersItemId: '01',
              ),
              price: Price(priceAmount: price),
            ),
          ],
        ),
      );

      context.read<BoletaBloc>().add(SendBoletaEvent(request));
    }
  }

  String? _validateDni(String? value) {
    if (value == null || value.isEmpty) return 'Obligatorio';
    if (value.length != 8) return 'El DNI debe tener 8 dígitos';
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) return 'Obligatorio';
    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Obligatorio';
    final price = double.tryParse(value);
    if (price == null || price <= 0) return 'El precio debe ser mayor a 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Boleta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/boletas_facturas'),
        ),
      ),
      body: BlocConsumer<BoletaBloc, BoletaState>(
        listener: (context, state) {
          if (state is LastDocumentNumberLoaded) {
            setState(() {
              _correlative = state.number;
            });
          } else if (state is BoletaSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Boleta enviada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/boletas_facturas');
          } else if (state is BoletaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Detalles de Boleta',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _customerIdCtrl,
                            decoration: const InputDecoration(
                              labelText: 'DNI',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: _validateDni,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _customerNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nombre Cliente',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Obligatorio' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _quantityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad',
                              prefixIcon: Icon(Icons.confirmation_number),
                            ),
                            keyboardType: TextInputType.number,
                            validator: _validateQuantity,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _priceCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Precio Unitario',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: _validatePrice,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Producto',
                              prefixIcon: Icon(Icons.description),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Obligatorio' : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: state is BoletaLoading ? null : _submit,
                            child: state is BoletaLoading
                                ? const CircularProgressIndicator()
                                : const Text('Enviar Boleta'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
