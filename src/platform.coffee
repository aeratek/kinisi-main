###
  Collector of data points
###

class Platform

    constructor: (@record) ->
    
    getUid: ->
        @record.uid

module.exports = Platform
