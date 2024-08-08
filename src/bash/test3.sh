#!/bin/bash


curl --request GET -sL \
     --url 'https://data.vlaanderen.be/ns/omgevingsvergunning.ttl'\
     --output '../main/resources/be/vlaanderen/data/ns/omgevingsvergunning/omgevingsvergunning.ttl'

sparql --data=../main/resources/be/vlaanderen/data/ns/omgevingsvergunning/omgevingsvergunning.ttl --query ../sparql/test3a.rq --results=CSV > /tmp/range_domain.csv

sparql --data=../main/resources/be/vlaanderen/data/ns/omgevingsvergunning/omgevingsvergunning.ttl --query ../sparql/test3b.rq --results=CSV > /tmp/definition.csv

diff /tmp/range_domain.csv /tmp/definition.csv | grep '^<'