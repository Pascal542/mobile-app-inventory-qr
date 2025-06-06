import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/sales_api_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/factura_bloc.dart';
import '../../data/models/boleta_request.dart';

class FacturaFormPage extends StatefulWidget {
  const FacturaFormPage({super.key});

  @override
  State<FacturaFormPage> createState() => _FacturaFormPageState();
}

class _FacturaFormPageState extends State<FacturaFormPage> {
  final _formKey = GlobalKey<FormState>();
  // Series y correlativo para fileName automático
  final String _series = 'F001';
  String _correlative = '00000001';
  final TextEditingController _customerIdCtrl = TextEditingController();
  final TextEditingController _customerNameCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  double round2(double value) => double.parse(value.toStringAsFixed(2));

  String? _validateRuc(String? value) {
    if (value == null || value.isEmpty) return 'Obligatorio';
    if (value.length != 11) return 'El RUC debe tener 11 dígitos';
    final validPrefixes = ['10', '15', '16', '17', '20'];
    if (!validPrefixes.any((prefix) => value.startsWith(prefix))) {
      return 'El RUC debe empezar con 10, 15, 16, 17 o 20';
    }
  }

  @override
  void initState() {
    super.initState();
    _getLastDocumentNumber();
  }

  void _getLastDocumentNumber() {
    // type: '01' para factura
    context.read<FacturaBloc>().add(
      GetLastDocumentNumberEvent(
        type: '01',
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
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
      final fileName = '${ApiConstants.rucEmisor}-01-$_series-$_correlative';
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
          invoiceTypeCode: '01',
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
            id: _customerIdCtrl.text.trim(),
            registrationName: _customerNameCtrl.text,
            schemeId: '6',
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
      context.read<FacturaBloc>().add(SendFacturaEvent(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Factura'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/boletas_facturas'),
        ),
      ),
      body: BlocConsumer<FacturaBloc, FacturaState>(
        listener: (context, state) {
          if (state is LastDocumentNumberLoaded) {
            setState(() {
              _correlative = state.number;
            });
          } else if (state is FacturaSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Factura enviada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/boletas_facturas');
          } else if (state is FacturaError) {
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
                          'Detalles de Factura',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customerIdCtrl,
                          decoration: const InputDecoration(
                            labelText: 'RUC',
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: _validateRuc,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customerNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Razón Social',
                            prefixIcon: Icon(Icons.business_outlined),
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
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obligatorio' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Precio Unitario',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obligatorio' : null,
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
                          onPressed: state is FacturaLoading ? null : _submit,
                          child: state is FacturaLoading
                              ? const CircularProgressIndicator()
                              : const Text('Enviar Factura'),
                        ),
                      ],
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
