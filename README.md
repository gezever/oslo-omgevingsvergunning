# oslo-omgevingsvergunning
```sparql
PREFIX besluit: <http://example.org/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX geosparql: <http://www.opengis.net/ont/geosparql#>
<http://www.opengis.net/def/crs/EPSG/0/31370>
SELECT ?besluit ?wkt
WHERE {
  ?besluit a besluit:Besluit .
  ?besluit prov:atLocation/prov:geometry/geosparql:asWKT ?wkt .
  BIND("<http://www.opengis.net/def/crs/EPSG/0/31370> POLYGON((x1 y1, x2 y2, x3 y3, x4 y4, x1 y1))"^^geosparql:wktLiteral AS ?polygon) .
  # Check if the point is within the polygon
  FILTER(geosparql:sfWithin(?wkt, ?polygon)) .
}
```