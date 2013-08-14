#
# abstract away the data management
#

"use strict"

config = require 'config'
getmac = require 'getmac'
pg     = require 'pg'
ChangeRequest = require './cr'


class Storage

    constructor: ->
        @systemuuid = null
              
    # get array of uids for a given name.
    # names are not guaranteed unique, so several uids may match
    getUidsForName: (name, cb) ->
        throw new Error 'invalid arguments' if !cb or !name
        query 'select uid from dim.platform where name = $1::varchar', [name], (err, result) ->
            if !err
                uids = result.rows?.map( (x) -> x.uid )
                cb null, uids
            else
                cb 'error querying for identifiers by name=' + name
    
    # get system identifier - caches this value
    getSystemUuid: (cb) ->
        throw new Error 'invalid arguments' if !cb
        return cb null, @systemuuid if @systemuuid
        #note: wide arrow for function callback
        query 'select systemkey from kinisi.local;', (err, result) =>
            if !err
                @systemuuid = result.rows?[0].systemkey
                cb null, @systemuuid
            else
                cb 'error querying for system key - db is likely corrupt'
    
    # atomic call to create a new platform, returns its initial state
    createPlatform: (name, cb) ->
        throw new Error 'invalid arguments' if !cb or !name
        # pass in the mac address for the stored procedure
        getmac.getMac (err, macAddress) =>
            return cb err if err or !macAddress
            params = [name, macAddress + process.pid]
            query 'select * from create_platform($1::varchar, $2::varchar)', params, (err, result) ->
                if !err
                    platform = result.rows?[0]
                    cb null, platform
                else
                    cb 'error creating platform with name ' + name
    
    # should not consider this an atomic call
    # count will be max 100
    getPlatforms: (page, count, cb) ->
        throw new Error 'invalid arguments' if !cb or count <= 0 or page < 0
        count = 100 if count > 100
        query 'select * from dim.platform limit $1::int offset $2::int', [count, page * count], (err, result) ->
            if !err
                cb null, result.rows || []
            else
                cb 'error getting platforms for page=' + page + ', count=' + count
    
    # returns an array of length with one platform, assuming it exists,
    # otherwise returns the empty array
    getPlatform: (uid, cb) ->
        throw new Error 'invalid arguments' if !cb or !uid
        query 'select * from dim.platform where uid = $1::uuid limit 1', [uid], (err, result) ->
            if !err
                cb null, result.rows || []
            else
                cb 'error querying for platform by uid=' + uid
    
    # create a change request for modifications
    createChange: (uuid) ->
        return new ChangeRequest(uuid)
    
    # submit the change to the data layer
    update: (change, cb) ->
        throw new Error 'invalid arguments' if !cb or !change
        cb 'unsupported error!'

    # calling this prevents anymore connections for the life of the process
    exit: ->
        pg.end()
    
    
    # private method: handle pg-client pooling
    query = (statement, parameters, cb) ->
        if typeof parameters is 'function'
            cb = parameters
            parameters = undefined
        
        throw new Error 'callback required' if !cb
        console.log 'query:', statement, ', ', parameters?.length, ' parameter(s)'
        pg.connect config.Postgres.connection, (err, client, done) =>
            if !err
                client.query statement, parameters, (err, result) ->
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

