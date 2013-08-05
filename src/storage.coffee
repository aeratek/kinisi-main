#
# abstract away the data management
#
config = require 'config'
pg     = require 'pg'
getmac = require 'getmac'
Platform = require './platform'


class Storage

    constructor: ->
        #assume this is strong enough guarantee for uniqueness
        @salt = Math.floor(Math.random() * 10000)
        @systemuuid = null
              

    getUidsForName: (name, cb) ->
        @query 'select uid from dim.platform where name = $1::varchar', [name], (err, result) ->
            if !err
                uids = result.rows?.map( (x) -> x.uid )
                cb null, uids
            else
                cb 'error querying for identifiers'

    getSystemUuid: (cb) ->
        return cb null, @systemuuid if @systemuuid
        
        getmac.getMac (err, macAddress) =>
            return cb err if err

            @query 'select systemkey from kinisi.local;', (err, result) =>
                console.log 'getSystemUuid: ', result.rows
                if !err
                    @systemuuid = result.rows?[0].systemkey
                    cb null, @systemuuid
                else
                    cb 'error querying system table: ' + err
    
    createPlatformUid: (name, cb) ->
        @getSystemUuid (err, uuid) =>
            return cb err if err or uuid is null
            
            @salt = @salt + 1
            stmt = 'select uuid_generate_v5($1::uuid, $2::varchar || $3::varchar || $4::varchar);'
            params = [uuid, (new Date()).getTime(), @salt, name]
            console.log params
            @query stmt, params, (err, result) ->
                if !err
                    console.log 'returned result', JSON.stringify(result)
                    cb null, result.rows
                else
                    cb 'error creating platform'

    createPlatform: (name, cb) ->
        # generate a securish v5 uuid, but still using mac, time properties 
        @getSystemUuid (err, uuid) =>
            return cb err if err or uuid is null

            @salt = @salt + 1
            stmt = """insert into dim.platform (uid, name, created, current) 
                        values (uuid_generate_v5($1::uuid, $2::varchar || $3::varchar || $4::varchar), $4::varchar, now(), 1::bit(2));"""
            params = [uuid, (new Date()).getTime(), @salt, name]
            @query stmt, params, (err, result) ->
                if !err
                    console.log 'returned result', JSON.stringify(result)
                    platform = result.rows[0]
                    cb null, new Platform(platform)
                else
                    cb 'error creating platform'
    
    # calling this prevents anymore connections for the life of the process
    exit: ->
        pg.end()

    # handle pg-client pooling
    query: (statement, options, cb) ->
        if typeof options is 'function'
            cb = options
            options = undefined
        
        if !cb then throw new Error 'callback required'
        
        console.log 'query:', statement

        pg.connect config.Postgres.connection, (err, client, done) =>
            if !err
                client.query statement, options, (err, result) ->
                    done()
                    try
                        if err then console.error err
                        cb err, result
                    catch e
                        console.error e
            else
                console.error 'error with query', err
                cb err


module.exports = Storage

