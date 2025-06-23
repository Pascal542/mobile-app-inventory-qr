class BoletaResponse {
  final String status;
  final String documentId;

  BoletaResponse({
    required this.status,
    required this.documentId,
  });

  factory BoletaResponse.fromJson(Map<String, dynamic> json) {
    return BoletaResponse(
      status: json['status'] as String,
      documentId: json['documentId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'documentId': documentId,
  };
}

class BoletaDocumentStatus {
  final bool production;
  final String status;
  final String type;
  final int issueTime;
  final int responseTime;
  final String fileName;
  final String xml;
  final String cdr;
  final List<String> faults;
  final List<String> notes;
  final String personaId;
  final String? reference;

  BoletaDocumentStatus({
    required this.production,
    required this.status,
    required this.type,
    required this.issueTime,
    required this.responseTime,
    required this.fileName,
    required this.xml,
    required this.cdr,
    required this.faults,
    required this.notes,
    required this.personaId,
    this.reference,
  });

  factory BoletaDocumentStatus.fromJson(Map<String, dynamic> json) {
    return BoletaDocumentStatus(
      production: json['production'] as bool,
      status: json['status'] as String,
      type: json['type'] as String,
      issueTime: json['issueTime'] as int,
      responseTime: json['responseTime'] as int,
      fileName: json['fileName'] as String,
      xml: json['xml'] as String,
      cdr: json['cdr'] as String,
      faults: List<String>.from(json['faults'] as List),
      notes: List<String>.from(json['notes'] as List),
      personaId: json['personaId'] as String,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'production': production,
    'status': status,
    'type': type,
    'issueTime': issueTime,
    'responseTime': responseTime,
    'fileName': fileName,
    'xml': xml,
    'cdr': cdr,
    'faults': faults,
    'notes': notes,
    'personaId': personaId,
    'reference': reference,
  };
} 