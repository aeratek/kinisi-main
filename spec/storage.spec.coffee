#
# spec file
#
config   = require 'config'
pg       = require 'pg'
Storage  = require '../dist/src/storage'
Platform = require '../dist/src/platform'

# gloabal test holder
test = {}

# test setup
jasmine.getEnv().defaultTimeoutInterval = 3000

beforeEach ->
    test.storage = new Storage()

describe 'storage class', ->
    it 'should be able to reset the db', (done) ->
        client = new pg.Client(config.Postgres.connection)
        client.connect (err) ->
            expect(err).toBeNull()
            if (err) then client.end()
            else client.query 'truncate dim.platform cascade', (err, result) ->
                expect(err).toBeNull()
                client.end()
                done()

    it 'should be able to get the system uuid', (done) ->
        test.storage.getSystemUuid (err, uuid) ->
            expect(err).toBeNull()
            expect(uuid).toBeDefined()
            done()
  
    it 'should not find any platforms that match based on name', (done) ->
        test.storage.getUidsForName 'platform1', (err, uids) ->
            expect(err).toBeNull()
            expect(uids).toBeDefined()
            expect(uids?.length).toEqual 0
            done()
    
    it 'should be able to create a platform uid', (done) ->
        test.storage.createPlatformUid 'platform1', (err, uid) ->
            expect(err).toBeNull()
            expect(uid).not.toBeNull()
            done()

    it 'should be able to create a new platform', (done) ->
        test.storage.createPlatform 'platform1', (err, platform) ->
            expect(err).toBeNull()
            expect(platform).toBeDefined()
            expect(platform?.getUid()).not.toBeNull()
            done()
    
    it 'should NOW find a platform that matches based on name', (done) ->
        test.storage.getUidsForName 'platform1', (err, uids) ->
            expect(err).toBeNull()
            expect(uids).toBeDefined()
            expect(uids?.length).toEqual 1
            expect(uids?[0]).toBeDefined()
            done()
  
    # this spec always has to be last
    it 'should be able to release all resources permanently', ->
        expect(test.storage.exit).not.toThrow()

