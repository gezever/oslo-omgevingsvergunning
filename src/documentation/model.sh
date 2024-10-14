#!/bin/bash
riot /home/gehau/git/OSLO/oslo-omgevingsvergunning/src/results/publicatie/* > /tmp/test.nt
  sparql --results=TTL --data=/tmp/test.nt --query model.rq  > model.ttl
  rdf2dot  model.ttl | dot -Tpng > model.png
  rdf2dot  model.ttl  > model.dot
