#!/bin/bash
  sparql --results=TTL --data=../results/dwh_mapping/radar_oslo.ttl  --query model.rq  > model.ttl
  rdf2dot  model.ttl | dot -Tpng > model.png
  rdf2dot  model.ttl  > model.dot
