# Inicio

DISCLAIMER: APISUNAT.com es un servicio privado. No es operado por SUNAT.

APISUNAT es un servicio de facturación electrónica en la nube que genera, firma, envía y almacena tus comprobantes y sus respectivas CDR. Dejándote como única tarea enviarnos el contenido en formato JSON a través de nuestra API REST.

Ya no necesitas saber programar. Ahora también puedes enviar tus comprobantes manualmente desde nuestro portal web sin usar la API REST.

Tipos de Documentos

Definiciones

Flujo en Producción y Desarrollo

1. Tipos de Documentos
Actualmente puedes enviar los siguientes documentos:

Código Nombre del Documento

01 Factura

03 Boleta de Venta


SUNAT permite el envío de otros documentos como Comprobantes de percepción, retención, etc. Los cuales agregaremos próximamente.

2. Definiciones
CPE: Comprobante de Pago Electrónico

GRE: Guía de Remisión Electrónica

XML: Archivo firmado que contiene la información del CPE

CDR: "Constancia De Recepción" que emite la SUNAT al recibir un CPE

PDF: Representación gráfica del XML

CDT: Certificado Digital Tributario. Archivo necesario para firmar el XML

OSE: "Operador de Servicios Electrónicos". Son empresas autorizadas para validar los comprobantes. Reemplazando la función de la SUNAT.

PSE: "Proveedor de Servicios Electrónicos". Son empresas autorizadas para firmar (con su propio CDT) los CPE de otras empresas.

SEE - Del Contribuyente: "Sistema de Emisión Electrónica" (como APISUNAT.com) mediante el cual cualquier contribuyente puede enviar sus CPE directamente a la SUNAT

Usuario Secundario: Debe ser creado en la web de la SUNAT y asignarle los permisos respectivos

DESARROLLO: Es el "modo de pruebas". Tus comprobantes no se envían a SUNAT.

PRODUCCIÓN: Es "la vida real". Tus comprobantes se informan a SUNAT y tienen valor legal.

3. Flujo en Desarrollo y Producción
Desarrollo Producción

✔️ ✔️ Emisión (se crea, firma y almacena el XML) 

✔️ ✔️ Validación del XML (*) \

❌ ✔️ Información a la SUNAT

✔️ ✔️ Recepción y almacenamiento del CDR

(*) La validación en ambos casos es hecha por SUNAT. Esta puede tener diferencias en desarrollo y producción. En el caso de desarrollo, por ejemplo, no se valida la firma.

Emisión: Es el proceso de generar el archivo XML. Si está correctamente estructurado, el documento quedará en estado PENDIENTE hasta recibir la respuesta de la SUNAT.

Validación: Unos instantes después SUNAT valida el XML. En este paso nos devuelve uno de tres estados posibles:

EXCEPCION cuando se rechaza el documento y no tiene ningún valor. Como si nunca lo hubieras enviado.

RECHAZADO cuando se rechaza pero la numeración queda usada. Ya no puedes usar la misma serie-número.

ACEPTADO cuando es aceptado. En este caso puede haber alguna observación pero igual es válido.

Información: Si el documento es RECHAZADO o ACEPTADO, este se considera informado. SUNAT retornará un CDR (Constancia De Recepción) que debes almacenar junto al XML por lo que indique la norma.

No te preocupes que nosotros almacenamos los archivos XML y CDR por ti. Podrás verlos y descargarlos en cualquier momento desde nuestro Portal Web.

Si ves un documento en estado PENDIENTE por más tiempo de lo normal, posiblemente sea por fallas en los servidores de SUNAT. Nosotros volvemos a enviar los documentos cada cierto tiempo hasta recibir una respuesta.

Si activas la opción de "Informar mediante OSE" el flujo es exactamente el mismo pero el OSE reemplaza a la SUNAT.

# URL y Autenticación 

Ambientes
Existen dos ambientes DESARROLLO y PRODUCCIÓN. Para ambos casos la URL del servicio es la misma.

URL del servicio
Copiar
https://back.apisunat.com
Autenticación
La token de autorización para nuestra API se llama personaToken. Cada empresa puede tener una o varias tokens. Las puedes crear o eliminar en la sección Configuración de Empresa en apisunat.com


Captura de la sección "Configuración de Empresa" en apisunat.com
Cada token funciona solo para su empresa y solo para el ambiente elegido PRODUCCIÓN o DESARROLLO.


# /personas

Endpoints para el envío y anulación de documentos

sendBill
POST URL /personas/v1/sendBill

Envío de documentos

Request Body

Name Type Description
personaId* string Identificador de tu empresa

personaToken* string Token de acceso de tu empresa

fileName* string Nombre que usaremos para el archivo XML según parámetros de SUNAT. RRRRRRRRRRR-TT-SSSS-CCCCCCCC

Donde:
R = RUC (11 dígitos)
T = Código de tipo de documento (2 dígitos)
S = Serie (4 caracteres)
C = Número correlativo (8 dígitos)

Serie:
Para poder enviar documentos debes habilitar las series en el portal en la sección de Configuración de Empresa. Estas deben tener como primer carácter una letra definida por el tipo de documento:

Factura debe empezar con "F001".

Boleta de Venta debe empezar con "B001".

Ejemplo:
"fileName": "20123456789-01-F001-00000001"

documentBody* object Objeto con todos los datos del documento

customerEmail string Email del adquiriente. Si lo pones le enviaremos el documento luego de ser emitido.

EJM:
200: OK El valor status esperado es PENDIENTE
{
    "status": "PENDIENTE",
    "documentId": "5d4g1e88b30104056706dffe"
}


voidBill

POST URL /personas/v1/voidBill

Anulación de documentos

Request Body

Name Type Description
personaId* string Identificador de tu empresa

personaToken* string Token de acceso de tu empresa

documentId* string Identificador del documento que se va a anular

reason* string Motivo de la anulación (3 - 100 caracteres)

EJM:
200: OK El valor status esperado es PENDIENTE
{
    "status": "PENDIENTE",
    "documentId": "5d4g1e88b30104056706dffe"
}


lastDocument
POST URL /personas/lastDocument

Obtener el número correlativo

Request Body

Name Type Description
personaId* string Identificador de tu empresa

personaToken* string Token de acceso de tu empresa

type* string Código de tipo de documento (2 dígitos)

serie* string Serie (4 caracteres)

EJM:
200: OK
{
    "personaId": "5f6cd73425f5c52d375dd55c",
    "production": true,
    "type": "01",
    "serie": "F001",
    "lastNumber":"00000001",
    "suggestedNumber":"00000002"
}


documentBody:

EJM:
Aca se muestra un json que se genera desde la app web para crear una boleta de pago  de 5 soles de venta de un producto con todos los campos llenos que se debe de usar como base para pedir en la app.

{
    "personaId": "6824b806a147e600158bc57e",
    "personaToken": "DEV_... ---> aquí va tu 'personaToken'",
    "fileName": "10111111111-03-B001-00000001",
    "documentBody": {
        "cbc:UBLVersionID": {
            "_text": "2.1"
        },
        "cbc:CustomizationID": {
            "_text": "2.0"
        },
        "cbc:ID": {
            "_text": "B001-00000001"
        },
        "cbc:IssueDate": {
            "_text": "2025-05-14"
        },
        "cbc:IssueTime": {
            "_text": "14:35:17"
        },
        "cbc:InvoiceTypeCode": {
            "_attributes": {
                "listID": "0101"
            },
            "_text": "03"
        },
        "cbc:Note": [
            {
                "_text": "CINCO CON 90/100 SOLES",
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
                        "_text": "10111111111"
                    }
                },
                "cac:PartyName": {
                    "cbc:Name": {
                        "_text": "NOMBRECOMERCIALOPCIONAL"
                    }
                },
                "cac:PartyLegalEntity": {
                    "cbc:RegistrationName": {
                        "_text": "EMPRESATEST"
                    },
                    "cac:RegistrationAddress": {
                        "cbc:AddressTypeCode": {
                            "_text": "0000"
                        },
                        "cac:AddressLine": {
                            "cbc:Line": {
                                "_text": "DIRECCIONOPCIONAL"
                            }
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
                "_text": 0.9
            },
            "cac:TaxSubtotal": [
                {
                    "cbc:TaxableAmount": {
                        "_attributes": {
                            "currencyID": "PEN"
                        },
                        "_text": 5
                    },
                    "cbc:TaxAmount": {
                        "_attributes": {
                            "currencyID": "PEN"
                        },
                        "_text": 0.9
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
                "_text": 5
            },
            "cbc:TaxInclusiveAmount": {
                "_attributes": {
                    "currencyID": "PEN"
                },
                "_text": 5.9
            },
            "cbc:PayableAmount": {
                "_attributes": {
                    "currencyID": "PEN"
                },
                "_text": 5.9
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
                    "_text": 1
                },
                "cbc:LineExtensionAmount": {
                    "_attributes": {
                        "currencyID": "PEN"
                    },
                    "_text": 5
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
                        "_text": 0.9
                    },
                    "cac:TaxSubtotal": [
                        {
                            "cbc:TaxableAmount": {
                                "_attributes": {
                                    "currencyID": "PEN"
                                },
                                "_text": 5
                            },
                            "cbc:TaxAmount": {
                                "_attributes": {
                                    "currencyID": "PEN"
                                },
                                "_text": 0.9
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
                        "_text": "PRODUCTO PRUEBA 1"
                    },
                    "cac:SellersItemIdentification": {
                        "cbc:ID": {
                            "_text": "01"
                        }
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

ACA TE ESCRIBO LAS CONSTANTES DE LA EMPRESA EN LA QUE SE ESTA TRABAJANDO

Nombre de empresa: EMPRESATEST
Nombre comercial opcional: NOMBRECOMERCIALOPCIONAL
Direccion opcional: DIRECCIONOPCIONAL
RUC: 10111111111
PersonaId: 6824b806a147e600158bc57e
PersonaToken: DEV_d11qF6fPYU6qTt1q443CQHP8FEtw80O1RZbSOxoWAO16peCPAdhyqj9vCs6cDFwv


Seguimos con los enpoints de documentos:

# /documents

Endpoints para la recuperación de documentos

getById
GET URL /documents/:documentId/getById

Recuperación de un documento

Path Parameters

Name Type Description
documentId* string ID del documento. Se obtiene como respuesta del método sendBill


200: OK El status puede ser ACEPTADO, RECHAZADO o EXCEPCION
{
    "production": true,
    "status": "ACEPTADO",
    "type": "01",
    "issueTime": 1604698592, // fecha de emisión
    "responseTime": 1604698788, // fecha de respuesta SUNAT
    "fileName": "20123456789-01-F001-00000001",
    "xml": "https://...",
    "cdr": "https://...",
    "faults": [], // arreglo de errores
    "notes": [], // arreglo de observaciones
    "personaId": "5f6cd73425f5c52d375dd55c",
    "reference": "referencia enviada al momento de emitir..."
}


getAll
GET URL /documents/getAll?personaId=[:personaId]&personaToken=[:personaToken]&...

Recuperación de varios documentos

Query Parameters
Name

Type

Description

personaId*

string

Identificador de tu empresa

personaToken*

string

Token de acceso de tu empresa

limit

number

Limita la cantidad de documentos retornados (max. 100)

skip

number

Salta cierta cantidad de documentos

from

number

(desde) fecha de emisión en formato UNIX

to

number

(hasta) fecha de emisión en formato UNIX

status

string

Estado del documento. Puede ser PENDIENTE, EXCEPCION, ACEPTADO o RECHAZADO

type

string

Código del tipo de documento. Puede ser 01, 03, D1, etc

order

String

Puede ser ASC, o DESC

serie

String

Serie del documento

number

String

Correlativo del documento (8 dígitos)



EJM:
200: OK Devuelve un array de documentos. El orden por defecto es el de creación, no el de emisión.

[
    {
        "production": true,
        "status": "ACEPTADO",
        "type": "01",
        "issueTime": 1604698592, // fecha de emisión
        "responseTime": 1604698788, // fecha de respuesta SUNAT
        "fileName": "20123456789-01-F001-00000001",
        "xml": "https://...",
        "cdr": "https://...",
        "faults": [], // arreglo de errores
        "notes": [], // arreglo de observaciones
        "personaId": "5f6cd73425f5c52d375dd55c",
        "reference": "referencia enviada al momento de emitir..."
    },
    //...
]



getPDF
GET URL /documents/:documentId/getPDF/:format/:fileName[.pdf]

Generación de la representación impresa

Path Parameters
Name
Type
Description
documentId*

string

ID del documento. Se obtiene como respuesta del método sendBill

format*

string

Actualmente puede ser A4, A5, ticket58mm o ticket80mm

fileName[.pdf]*

string

Nombre usado para el archivo, agregando .pdf al final.


Ejemplo: 20606170514-01-F001-00000001.pdf

EJM:
200: OK
// representación impresa del documento en formato PDF