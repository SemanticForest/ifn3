#!/bin/bash

# This script makes use of csvtk, downloadable at: https://bioinf.shenwei.me/csvtk/
# This script assumes you have java installed in your system and the epsgrdf jar in /usr/local/lib/

# Download and preprocess IFN3 files
# ./extractIFN3.sh

# Run sparql-generate queries
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/cambioespecie.rqg -i tables/cambioespecie.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/cambioespeciereg.rqg -i tables/cambioespeciereg.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/estratos.rqg -i tables/estratos.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/estratos_exs.rqg -i tables/estratos_exs.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/mayores_exs.rqg -i tables/mayores_exs.csv -v -s 100000
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/parcelas_exs.rqg -i tables/parcelas_exs.csv -v -s 100000
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/parcpoly.rqg -i tables/parcpoly.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/pcdatosmap.rqg -i tables/pcdatosmap.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/pcespparc.rqg -i tables/pcespparc.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/pcmatorral.rqg -i tables/pcmatorral.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/pcmayores.rqg -i tables/pcmayores-sources.csv -v -s 100000
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/pcnueesp.rqg -i tables/pcnueesp.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/pcparcelas.rqg -i tables/pcparcelas.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/pcregenera.rqg -i tables/pcregenera.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/provincias_exs.rqg -i tables/provincias_exs.csv -v
../../sparqlgenerate.sh -q ../../../sparql-generate/ifn3/tarifasifn3.rqg -i tables/tarifasifn3.csv -v

# # Create positions for WGS84
# java -Xmx20000M -jar ../../../epsgrdf/target/epsgrdf-1.0-SNAPSHOT-jar-with-dependencies.jar ../../../Ontologies/epsg/Coordinate_Reference_System.ttl tables/pcdatosmap.ttl tables/pcparcelas.ttl tables/pcmayores-sources.ttl
# # java -Xmx20000M -jar /usr/local/lib/epsgrdf-1.1-SNAPSHOT-jar-with-dependencies.jar tables/pcdatosmap.ttl tables/pcespparc.ttl tables/pcmayores-sources.ttl ../Ontologies/epsg/Coordinate_Reference_System.ttl
