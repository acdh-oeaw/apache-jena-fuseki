# Apache Jena Fuseki

A Docker image uses ShenandoahGC that reduces GC pause times by performing more garbage collection work concurrently with the running Java program.

## Deployment on ACDH-CH servers

Deployment on ACDH-CH k8s cluster is performed over Github actions.

### Environment variables

| Environment Variable | Required | Default | Description                                                            |
|----------------------|----------|---------|------------------------------------------------------------------------|
| ADMIN_PASSWORD       |    +     |         | Admin password for Jena Fuseki. It can be set over the Rancher GIU     |
| JVM_ARGS             |    +     |         | Specifies the RAM required for Jena Fuseki.                            |

### Data persistency

Following directories should be persistent:
 - /fuseki/configuration 
 - /fuseki/databases
 -  /vocabs-import


