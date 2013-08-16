#
# Handles routes
#

"use strict"

config = require 'config'
Storage = require './storage'

class Routes

    constructor: ->
        @storage = new Storage()

    # '/', processor.welcomeJson
    welcome: (request, response) ->
        response.json msg: 'Welcome to the Cypress Hills Air Quality Project'
    
    # '/form', processor.uploadForm
    uploadForm: (request, response) ->
        response.set 'Content-Type', 'text/html'
        response.render 'form.ejs'

    # '/upload', processor.postForm
    postForm:  (request, response) ->
        console.log 'data_present=', request.files.eggdata?
        if request.files.eggdata
            meta = request.files.eggdata
            response.json
                status: 'upload successful'
                name: meta.name
                size: meta.size
                type: meta.type
        else
            response.status(500).send
                error: 'uploaded data not parsed correctly, please contact your administrator'

    # '/eggs/p/:page', processor.listByPage
    listByPage: (request, response) =>
        page = +request.params.page || 0
        @storage.getPlatforms page, 20, (err, platforms) ->
            if !err
                response.send 'platforms': platforms, 'page': page
            else
                response.status(500).send error: 'internal server error: ' + err

    #'/eggs/id/:pid', processor.getById
    getById: (request, response) =>
        return response.status(404).send 'resource not found' if !request.params.pid
        @storage.getPlatformById +request.params.pid, (err, platform) ->
            if !err
                response.send 'platforms': platform
            else
                response.status(500).send error: 'internal server error: ' + err

    #'/eggs/uid/:uid', processor.getByUid
    getByUid: (request, response) =>
        return response.status(404).send 'resource not found' if !request.params.uid
        @storage.getPlatformByUid request.params.uid, (err, platform) ->
            if !err
                response.send 'platforms': platform
            else
                response.status(500).send error: 'internal server error: ' + err
    
    # '/eggs/uid/:uid/data/:page', processor.getDataByIdAndPage
    getDataByUidAndPage: (request, response) =>
        return response.status(404).send 'resource not found' if !request.params.uid
        page = + request.params.page || 0
        uid = request.params.uid
        @storage.getDataByUidAndPage uid, page, (err, data) ->
            if !err
                response.send 'uid': uid, 'data': data
            else
                response.status(500).send error: 'internal server error: ' + err

    # '/eggs/id/:pid/data', processor.addDataById
module.exports = Routes

