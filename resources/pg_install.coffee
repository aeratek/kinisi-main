# Assumes:
# - postgres 8+ is installed
# - user roles created
# - extensions can be created
#
# Checks:
# - proper environment variable set

pg     = require 'pg'
config = require 'config'

if process.env.NODE_ENV != 'superuser' and process.env.NODE_ENV != 'test'
    throw new Error 'NODE_ENV not set properly'

schemaScript = """
    create extension if not exists hstore;
    create extension if not exists "uuid-ossp";
    --
    drop schema if exists kinisi cascade;
    create schema kinisi authorization internal;
    create sequence kinisi.local_salt_seq;
    --
    drop schema if exists dim cascade;
    create schema dim authorization internal;
    --
    drop schema if exists fact cascade;
    create schema fact authorization application;
    """

tableScript = """
    -- kinisi.local - the system schema
    drop table if exists kinisi.local cascade;
    create table if not exists kinisi.local(
        systemkey uuid primary key, 
        name varchar(160) not null, 
        installed timestamp default now());
    
    -- create system UUID
    insert into kinisi.local (systemkey, name, installed) values (
        uuid_generate_v1(), 
        'kinisi_prototype', 
        now());

    -- dim.document
    drop table if exists dim.document cascade;
    create table dim.document (
        uid uuid primary key, 
        name varchar(160) not null, 
        created timestamp not null,
        current bit(2) not null, 
        description varchar(1000),
        meta hstore);
    create index on dim.document (current);

    drop table if exists dim.platform cascade;
    create table dim.platform ( like dim.document including storage including indexes,
        lastupdate timestamp default now());

    drop table if exists dim.user cascade;
    create table dim.user ( like dim.document including storage including indexes);

    drop table if exists dim.group cascade;
    create table dim.group ( like dim.document including storage including indexes);
    """

# cb takes two arguments (err, result)
installSchemaDefinitions = (cb) ->
    withClient 'installing postgres schema elements', cb, (client, done) ->
        client.query schemaScript, (err, result) ->
            done()
            cb err, result
    
installTableDefinitions = (cb) ->
    withClient 'installing postgres table definitions', cb, (client, done) ->
        client.query tableScript, (err, result) ->
            #call `done()` to release the client back to the pool
            done()
            cb err, result

installFunctions = (cb) ->
    spawn  = require('child_process').spawn
    spawn('psql', ['-f resources/platformFunctions.sql'])
        .on 'close', (code) ->
            error = 'exit error ' + code if code != 0
            cb error, code

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
    console.log 'success' if result and not err
    pg.end()

# MAIN 
console.log process.argv
if process.argv[2] == '--schema'
    installSchemaDefinitions logger
else
    installTableDefinitions logger
    #installFunctions logger

