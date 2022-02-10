# Apache Jena Fuseki

A Docker image uses ShenandoahGC that reduces GC pause times by performing more garbage collection work concurrently with the running Java program.

## Deployment on ACDH-CH servers

Deployment on ACDH-CH k8s cluster is performed over Github actions.

### Environment variables

| Environment Variable | Required | Default | Description                                                            |
|----------------------|----------|---------|------------------------------------------------------------------------|
| ADMIN_PASSWORD       |    +     |         | Admin password for Jena Fuseki. It can be set over the Rancher GUI     |
| JVM_ARGS             |    +     |         | Specifies the RAM required for Jena Fuseki.                            |

### Data persistency

Following directories should be persistent:
 - /fuseki/configuration 
 - /fuseki/databases
 -  /vocabs-import

### How to upload large dataset via command line

1. check the config file (e.g. fuseki-data/configuration/largedataset.ttl) for a graph, it should contain:

  ```@prefix :      <http://base/#> .
@prefix tdb:   <http://jena.hpl.hp.com/2008/tdb#> .
@prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix ja:    <http://jena.hpl.hp.com/2005/11/Assembler#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix fuseki: <http://jena.apache.org/fuseki#> .

:service_tdb_all  a                   fuseki:Service ;
        rdfs:label                    "TDB largedataset" ;
        fuseki:dataset                :tdb_dataset_readwrite ;
        fuseki:name                   "largedataset" ;
        fuseki:serviceQuery           "query" , "sparql" ;
        fuseki:serviceReadGraphStore  "get" ;
        fuseki:serviceReadWriteGraphStore
                "data" ;
        fuseki:serviceUpdate          "update" ;
        fuseki:serviceUpload          "upload" .

:tdb_dataset_readwrite
        a             tdb:DatasetTDB ;
        tdb:location  "/fuseki/databases/largedataset" .
  ```
2. Put the file that should be imported in /vocabs-import
3. Go to Rancher GUI ---> Vocabs ---> Edit the pod apache-jena-fuseki ---> Show advanced options ---> Command ---> Entrypoint ---> Add /bin/bash ---> Save
4. Enter container and execute: ./load.sh destination yourdatadump.rdf 	
5. Go back to Rancher GUI and remove  "/bin/bash" command added in the third step .
