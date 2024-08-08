#!/bin/bash

curl --request GET -sL \
     --url 'https://data.vlaanderen.be/doc/applicatieprofiel/omgevingsvergunning/kandidaatstandaard/2024-06-20/context/omgevingsvergunning-ap.jsonld'\
     --output '../source/omgevingsvergunning-ap.jsonld'
curl --request GET -sL \
     --url 'https://data.vlaanderen.be/ns/omgevingsvergunning.ttl'\
     --output '../main/resources/be/vlaanderen/data/ns/omgevingsvergunning/omgevingsvergunning.ttl'

jq '..|select(contains("https://data.vlaanderen.be/ns/omgevingsvergunning#")?)' ../source/omgevingsvergunning-ap.jsonld | sort -u | sed -e 's/"//g' > /tmp/context.csv

sparql --data=../main/resources/be/vlaanderen/data/ns/omgevingsvergunning/omgevingsvergunning.ttl --query ../sparql/test1.rq --results=CSV | tr -d '\015'| sed '1d' | sort -u > /tmp/vocabularium.csv

diff /tmp/vocabularium.csv /tmp/context.csv


