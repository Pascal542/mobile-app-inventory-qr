import '../../data/models/boleta_response.dart';
import '../repositories/sales_repository.dart';
import '../../data/models/boleta_request.dart';
import 'get_last_document_number_usecase.dart';
import 'dart:developer' as developer;

class SendBoletaUseCase {
  final SalesRepository _repository;
  final GetLastDocumentNumberUseCase _getLastDocumentNumber;

  SendBoletaUseCase(this._repository, this._getLastDocumentNumber);

  Future<(BoletaResponse, String)> call(BoletaRequest request) async {
    try {
      final series = request.documentBody.id.split('-')[0];
      developer.log('Solicitando último número para serie: $series y tipo: ${request.documentBody.invoiceTypeCode}');

      final nextNumberStr = await _getLastDocumentNumber.call(
        type: request.documentBody.invoiceTypeCode,
        series: series,
      );
      
      developer.log('Número sugerido por la API: $nextNumberStr');

      final newNumber = int.parse(nextNumberStr);
      final newNumberFormatted = newNumber.toString().padLeft(8, '0');
      final newId = '$series-$newNumberFormatted';
      
      developer.log('Nuevo ID de documento generado: $newId');

      final newDocumentBody = BoletaDocumentBody(
        id: newId,
        ublVersionId: request.documentBody.ublVersionId,
        customizationId: request.documentBody.customizationId,
        issueDate: request.documentBody.issueDate,
        issueTime: request.documentBody.issueTime,
        invoiceTypeCode: request.documentBody.invoiceTypeCode,
        notes: request.documentBody.notes,
        documentCurrencyCode: request.documentBody.documentCurrencyCode,
        accountingSupplierParty: request.documentBody.accountingSupplierParty,
        accountingCustomerParty: request.documentBody.accountingCustomerParty,
        taxTotal: request.documentBody.taxTotal,
        legalMonetaryTotal: request.documentBody.legalMonetaryTotal,
        invoiceLines: request.documentBody.invoiceLines,
      );

      final newFileName =
          '${request.documentBody.accountingSupplierParty.id}-${request.documentBody.invoiceTypeCode}-$newId';

      developer.log('Nuevo nombre de archivo generado: $newFileName');

      final newRequest = BoletaRequest(
        personaId: request.personaId,
        personaToken: request.personaToken,
        fileName: newFileName,
        documentBody: newDocumentBody,
      );

      final response = await _repository.sendBoleta(newRequest);
      return (response, newId);
    } catch (e) {
      developer.log('Error en SendBoletaUseCase: $e', error: e);
      throw Exception('Error in use case while sending boleta: $e');
    }
  }
} 