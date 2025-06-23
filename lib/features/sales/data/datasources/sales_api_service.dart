import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sales_document.dart';

// TODO FALTA IMPLEMENTAR QUE PARTE DE LA INFO QUE MANDA SE MANDE A FIREBASE
// TODO POR EJEMPLO: 
/*
{
    "personaId": "683fbb3665e1970015000ce5",
    "personaToken": "DEV_... ---> aquí va tu 'personaToken'",
    "fileName": "10000000001-03-B001-00000021",
    "documentBody": {
        "cbc:UBLVersionID": {
            "_text": "2.1"
        },
        "cbc:CustomizationID": {
            "_text": "2.0"
        },
        "cbc:ID": {
            "_text": "B001-00000021"
        },
        "cbc:IssueDate": {
            "_text": "2025-06-06"
        },
        "cbc:IssueTime": {
            "_text": "01:16:13"
        },
        "cbc:InvoiceTypeCode": {
            "_attributes": {
                "listID": "0101"
            },
            "_text": "03"
        },
        "cbc:Note": [
            {
                "_text": "DIECISIETE CON 70/100 SOLES",
                "_attributes": {
                    "languageLocaleID": "1000"
                }
            }
        ],
        "cbc:DocumentCurrencyCode": {
            "_text": "PEN"
        },
        "cac:AccountingSupplierParty": {
            "cac:Party": {
                "cac:PartyIdentification": {
                    "cbc:ID": {
                        "_attributes": {
                            "schemeID": "6"
                        },
                        "_text": "10000000001"
                    }
                },
                "cac:PartyName": {
                    "cbc:Name": {
                        "_text": "Vendify"
                    }
                },
                "cac:PartyLegalEntity": {
                    "cbc:RegistrationName": {
                        "_text": "Vendify SAC"
                    },
                    "cac:RegistrationAddress": {
                        "cbc:AddressTypeCode": {
                            "_text": "0000"
                        }
                    }
                }
            }
        },
        "cac:AccountingCustomerParty": {
            "cac:Party": {
                "cac:PartyIdentification": {
                    "cbc:ID": {
                        "_attributes": {
                            "schemeID": "1"
                        },
                        "_text": "72699727"
                    }
                },
                "cac:PartyLegalEntity": {
                    "cbc:RegistrationName": {
                        "_text": "ALONSO EDUARDO SALAS CARDOZA"
                    },
                    "cac:RegistrationAddress": {
                        "cac:AddressLine": {
                            "cbc:Line": {
                                "_text": "CALLE ALBERTO LAFONT 240 BARRANCO LIMA LIMA"
                            }
                        }
                    }
                }
            }
        },
        "cac:TaxTotal": {
            "cbc:TaxAmount": {
                "_attributes": {
                    "currencyID": "PEN"
                },
                "_text": 2.7
            },
            "cac:TaxSubtotal": [
                {
                    "cbc:TaxableAmount": {
                        "_attributes": {
                            "currencyID": "PEN"
                        },
                        "_text": 15
                    },
                    "cbc:TaxAmount": {
                        "_attributes": {
                            "currencyID": "PEN"
                        },
                        "_text": 2.7
                    },
                    "cac:TaxCategory": {
                        "cac:TaxScheme": {
                            "cbc:ID": {
                                "_text": "1000"
                            },
                            "cbc:Name": {
                                "_text": "IGV"
                            },
                            "cbc:TaxTypeCode": {
                                "_text": "VAT"
                            }
                        }
                    }
                }
            ]
        },
        "cac:LegalMonetaryTotal": {
            "cbc:LineExtensionAmount": {
                "_attributes": {
                    "currencyID": "PEN"
                },
                "_text": 15
            },
            "cbc:TaxInclusiveAmount": {
                "_attributes": {
                    "currencyID": "PEN"
                },
                "_text": 17.7
            },
            "cbc:PayableAmount": {
                "_attributes": {
                    "currencyID": "PEN"
                },
                "_text": 17.7
            }
        },
        "cac:InvoiceLine": [
            {
                "cbc:ID": {
                    "_text": 1
                },
                "cbc:InvoicedQuantity": {
                    "_attributes": {
                        "unitCode": "NIU"
                    },
                    "_text": 3
                },
                "cbc:LineExtensionAmount": {
                    "_attributes": {
                        "currencyID": "PEN"
                    },
                    "_text": 15
                },
                "cac:PricingReference": {
                    "cac:AlternativeConditionPrice": {
                        "cbc:PriceAmount": {
                            "_attributes": {
                                "currencyID": "PEN"
                            },
                            "_text": 5.9
                        },
                        "cbc:PriceTypeCode": {
                            "_text": "01"
                        }
                    }
                },
                "cac:TaxTotal": {
                    "cbc:TaxAmount": {
                        "_attributes": {
                            "currencyID": "PEN"
                        },
                        "_text": 2.7
                    },
                    "cac:TaxSubtotal": [
                        {
                            "cbc:TaxableAmount": {
                                "_attributes": {
                                    "currencyID": "PEN"
                                },
                                "_text": 15
                            },
                            "cbc:TaxAmount": {
                                "_attributes": {
                                    "currencyID": "PEN"
                                },
                                "_text": 2.7
                            },
                            "cac:TaxCategory": {
                                "cbc:Percent": {
                                    "_text": 18
                                },
                                "cbc:TaxExemptionReasonCode": {
                                    "_text": "10"
                                },
                                "cac:TaxScheme": {
                                    "cbc:ID": {
                                        "_text": "1000"
                                    },
                                    "cbc:Name": {
                                        "_text": "IGV"
                                    },
                                    "cbc:TaxTypeCode": {
                                        "_text": "VAT"
                                    }
                                }
                            }
                        }
                    ]
                },
                "cac:Item": {
                    "cbc:Description": {
                        "_text": "pan"
                    }
                },
                "cac:Price": {
                    "cbc:PriceAmount": {
                        "_attributes": {
                            "currencyID": "PEN"
                        },
                        "_text": 5
                    }
                }
            }
        ]
    }
}
*/

class SalesApiService {
  static Future<List<SalesDocument>> fetchDocuments() async {
    try {
      // TODO: Implementar integración con Firebase para obtener documentos
      // Por ahora retornamos una lista vacía
      return [];
    } catch (e) {
      throw Exception('Error al obtener documentos: $e');
    }
  }

  static Future<void> saveDocumentToFirebase(SalesDocument document) async {
    try {
      await FirebaseFirestore.instance
          .collection('sales_documents')
          .add(document.toJson());
    } catch (e) {
      throw Exception('Error al guardar documento en Firebase: $e');
    }
  }
} 