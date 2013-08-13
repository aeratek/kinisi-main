#
# The main webserving application
# call with something like:
#    coffee app.coffee
#

"use strict"

config  = require('config')
express = require('express')
Routes  = require('./src/routes')

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
    
    routes = new Routes()
    app.get '/', routes.welcome
    app.get '/form', routes.uploadForm
    app.post '/upload', routes.postForm
    ###
    app.get '/eggs', routes.listByPage
    app.get '/eggs/p/:page', routes.list
    app.post '/eggs', routes.addNew
    app.get '/eggs/id/:eggid', routes.getById
    app.del '/eggs/id/:eggid', routes.removeById
    app.get '/eggs/id/:eggid/data/:page', routes.getDataByIdAndPage
    app.post '/eggs/id/:eggid/data', routes.addDataById
    ###
    console.log 'registration complete'

app.configure 'development', ->
    app.use express.logger('dev')
        
app.listen config.WebService.port

console.log 'listening via HTTP on', config.WebService.port

