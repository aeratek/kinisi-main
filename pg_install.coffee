#Assumes:
# - postgres 8+ is installed
# - user roles created
#Checks:
# - proper environment variable set

pg = require 'pg'
config = require 'config'

if process.env.NODE_ENV != 'superuser' and process.env.NODE_ENV != 'test'
    throw new Error 'NODE_ENV not set properly'

schemaScript = """
    create extension if not exists hstore;
    create extension if not exists "uuid-ossp";
    
    create schema kinisi authorization internal;
    create schema dim authorization internal;
    create schema fact authorization application;
"""

installScript = """
    -- kinisi.local - the system schema
    drop table if exists kinisi.local cascade;
    create table if not exists kinisi.local(systemkey uuid primary key, name varchar(160), 
        installed timestamp default now());
    
    -- create system UUID
    insert into kinisi.local (systemkey, name, installed) values (uuid_generate_v1(), 
        'kinisi_prototype', now());

    -- dim.platform
    drop table if exists dim.platform;
    create table if not exists dim.platform (uid uuid primary key, name varchar(160), 
        created timestamp, current bit(2), description varchar(1000), meta hstore);            
    """

# cb takes two arguments (err, result)
installSchemaDefinitions = (cb) ->
    withClient 'installing postgres schema elements', cb, (client, done) ->
        client.query schemaScript, (err, result) ->
            done()
            cb err, result
    
installTableDefinitions = (cb) ->
    withClient 'installing postgres table definitions', cb, (client, done) ->
        client.query installScript, (err, result) ->
            #call `done()` to release the client back to the pool
            done()
            cb err, result

# errorHandler and next should be functions
withClient = (message, errorHandler, next) ->
    console.log message
    pg.connect config.Postgres.connection, (err, client, done) ->
        if err
            done()
            errorHandler err
        else
            next client, done
    
logger = (err, result) ->
    console.error err if err
    console.log 'success' if result
    pg.end()

# MAIN 
console.log process.argv
if process.argv[2] == '--schema'
    installSchemaDefinitions logger
else
    installTableDefinitions logger


