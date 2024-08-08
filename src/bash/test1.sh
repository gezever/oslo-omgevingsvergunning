#!/bin/bash

curl --request GET -sL \
     --url 'https://data.vlaanderen.be/doc/applicatieprofiel/omgevingsvergunning/kandidaatstandaard/2024-06-20/shacl/omgevingsvergunning-ap-SHACL.ttl'\
     --output '../main/resources/be/vlaanderen/data/id/applicatieprofiel/omgevingsvergunning/omgevingsvergunning-ap-SHACL.ttl'
curl --request GET -sL \
     --url 'https://data.vlaanderen.be/ns/omgevingsvergunning.ttl'\
     --output '../main/resources/be/vlaanderen/data/ns/omgevingsvergunning/omgevingsvergunning.ttl'

sparql --data=../main/resources/be/vlaanderen/data/id/applicatieprofiel/omgevingsvergunning/omgevingsvergunning-ap-SHACL.ttl --query ../sparql/test1.rq --results=CSV > /tmp/shacl.csv

sparql --data=../main/resources/be/vlaanderen/data/ns/omgevingsvergunning/omgevingsvergunning.ttl --query ../sparql/test1.rq --results=CSV > /tmp/vocabularium.csv

diff /tmp/vocabularium.csv /tmp/shacl.csv
