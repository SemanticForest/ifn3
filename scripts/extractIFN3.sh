#!/bin/bash

# This script makes use of csvtk, downloadable at: https://bioinf.shenwei.me/csvtk/
# This script makes use of mdbtools, downloadable at: http://mdbtools.sourceforge.net/
# This script makes use of unzip, downloadable at: http://infozip.sourceforge.net/
# This script makes use of gawk 5.3+, downloadable at: https://ftp.gnu.org/gnu/gawk/

# Change variables to perform operation
declare DOWNLOAD_FILES=true
declare UNCOMPRESS_FILES=true
declare EXTRACT_TABLES=true
declare MERGE_TABLES=true
declare COMBINE_TABLES=true

if [ ${DOWNLOAD_FILES} = true ]
then
    echo "[$(date +%F-%T)] Downloading files from miteco.gob.es"
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/ifn3_base_datos_1_25.html | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  > links.txt 
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/ifn3_base_datos_26_50.html | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt 
    wget --no-check-certificate -i links.txt -P ./data/ 
fi

if [ ${UNCOMPRESS_FILES} = true ]
then
    echo "[$(date +%F-%T)] Uncompressing files and removing compressed files"
    unzip -o -d ./data ./data/"*.zip" && echo -n "1 - " 
    rm ./data/*.zip && echo "OK" 
fi

if [ ${EXTRACT_TABLES} = true ]
then
    echo "[$(date +%F-%T)] Starting table extraction "
    rm -f allTables.txt 
    rm -fr tables/temp 
    mkdir -p tables/temp 
    # Extracting all tables from all files. Each table from each file goes to a different file
    # for dbFile in ./data/*.mdb
    for dbFile in ./data/*.accdb
    do
        province=${dbFile%.*} 
        province=${province: -2:2} 
        echo "[$(date +%F-%T)] Exporting file ${dbFile}"
        mdb-tables -1 ${dbFile} > tables.txt 
        cat tables.txt | tr "[:upper:]" "[:lower:]" >> allTables.txt 
        
        while IFS="" read -r table || [ -n "$table" ]
        do
            table=`echo $table | tr "[:upper:]" "[:lower:]"` 
            tableFile="./tables/temp/${table// /}-${province}.csv" 
            echo -n "[$(date +%F-%T)] Exporting table ${table} from file ${dbFile} to ${tableFile} - "
            #the 1st sed is necessary because there is (at least) one table with wrong name table
            mdb-export -e -T "%Y-%m-%d %H:%M:%S" ${dbFile} "${table}" | sed "1,1s|Distancia|Distanci|" | sed "1,1s|^|Origen,|" | sed  "2,\$s|^|${province},|" | awk -kf remove_leading_zeros.awk > "${tableFile}" && echo "OK" 
        done < tables.txt
    done
    sort -u -o allTables.txt allTables.txt 
fi

if [ ${MERGE_TABLES} = true ]
then
    rm tables/*.csv
    while IFS="" read -r table || [ -n "$table" ]
    do
        filesForTable=(`ls ./tables/temp/${table// /}-*.csv | grep -i ${table// /}`)
        if [ ${#filesForTable[@]} -gt 1 ]
        then
            echo -n "[$(date +%F-%T)] Merging ${#filesForTable[@]} files for table ${table} - "
            csvtk concat -k ${filesForTable[@]} > "./tables/${table// /}.csv" && echo "OK" 
        else
            echo -n "[$(date +%F-%T)] Copying 1 file for table ${table} - "
            cat ${filesForTable[@]} > "./tables/${table// /}.csv" && echo "OK" 
        fi
    done < allTables.txt
fi

if [ ${COMBINE_TABLES} = true ]
then
    # Join tables to get aggregated data by province
    echo -n "[$(date +%F-%T)] Joinin estratos_exs.csv and estratos.csv into tables/provincias_exs.csv  - "
    csvtk join -f "Origen,Estrato" "tables/estratos_exs.csv" "tables/estratos.csv" -o "tables/provincias_exs.csv" && echo "OK" 

    echo -n "[$(date +%F-%T)] Extracting sources from pcparcelas.csv to sources.csv - "
    csvtk cut -f "Origen,Estadillo,Cla,Subclase,Equipo,JefeEq,Tecnico" "./tables/pcparcelas.csv" > "./tables/sources.csv" && echo "OK" 
    # echo " [$?]"


    echo -n "[$(date +%F-%T)] Merging pcmayores.csv and sources.csv into pcmayores-sources.csv - "
    csvtk join -f "Origen,Estadillo,Cla,Subclase" "./tables/pcmayores.csv" "./tables/sources.csv" > "./tables/pcmayores-sources.csv" && echo "OK" 
    
fi

echo "[$(date +%F-%T)] PROGRAM FINISHED"