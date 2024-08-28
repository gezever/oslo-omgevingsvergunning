#!/bin/bash

#properties=( $(sparql --data=../main/resources/be/vlaanderen/data/id/applicatieprofiel/omgevingsvergunning/omgevingsvergunning.ttl --query ../sparql/test7.rq --results=CSV | tail -n +2) )
pushd ../results/check_properties
#for property in  ${properties[@]} ; do
#  p=`echo $property | cut -d '#' -f1`
#  file=$(basename ${p}).ttl
#
#  curl -s -H "Accept: text/turtle, application/rdf+xml"  -L ${p} > $file
#  riot $file > ${file/.ttl/.nt}
#done
#for property in  ${properties[@]} ; do
 # echo $property >> properties
#  p=`echo $property | cut -d '#' -f1`
#  file=$(basename ${p}).ttl
#  echo $property
#  echo ${file/.ttl/.nt}
#  grep $property *.nt
 # done
while read line; do
  if [ "$(grep "$line" property2)" != "" ]; then
    echo "found:     $line"
else
    echo "not found: $line"
fi
done < properties2

popd
