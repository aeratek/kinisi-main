#
# spec file
#
Storage = require('../dist/src/storage')
Platform = require('../dist/src/platform')

test = {}

# test setup
jasmine.getEnv().defaultTimeoutInterval = 4000

beforeEach ->
    test.storage = new Storage

describe 'storage class', ->

    it 'should be able to query for uids for a given, non-unique name', (done) ->
        test.storage.getUidsForName 'platform1', (err, uids) ->
            expect(err).toBeNull()
            expect(uids).toBeDefined()
            expect(uids?.length).toEqual 0
            done()
        
    it 'should be able to add a new platform', (done) ->
        test.storage.createPlatform 'platform1', (err, platform) ->
            expect(err).toBeNull()
            expect(platform).toBeDefined()
            expect(platform?.getUid()).not.toBeNull()
            done()

    it 'should be able to release all resources permanently', ->
        expect(test.storage.exit).not.toThrow()

