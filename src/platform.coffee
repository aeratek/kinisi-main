###
  Collector of data points
###

class Platform

    constructor: @map
    
    getUid: ->
        @map.uid

module.exports = Platform
