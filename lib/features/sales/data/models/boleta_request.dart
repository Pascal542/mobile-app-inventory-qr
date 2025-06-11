class BoletaRequest {
  final String personaId;
  final String personaToken;
  final String fileName;
  final BoletaDocumentBody documentBody;

  BoletaRequest({
    required this.personaId,
    required this.personaToken,
    required this.fileName,
    required this.documentBody,
  });

  Map<String, dynamic> toJson() => {
        'personaId': personaId,
        'personaToken': personaToken,
        'fileName': fileName,
        'documentBody': documentBody.toJson(),
      };
}

class BoletaDocumentBody {
  final String ublVersionId;
  final String customizationId;
  final String id;
  final String issueDate;
  final String issueTime;
  final String invoiceTypeCode;
  final List<Note> notes;
  final String documentCurrencyCode;
  final AccountingSupplierParty accountingSupplierParty;
  final AccountingCustomerParty accountingCustomerParty;
  final TaxTotal taxTotal;
  final LegalMonetaryTotal legalMonetaryTotal;
  final List<InvoiceLine> invoiceLines;

  BoletaDocumentBody({
    required this.ublVersionId,
    required this.customizationId,
    required this.id,
    required this.issueDate,
    required this.issueTime,
    required this.invoiceTypeCode,
    required this.notes,
    required this.documentCurrencyCode,
    required this.accountingSupplierParty,
    required this.accountingCustomerParty,
    required this.taxTotal,
    required this.legalMonetaryTotal,
    required this.invoiceLines,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'cbc:UBLVersionID': {'_text': ublVersionId},
      'cbc:CustomizationID': {'_text': customizationId},
      'cbc:ID': {'_text': id},
      'cbc:IssueDate': {'_text': issueDate},
      'cbc:IssueTime': {'_text': issueTime},
      'cbc:InvoiceTypeCode': {
        '_attributes': {'listID': '0101'},
        '_text': invoiceTypeCode,
      },
      'cbc:Note': notes.map((note) => note.toJson()).toList(),
      'cbc:DocumentCurrencyCode': {'_text': documentCurrencyCode},
      'cac:AccountingSupplierParty': accountingSupplierParty.toJson(),
      'cac:AccountingCustomerParty': accountingCustomerParty.toJson(),
      'cac:TaxTotal': taxTotal.toJson(),
      'cac:LegalMonetaryTotal': legalMonetaryTotal.toJson(),
      'cac:InvoiceLine': invoiceLines.map((line) => line.toJson()).toList(),
    };
    if (invoiceTypeCode == '01') {
      map['cac:PaymentTerms'] = [
        {
          'cbc:ID': {'_text': 'FormaPago'},
          'cbc:PaymentMeansID': {'_text': 'Contado'},
        }
      ];
    }
    return map;
  }
}

class Note {
  final String text;
  final String languageLocaleId;

  Note({required this.text, required this.languageLocaleId});

  Map<String, dynamic> toJson() => {
        '_text': text,
        '_attributes': {'languageLocaleID': languageLocaleId},
      };
}

class AccountingSupplierParty {
  final String id;
  final String registrationName;
  final String? partyName;
  final String? address;

  AccountingSupplierParty({
    required this.id,
    required this.registrationName,
    this.partyName,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'cac:Party': {
          'cac:PartyIdentification': {
            'cbc:ID': {
              '_attributes': {'schemeID': '6'},
              '_text': id,
            },
          },
          if (partyName != null)
            'cac:PartyName': {
              'cbc:Name': {'_text': partyName},
            },
          'cac:PartyLegalEntity': {
            'cbc:RegistrationName': {'_text': registrationName},
            if (address != null)
              'cac:RegistrationAddress': {
                'cbc:AddressTypeCode': {'_text': '0000'},
                'cac:AddressLine': {
                  'cbc:Line': {'_text': address},
                },
              },
          },
        },
      };
}

class AccountingCustomerParty {
  final String id;
  final String registrationName;
  final String schemeId;
  final String? address;

  AccountingCustomerParty({
    required this.id,
    required this.registrationName,
    required this.schemeId,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'cac:Party': {
          'cac:PartyIdentification': {
            'cbc:ID': {
              '_attributes': {'schemeID': schemeId},
              '_text': id,
            },
          },
          'cac:PartyLegalEntity': {
            'cbc:RegistrationName': {'_text': registrationName},
            if (address != null)
              'cac:RegistrationAddress': {
                'cac:AddressLine': {
                  'cbc:Line': {'_text': address},
                },
              },
          },
        },
      };
}

class TaxTotal {
  final double taxAmount;
  final List<TaxSubtotal> taxSubtotals;

  TaxTotal({
    required this.taxAmount,
    required this.taxSubtotals,
  });

  Map<String, dynamic> toJson() => {
        'cbc:TaxAmount': {
          '_attributes': {'currencyID': 'PEN'},
          '_text': taxAmount,
        },
        'cac:TaxSubtotal': taxSubtotals.map((subtotal) => subtotal.toJson()).toList(),
      };
}

class TaxSubtotal {
  final double taxableAmount;
  final double taxAmount;
  final TaxCategory taxCategory;

  TaxSubtotal({
    required this.taxableAmount,
    required this.taxAmount,
    required this.taxCategory,
  });

  Map<String, dynamic> toJson() => {
        'cbc:TaxableAmount': {
          '_attributes': {'currencyID': 'PEN'},
          '_text': taxableAmount,
        },
        'cbc:TaxAmount': {
          '_attributes': {'currencyID': 'PEN'},
          '_text': taxAmount,
        },
        'cac:TaxCategory': taxCategory.toJson(),
      };
}

class TaxCategory {
  final double percent;
  final String taxExemptionReasonCode;
  final TaxScheme taxScheme;

  TaxCategory({
    required this.percent,
    required this.taxExemptionReasonCode,
    required this.taxScheme,
  });

  Map<String, dynamic> toJson() => {
        'cbc:Percent': {'_text': percent},
        'cbc:TaxExemptionReasonCode': {'_text': taxExemptionReasonCode},
        'cac:TaxScheme': taxScheme.toJson(),
      };
}

class TaxScheme {
  final String id;
  final String name;
  final String taxTypeCode;

  TaxScheme({
    required this.id,
    required this.name,
    required this.taxTypeCode,
  });

  Map<String, dynamic> toJson() => {
        'cbc:ID': {'_text': id},
        'cbc:Name': {'_text': name},
        'cbc:TaxTypeCode': {'_text': taxTypeCode},
      };
}

class LegalMonetaryTotal {
  final double lineExtensionAmount;
  final double taxInclusiveAmount;
  final double payableAmount;

  LegalMonetaryTotal({
    required this.lineExtensionAmount,
    required this.taxInclusiveAmount,
    required this.payableAmount,
  });

  Map<String, dynamic> toJson() => {
        'cbc:LineExtensionAmount': {
          '_attributes': {'currencyID': 'PEN'},
          '_text': lineExtensionAmount,
        },
        'cbc:TaxInclusiveAmount': {
          '_attributes': {'currencyID': 'PEN'},
          '_text': taxInclusiveAmount,
        },
        'cbc:PayableAmount': {
          '_attributes': {'currencyID': 'PEN'},
          '_text': payableAmount,
        },
      };
}

class InvoiceLine {
  final int id;
  final int invoicedQuantity;
  final double lineExtensionAmount;
  final PricingReference pricingReference;
  final TaxTotal taxTotal;
  final Item item;
  final Price price;

  InvoiceLine({
    required this.id,
    required this.invoicedQuantity,
    required this.lineExtensionAmount,
    required this.pricingReference,
    required this.taxTotal,
    required this.item,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'cbc:ID': {'_text': id},
        'cbc:InvoicedQuantity': {
          '_attributes': {'unitCode': 'NIU'},
          '_text': invoicedQuantity,
        },
        'cbc:LineExtensionAmount': {
          '_attributes': {'currencyID': 'PEN'},
          '_text': lineExtensionAmount,
        },
        'cac:PricingReference': pricingReference.toJson(),
        'cac:TaxTotal': taxTotal.toJson(),
        'cac:Item': item.toJson(),
        'cac:Price': price.toJson(),
      };
}

class PricingReference {
  final double priceAmount;
  final String priceTypeCode;

  PricingReference({
    required this.priceAmount,
    required this.priceTypeCode,
  });

  Map<String, dynamic> toJson() => {
        'cac:AlternativeConditionPrice': {
          'cbc:PriceAmount': {
            '_attributes': {'currencyID': 'PEN'},
            '_text': priceAmount,
          },
          'cbc:PriceTypeCode': {'_text': priceTypeCode},
        },
      };
}

class Item {
  final String description;
  final String sellersItemId;

  Item({
    required this.description,
    required this.sellersItemId,
  });

  Map<String, dynamic> toJson() => {
        'cbc:Description': {'_text': description},
        'cac:SellersItemIdentification': {
          'cbc:ID': {'_text': sellersItemId},
        },
      };
}

class Price {
  final double priceAmount;

  Price({required this.priceAmount});

  Map<String, dynamic> toJson() => {
        'cbc:PriceAmount': {
          '_attributes': {'currencyID': 'PEN'},
          '_text': priceAmount,
        },
      };
} 