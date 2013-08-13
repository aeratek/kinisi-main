
"use strict"

config   = require('config')
express  = require('express')
format   = require('util').format
Handlers = require('./src/handlers')

app = express()

app.configure () ->
    app.set 'title', 'Cypress Hills Air Quality Project'

    #app.use express.basicAuth 'chaq_admin', 'eggsarefun'
    app.use express.errorHandler()
    app.use express.favicon()
    app.use express.bodyParser uploadDir:'./uploads'
    #app.use '/static', express.static(__dirname + '/public')
    app.set 'views', __dirname + '/views'
    app.engine 'html', require('ejs').renderFile

    # register routes here 
    console.log 'registering routes'
    
    processor = new Handlers()
    app.get '/', processor.welcome
    app.get '/form', processor.uploadForm
    app.post '/upload', processor.postForm
    ###
    app.get '/eggs', processor.listByPage
    app.get '/eggs/p/:page', processor.list
    app.post '/eggs', processor.addNew
    app.get '/eggs/id/:eggid', processor.getById
    app.del '/eggs/id/:eggid', processor.removeById
    app.get '/eggs/id/:eggid/data/:page', processor.getDataByIdAndPage
    app.post '/eggs/id/:eggid/data', processor.addDataById
    ###
    console.log 'registration complete'

app.configure 'development', ->
    app.use express.logger('dev')
        
app.listen config.WebService.port

console.log 'listening via HTTP on', config.WebService.port

