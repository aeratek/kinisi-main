pg = require 'pg'
config = require 'config'

pg.connect config.Postgres.connection, (err, client, done) ->
    if err
        return console.error 'error fetching client from pool', err
    
    installScript = """
        create schema dim authorization internal
            create table if not exists platform (
                uid uuid primary key,
                name varchar(140),
                latitude numeric,
                longitude numeric,
                meta hstore);
    """

    #test general operations
    client.query 'SELECT $1::int as number, uuid_generate_v1() as theuid', ['1'], (err, result) ->

        if err
            return console.error 'error running query', err
        else
            console.log "this should be 1==#{ result.rows[0].number } and this should be a uuid=#{ result.rows[0].theuid}"
            client.query installScript, (err, result) ->
                if err then console.log err
                #call `done()` to release the client back to the pool
                done()
                pg.end()

