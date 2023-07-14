#!/bin/bash

# This script is used to run a mongodump for a specific collection of a specific database.  Dumping the last x number of records inserted.
# author: bgoff@snaplogic
# since: 14 July 2023

dump()
{
	echo "password?"
	read PASSWORD
	local lastIdQuery="db.getSiblingDB(\"$DATABASE\").$COLLECTION.aggregate([{\$sort:{_id:-1}},{\$limit:$MAX_DOCUMENT},{\$sort:{_id:1}},{\$limit:1},{\$project:{_id:{\$toString:\"\$_id\"}}}])"
	echo "lastIdQuery $lastIdQuery"
	local lastIdResult=$(mongo -u admin -p $PASSWORD --host=$MONGODB_URI --quiet --eval "$lastIdQuery")
	echo "lastIdResult $lastIdResult"
	local lastId=$(echo $lastIdResult | sed -e 's/{ "_id" : "\(.*\)" }/\1/')
	echo $lastId
	query="{\"_id\":{\"\$gte\":\"$lastId\"}}"
	echo "query $query"
	mongodump -v --tlsInsecure --authenticationDatabase=admin -u admin -p $PASSWORD --readPreference=secondary --uri=$MONGODB_URI --db=$DATABASE --collection=$COLLECTION --query="$query" --out=$OUTPUT_FOLDER
}

#MONGODB_URI='mongodb://localhost:27017/sldb'

MONGODB_URI='mongodb://na03sl-mgdb-ux1002.fsac3.snaplogic.net:27017,na03sl-mgdb-ux1008.fsac3.snaplogic.net:27017,na03sl-mgdb-ux1003.fsac3.snaplogic.net:27017/?replicaSet=snapreplica'
OUTPUT_FOLDER=./mongoDumps
MAX_DOCUMENT=500000
DATABASE="cslserver"
COLLECTION="pm.pipeline_rt"

dump
