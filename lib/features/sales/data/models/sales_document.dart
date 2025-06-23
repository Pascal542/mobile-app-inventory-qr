/// Modelo de datos para representar un documento de venta (factura o boleta)
/// 
/// Este modelo contiene toda la información necesaria para gestionar
/// documentos electrónicos emitidos a través de la API de SUNAT.
class SalesDocument {
  /// ID único del documento
  final String documentId;
  
  /// Nombre del archivo del documento
  final String fileName;
  
  /// Estado del documento (accepted, rejected, pending)
  final String status;
  
  /// Tipo de documento (01: Factura, 03: Boleta)
  final String type;
  
  /// Timestamp de emisión del documento
  final int issueTime;
  
  /// Contenido XML del documento (opcional)
  final String? xml;
  
  /// Contenido CDR (Constancia de Recepción) del documento (opcional)
  final String? cdr;
  
  /// RUC del cliente (opcional)
  final String? customerRuc;
  
  /// Nombre del cliente (opcional)
  final String? customerName;
  
  /// Monto total del documento (opcional)
  final double? total;

  /// Constructor del modelo SalesDocument
  /// 
  /// [documentId] - ID único del documento
  /// [fileName] - Nombre del archivo del documento
  /// [status] - Estado del documento
  /// [type] - Tipo de documento
  /// [issueTime] - Timestamp de emisión
  /// [xml] - Contenido XML (opcional)
  /// [cdr] - Contenido CDR (opcional)
  /// [customerRuc] - RUC del cliente (opcional)
  /// [customerName] - Nombre del cliente (opcional)
  /// [total] - Monto total (opcional)
  const SalesDocument({
    required this.documentId,
    required this.fileName,
    required this.status,
    required this.type,
    required this.issueTime,
    this.xml,
    this.cdr,
    this.customerRuc,
    this.customerName,
    this.total,
  });

  /// Factory constructor para convertir un JSON en un SalesDocument
  /// 
  /// [json] - Mapa con los datos del documento
  /// 
  /// Retorna un objeto SalesDocument con los datos extraídos del JSON
  factory SalesDocument.fromJson(Map<String, dynamic> json) {
    return SalesDocument(
      documentId: json['documentId']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      issueTime: (json['issueTime'] as num?)?.toInt() ?? 0,
      xml: json['xml']?.toString(),
      cdr: json['cdr']?.toString(),
      customerRuc: json['customerRuc']?.toString(),
      customerName: json['customerName']?.toString(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }

  /// Convierte el documento a JSON
  /// 
  /// Retorna un Map<String, dynamic> con los datos del documento
  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'fileName': fileName,
      'status': status,
      'type': type,
      'issueTime': issueTime,
      'xml': xml,
      'cdr': cdr,
      'customerRuc': customerRuc,
      'customerName': customerName,
      'total': total,
    };
  }

  /// Crea una copia del documento con cambios opcionales
  /// 
  /// Todos los parámetros son opcionales y mantienen el valor original si no se especifican
  /// 
  /// Retorna un nuevo objeto SalesDocument con los cambios aplicados
  SalesDocument copyWith({
    String? documentId,
    String? fileName,
    String? status,
    String? type,
    int? issueTime,
    String? xml,
    String? cdr,
    String? customerRuc,
    String? customerName,
    double? total,
  }) {
    return SalesDocument(
      documentId: documentId ?? this.documentId,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      type: type ?? this.type,
      issueTime: issueTime ?? this.issueTime,
      xml: xml ?? this.xml,
      cdr: cdr ?? this.cdr,
      customerRuc: customerRuc ?? this.customerRuc,
      customerName: customerName ?? this.customerName,
      total: total ?? this.total,
    );
  }

  /// Valida si el documento tiene datos válidos
  /// 
  /// Un documento es válido si:
  /// - Tiene un documentId no vacío
  /// - Tiene un fileName no vacío
  /// - Tiene un status no vacío
  /// - Tiene un type no vacío
  /// - Tiene un issueTime válido (mayor a 0)
  bool get isValid => 
    documentId.isNotEmpty && 
    fileName.isNotEmpty && 
    status.isNotEmpty && 
    type.isNotEmpty && 
    issueTime > 0;

  /// Obtiene el estado del documento formateado en español
  /// 
  /// Retorna el estado traducido: accepted -> Aceptado, rejected -> Rechazado, etc.
  String get statusFormatted {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Aceptado';
      case 'rejected':
        return 'Rechazado';
      case 'pending':
        return 'Pendiente';
      default:
        return status;
    }
  }

  /// Obtiene el tipo de documento formateado en español
  /// 
  /// Retorna el tipo traducido: 01 -> Factura, 03 -> Boleta
  String get typeFormatted {
    switch (type) {
      case '03':
        return 'Boleta';
      case '01':
        return 'Factura';
      default:
        return type;
    }
  }

  /// Obtiene el total formateado con símbolo de moneda
  /// 
  /// Retorna el total con formato "S/ X.XX" o "N/A" si no hay total
  String get totalFormatted => 
    total != null ? 'S/ ${total!.toStringAsFixed(2)}' : 'N/A';

  /// Obtiene la fecha de emisión formateada
  /// 
  /// Retorna la fecha en formato DD/MM/YYYY
  String get dateFormatted {
    final date = DateTime.fromMillisecondsSinceEpoch(issueTime * 1000);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  String toString() {
    return 'SalesDocument(documentId: $documentId, fileName: $fileName, status: $status, type: $type, issueTime: $issueTime, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesDocument &&
        other.documentId == documentId &&
        other.fileName == fileName &&
        other.status == status &&
        other.type == type &&
        other.issueTime == issueTime &&
        other.xml == xml &&
        other.cdr == cdr &&
        other.customerRuc == customerRuc &&
        other.customerName == customerName &&
        other.total == total;
  }

  @override
  int get hashCode {
    return Object.hash(
      documentId, 
      fileName, 
      status, 
      type, 
      issueTime, 
      xml, 
      cdr, 
      customerRuc, 
      customerName, 
      total,
    );
  }
} 