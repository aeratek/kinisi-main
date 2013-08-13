#
# Clients describe changes throught this mapping
# The storage set of classes actually executes the change
#

"use strict"

class ChangeRequest
    @changes = {}
        
    constructor: (@uuid)  ->

    changeAttr: (attribute, value) ->
        throw new Error 'empty value' if !value
        stdChecks attribute
        changes[attribute] = value

    deleteAttr: (attribute) ->
        stdCheck attribute
        delete changes[attribute] if changes[attribute]
        changes['__deletes'][attribute] = '__del__'
    
    createSequence: (attribute, schema) ->
        throw new Error 'empty schema' if !schema
        stdChecks attribute
        changes['__seq_schema'][attribute] = schema

    addToSequence: (attribute, value) ->
        stdChecks attribute
        changes['__seq'] = changes['__seq'] || {}
        changes['__seq'][attribute] = changes['__seq'][attribute] || []
        changes['__seq'][attribute].push(value)

    deleteSequence: (attribute) ->
        stdChecks attribute
        changes['__deletes'][attribute] = '__deleted__'

    stdChecks = (attribute) ->
        throw new Error 'empty change or deletion attribute' if !attribute
        throw new Error 'illegal attribute name' if attribute = '__deletes' or attribute = '__seq' or attribute = 'uid' or attribute = 'created'


