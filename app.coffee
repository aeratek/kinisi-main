
"use strict"

config   = require('config')
express  = require('express')
handlers = require('./lib/handlers')
format   = require('util').format

app = express()

app.configure () ->
    app.set 'title', 'Cypress Hills Air Quality Project'

    #app.use express.basicAuth 'chaq_admin', 'eggsarefun'
    app.use express.errorHandler()
    app.use express.favicon()
    app.use express.bodyParser uploadDir:'./uploads'
    
    # register routes here 
    console.log 'registering routes'
    
    processor = new handlers
    app.get '/', processor.uploadForm
    app.post '/', processor.postForm
    app.get '/eggs', processor.listAll
    app.post '/eggs', processor.addNew
    app.get '/eggs/:eggid', processor.getById
    app.del '/eggs/:eggid', processor.removeById
    app.get '/eggs/:eggid/data/:page', processor.getDataByIdAndPage
    app.post '/eggs/:eggid/data', processor.addDataById

    console.log 'registration complete'

app.configure 'development', ->
    app.use express.logger('dev')
        
app.listen config.WebService.port

console.log 'listening via HTTP on', config.WebService.port

