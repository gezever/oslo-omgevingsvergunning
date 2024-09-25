#!/bin/bash

#issue https://github.com/Informatievlaanderen/OSLOthema-omgevingsvergunning/issues/19
curl --request GET -sL \
     --url 'https://data.vlaanderen.be/doc/applicatieprofiel/omgevingsvergunning/kandidaatstandaard/2024-09-12/context/omgevingsvergunning-ap.jsonld'\
     --output '../source/omgevingsvergunning-ap.jsonld'


curl --request GET -sL \
     --url 'https://data.vlaanderen.be/doc/applicatieprofiel/omgevingsvergunning/kandidaatstandaard/2024-09-12/shacl/omgevingsvergunning-ap-SHACL.ttl'\
     --output '../main/resources/be/vlaanderen/data/id/applicatieprofiel/omgevingsvergunning/omgevingsvergunning-ap-SHACL.ttl'


jq '..|select(contains("https://data.vlaanderen.be/ns/perceel#adres")?)' ../source/omgevingsvergunning-ap.jsonld

sparql --data=../main/resources/be/vlaanderen/data/id/applicatieprofiel/omgevingsvergunning/omgevingsvergunning-ap-SHACL.ttl --query ../sparql/test4.rq --results=CSV


