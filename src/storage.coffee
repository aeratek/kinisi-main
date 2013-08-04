

config = require 'config'
pg     = require 'pg'

class Storage

    query: (statement, options, cb) ->
        if typeof options is 'function'
            cb = options
            options = undefined
        if !cb then throw new Error 'callback required'
        
        pg.connect config.Postgres.connection, (err, client, done) =>
            if !err
                client.query statement, options, (err, result) ->
                    try
                        cb err, result
                    catch e
                        console.error e
                    done()
            else
                console.error 'error with client', err
                cb err

    getUidsForName: (name, cb) ->
        @query 'SELECT 1 AS "uid"', (err, result) ->
            if !err
                uids = result.rows?.map( (x) -> x.uid )
                cb null, uids
            else
                cb 'error quring for identifiers'
                
    createPlatform: (name, cb) ->
        @query 'SELECT 1 AS "uid"', (err, result) ->
            if err
                cb null, result.rows?[0].uid
            else
                cb 'error creating platform'
    
    # calling this prevents anymore connections for the life of the process
    exit: ->
        pg.end()

module.exports = Storage

