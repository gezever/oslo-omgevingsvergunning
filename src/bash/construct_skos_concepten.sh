#!/bin/bash

#riot --formatted=turtle ../results/dwh_mapping/radar_oslo.ttl > ../results/publicatie/radar_oslo.ttl
#riot  ../results/dwh_mapping/radar_oslo.ttl > ../results/publicatie/radar_oslo.nt
for i in `ls /tmp/*ttl`; do
sparql --data=$i --query ../sparql/construct_skos_concepten.rq --results=TURTLE >> ../results/publicatie/radar_oslo_concepten.ttl
done

#/home/gehau/Documents/evaluatie_oslo_omgevingsvergunning/concepten.nt

sparql --data=/home/gehau/Documents/evaluatie_oslo_omgevingsvergunning/concepten.nt --query ../sparql/construct_skos_concepten.rq --results=TURTLE >> ../results/publicatie/radar_oslo_concepten.ttl
