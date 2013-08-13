

config = require 'config'
#jobservice = require './jobservice'

class Handlers

    # '/', processor.welcomeJson
    welcome: (request, response) ->
        response.json msg: 'Welcome to the Cypress Hills Air Quality Project'
    
    # '/form', processor.uploadForm
    uploadForm: (request, response) ->
        response.set 'Content-Type', 'text/html'
        response.render 'form.html'

    # '/upload', processor.postForm
    postForm:  (request, response) ->
        console.log request.files
        if request.files.eggdata
            console.log 'found parsed egg data'
            meta = request.files.eggdata
            response.json
                status: 'upload successful'
                name: meta.name
                size: meta.size
                type: meta.type
        else
            response.status(500).send
                error: 'uploaded data not parsed correctly, please contact your administrator'

    # '/eggs', processor.listByPage
    # '/eggs/p/:page', processor.list
    # '/eggs', processor.addNew
    # '/eggs/id/:eggid', processor.getById
    # '/eggs/id/:eggid', processor.removeById
    # '/eggs/id/:eggid/data/:page', processor.getDataByIdAndPage
    # '/eggs/id/:eggid/data', processor.addDataById
module.exports = Handlers
