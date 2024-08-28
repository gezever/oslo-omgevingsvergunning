#!/bin/bash

pushd ../main/resources/org/purl/vocab/cpsv
curl -O https://joinup.ec.europa.eu/sites/default/files/distribution/2013-11/cpsv_101.ttl
popd
pushd ../main/resources/org/purl/vocab/frbr/core
curl -O https://vocab.org/frbr/frbr-core-20050810.rdf
riot --formatted=turtle https://vocab.org/frbr/frbr-core-20050810.rdf > https://vocab.org/frbr/frbr-core-20050810.ttl
popd

pushd ../main/resources/be/vlaanderen/data/ns/omgevingsvergunning
curl -O https://data.vlaanderen.be/ns/omgevingsvergunning.ttl