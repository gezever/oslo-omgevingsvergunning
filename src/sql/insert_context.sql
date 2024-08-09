
INSERT INTO b_omv_oslo.context(
    context)
VALUES ('{
  "id": {
    "@id" : "@id",
    "@type" : "@id"
  },
  "type" : {
    "@id" : "@type",
    "@type" : "@id"
  },
  "aanleiding": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#aanleiding",
    "@type": "@id"
  },
  "identifier" : {
    "@id": "http://www.w3.org/ns/adms#identifier",
    "@type" : "@id"
  },
  "identificator" : {
    "@id": "http://www.w3.org/ns/adms#identifier",
    "@type" : "@id"
  },
  "procedure": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#procedure",
    "@type": "@id"
  },
  "zaak_naar_zaak": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#verwanteZaak",
    "@type": "@id"
  },
  "reverse_handeling":{
    "@type": "@id",
    "@reverse": "zaakhandeling"
  },
  "zaakhandeling": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#zaakhandeling",
    "@type": "@id"
  },
  "bekendmaking": {
    "@container": "@set",
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#bekendmaking",
    "@type": "@id"
  },
  "document": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#document",
    "@type": "@id"
  },
  "ingangsdatum": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#ingangsdatum",
    "@type": "http://www.w3.org/2001/XMLSchema#date"
  },
  "inhoud": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#inhoud",
    "@type": "@id"
  },
  "juridische_kwalificatie": {
    "@container": "@set",
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#juridischeKwalificatie",
    "@type": "@id"
  },
  "verantwoordelijke": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#verantwoordelijke",
    "@type": "@id"
  },
  "procedurestap": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#procedurestap",
    "@type": "@id"
  },
  "adres": {
    "@id": "http://www.w3.org/ns/locn#address",
    "@type": "@id"
  },
  "geometrie": {
    "@id": "http://www.opengis.net/ont/geosparql#hasGeometry",
    "@type": "@id"
  },
  "landgebruik": {
    "@id": "https://data.vlaanderen.be/ns/perceel#landgebruik",
    "@type": "@id"
  },
  "niveau": {
    "@id": "https://data.vlaanderen.be/ns/perceel#niveau",
    "@type": "http://www.w3.org/2001/XMLSchema#integer"
  },
  "oppervlakte": {
    "@id": "https://data.vlaanderen.be/ns/perceel#RuimtelijkeEenheid.oppervlakte",
    "@type": "@id"
  },
  "beschrijving": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#beschrijving",
    "@type": "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"
  },
  "reverse_is_deel_van":  {
    "@type": "@id",
    "@reverse": "heeft_deel"
  },
  "heeft_deel":  {
    "@id": "http://purl.org/dc/terms/hasPart",
    "@type": "@id"
  },
  "is_deel_van":  {
    "@id": "http://purl.org/dc/terms/isPartOf",
    "@type": "@id"
  },
  "locatie": {
    "@id": "https://data.vlaanderen.be/ns/omgevingsvergunning#locatie",
    "@type": "@id"
  },
  "concept": "https://data.omv.vlaanderen.be/id/concept/",
  "dbo" : "http://dbpedia.org/ontology/casNumber",
  "eurovoc": "http://eurovoc.europa.eu/",
  "omv": "https://data.vlaanderen.be/ns/omgevingsvergunning#",
  "project": "https://data.omv.vlaanderen.be/id/project/",
  "voorwerp": "https://data.omv.vlaanderen.be/id/voorwerp/",
  "zaak_handeling": "https://data.omv.vlaanderen.be/id/zaakhandeling/",
  "zaak": "https://data.omv.vlaanderen.be/id/zaak/"
}'::jsonb);