import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/sales_api_constants.dart';

class FacturaFormPage extends StatefulWidget {
  const FacturaFormPage({super.key});

  @override
  State<FacturaFormPage> createState() => _FacturaFormPageState();
}

class _FacturaFormPageState extends State<FacturaFormPage> {
  final _formKey = GlobalKey<FormState>();
  // Series y correlativo para fileName automático
  final String _series = 'F001';
  final String _correlative = '00000001';
  final TextEditingController _customerIdCtrl = TextEditingController();
  final TextEditingController _customerNameCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

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
      final fileName = '$_series-$_correlative';
      final payload = {
        'personaId': ApiConstants.personaId,
        'personaToken': ApiConstants.personaToken,
        'fileName': fileName,
        'documentBody': {
          'cbc:InvoiceTypeCode': {
            '_text': '01',
            '_attributes': {'listID': '0101'},
          },
          'cbc:IssueDate': {'_text': dateStr},
          'cbc:IssueTime': {'_text': timeStr},
          'cac:AccountingCustomerParty': {
            'cac:Party': {
              'cac:PartyIdentification': {
                'cbc:ID': {
                  '_attributes': {'schemeID': '6'},
                  '_text': _customerIdCtrl.text,
                },
              },
              'cac:PartyLegalEntity': {
                'cbc:RegistrationName': {'_text': _customerNameCtrl.text},
              },
            },
          },
          'cac:InvoiceLine': [
            {
              'cbc:InvoicedQuantity': {
                '_attributes': {'unitCode': 'NIU'},
                '_text': int.parse(_quantityCtrl.text),
              },
              'cbc:LineExtensionAmount': {
                '_attributes': {'currencyID': 'PEN'},
                '_text': double.parse(_quantityCtrl.text) *
                    double.parse(_priceCtrl.text),
              },
              'cac:Item': {
                'cbc:Description': {'_text': _descriptionCtrl.text},
              },
              'cac:Price': {
                'cbc:PriceAmount': {
                  '_attributes': {'currencyID': 'PEN'},
                  '_text': double.parse(_priceCtrl.text),
                },
              },
            },
          ],
        },
      };
      print(payload);
      // TODO: enviar a la API usando tu cliente HTTP
      context.go('/boletas_facturas');
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
      body: SafeArea(
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
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Obligatorio' : null,
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
                      onPressed: _submit,
                      child: const Text('Enviar Factura'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
