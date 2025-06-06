class SalesDocument {
  final String fileName;
  final String status;
  final String type;
  final int issueTime;
  final String? xml;
  final String? cdr;
  final String? customerRuc;
  final String? customerName;
  final double? total;

  SalesDocument({
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

  factory SalesDocument.fromJson(Map<String, dynamic> json) {
    return SalesDocument(
      fileName: json['fileName'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      issueTime: json['issueTime'] ?? 0,
      xml: json['xml'],
      cdr: json['cdr'],
      customerRuc: json['customerRuc'],
      customerName: json['customerName'],
      total: (json['total'] as num?)?.toDouble(),
    );
  }
} 