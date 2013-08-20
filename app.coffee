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
port = process.argv[2] || config.WebService.port

app.configure () ->
    app.engine 'html', require('ejs').renderFile

    app.set 'title', 'Cypress Hills Air Quality Project'
    app.set 'views', __dirname + '/views'

    console.log 'upload directory', config.WebService.uploadsDir

    app.use express.errorHandler()
    app.use express.favicon()
    app.use express.bodyParser uploadDir: config.WebService.uploadsDir
    
    # register routes here 
    console.log 'registering routes'
    routes = new Routes(app)
    console.log 'registration complete'

app.configure 'development', ->
    app.use express.logger('dev')
        

app.listen port

console.log 'listening via HTTP on', port

