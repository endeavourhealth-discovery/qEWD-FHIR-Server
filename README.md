# qEWD-FHIR-Server

Install docker!

sudo docker pull rtweed/qewd-server:yottadb_1.24

sudo docker network create qewd-net

```
docker run -it --name orchestrate --rm --net qewd-net -p 8080:8080 -v /home/ubuntu/roqr:/opt/qewd/mapped rtweed/qewd-server:yottadb_1.24
```

```
docker run -it --name validator_service --rm --net qewd-net -p 8081:8080 -v /home/ubuntu/roqr:/opt/qewd/mapped -e microservice="validator_service" rtweed/qewd-server:yottadb_1.24
```

```
docker run -it --name search_service --rm --net qewd-net -p 8082:8080 -v /home/ubuntu/roqr:/opt/qewd/mapped -e microservice="search_service" rtweed/qewd-server:yottadb_1.24
```

```
docker run -it --name localdb_service --rm --net qewd-net -p 8083:8080 -v /home/ubuntu/g:/root/.yottadb/r1.24_x86_64/g/ -v /home/ubuntu/roqr:/opt/qewd/mapped -v /home/ubuntu/roqr/mumps:/root/.yottadb/r/ -e microservice="localdb_service" rtweed/qewd-server:yottadb_1.24
```

To shut down the microservices press CTRL-C

To get to a Yotta/Mumps prompt:

docker exec -it localdb_service bash

./ydb

To import ^SYNSCHEMA into yotta:
copy /schema/SYNSCHEMA.glb to a docker mapped folder - then run:
D ^IMPORT("/root/.yottadb/r/SYNSCHEMA.glb")

Example queries:

/fhir/STU3/MedicationStatement?patient=Patient/5a3962c5-e170-4057-82b0-7a1555e888bf

/fhir/STU3/Patient?identifier=https://fhir.nhs.uk/Id/nhs-number|9658218873&_revinclude=*

/fhir/STU3/Observation?date=gt2012-01-01&code=434912009&patient=Patient/5a3962c5-e170-4057-82b0-7a1555e888bf

/fhir/STU3/Patient/3c55f80a-437b-4321-ad85-da88eb5958c2/$everything

/fhir/STU3/Observation?code=2469&value-quantity=gt9&date=2018

/fhir/STU3/Patient?identifier=2942355359&_revinclude=Observation:patient

/fhir/STU3/Practitioner?name=smith

/fhir/STU3/Observation?code=44PF&value-quantity=gt9

/fhir/STU3/Patient?family=jones&gender=f

/fhir/STU3/Practitioner?family=MUNT

/fhir/gfind?global=^docindex3&str=gilbert