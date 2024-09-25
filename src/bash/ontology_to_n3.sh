#!/bin/bash


if [ -n "$1" ]; then
riot ${1} > /tmp/ontology.nt
cat /tmp/ontology.nt | grep 'http://www.w3.org/2000/01/rdf-schema#domain' | sort -u | grep -v '_:' | sed -e 's/^/{ ?x /' | sed -e 's; <http://www.w3.org/2000/01/rdf-schema#domain> ; ?y } => { ?x a ;' | sed -e 's/\.$/} ./ ' > ${1/.ttl/.n3}
cat /tmp/ontology.nt | grep 'http://www.w3.org/2000/01/rdf-schema#range' | sort -u | grep -v '_:' | sed -e 's/^/{ ?x /' | sed -e 's; <http://www.w3.org/2000/01/rdf-schema#range> ; ?y } => { ?y a ;' | sed -e 's/\.$/} ./ ' >> ${1/.ttl/.n3}
cat /tmp/ontology.nt | grep 'http://www.w3.org/2000/01/rdf-schema#subClassOf>' | sort -u | grep -v '_:' | sed -e 's/^/{ ?x  a /' | sed -e 's; <http://www.w3.org/2000/01/rdf-schema#subClassOf> ; } => { ?x a ;' | sed -e 's/\.$/} ./ ' >> ${1/.ttl/.n3}
cat /tmp/ontology.nt | grep 'http://www.w3.org/2000/01/rdf-schema#subPropertyOf>' | sort -u | grep -v '_:' | sed -e 's/^/{ ?x /' | sed -e 's; <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> ; ?y } => { ?x ;' | sed -e 's/\.$/ ?y } ./ ' >> ${1/.ttl/.n3}

else
	echo "Usage example:"
    echo "./ontology_to_n3.sh example.ttl"
fi


