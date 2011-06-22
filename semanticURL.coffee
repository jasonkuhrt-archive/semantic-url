_ = require './node_modules/underscore'
utils = require './utils'

classParsers =
    parsed: ''

    parse: (trait)->
        @parsed = ''
        @applyParser parser, trait for parser in @preParsers
        @parsed = @parsers[trait.name](trait)
        @applyParser parser, trait for parser in @postParsers
        @parsed

    
    #pre/post helpers

    applyParser: (parser,trait)->
        if @parserIsApplicable parser, trait
            @parsed = parser.parse.call @, trait
    
    parserIsApplicable: (parser,trait)->
        parser.name is '*' or parser.name is trait.name
    
    
    #inventory control

    addParsers: (parsers)->
        @addParser parser for parser in parsers
            
    #config.stage
    #config.name
    #config.parseFunction

    addParser: (config)->
        @["#{config.when}Parsers"].push
            name:config.what
            parse:config.parseFunction

    
    #parsers

    preParsers:  []
    postParsers: []
    parsers:
        page: (trait)->
            trait.label + '-page'
            
        resource: (trait)->
            trait.label





classParsers.addParser
    when: 'post'
    what: '*'
    parseFunction: (trait)->
        if not trait.location.is_last
            'within-' + @parsed
        else
            @parsed

class Trait
    constructor: (@name,@label,@location)->
        @label = @label or @location.slug
        @myvalue = classParsers.parse this
    toString: ->
        @myvalue
    
    
class Location
    constructor: (config)->
        @depth = config.depth
        @slug = config.slug
        @is_last = config.is_last or false
        if typeof config.traits is 'string'
                @traits = []
                @addTraits config.traits
        else
            @traits = config.traits or []

        @
    
    toString: ->
        a_string = ''
        for trait in @traits
            a_string += ' ' + trait.toString()
        a_string.trim()

    addTraits: (traits_collection)->
        parsed = traits_collection.split ','
        parsed[i] = t.trim() for t,i in parsed

        @addTrait trait for trait in parsed
        @
        
    
    addTrait: (trait_specification)->
        if trait_specification isnt '--'
            parsed = trait_specification.split ':'
            parsed[i] = t.trim() for t,i in parsed

            @traits.push new Trait parsed[0], parsed[1], @
        @
        
    
    

class SemanticURL
    constructor: (@specification,@raw_url,root_location)->
        @url = utils.chunkURL @raw_url
        @locations = []
        @within = []

        @locations = @parseSpecification(@specification, @url) unless not @specification
        @root_location = root_location or new Location({depth:0,slug:'/',is_last:true}).addTrait('page:home')
        
        if @locations.length > 1
            @within = @locations.slice(0,-1)
        else if _(@locations).isEmpty()
            @locations.push @root_location
        
        @current_location = _(@locations).last()



               
    #helpers

    parseSpecification: (specification,url)=>
        unformed_definitions = utils.chunkURL specification
        for definition,i in unformed_definitions
            new Location
                traits: definition
                depth: i+1
                is_last: i+1 is unformed_definitions.length
                slug: url[i]

    has_definitions: ->
        @definitions.length

    toString: ()->
        as_string = ''
        as_string += ' ' + location.toString() for location in @locations
        as_string.trim()


    
    
        

module.exports = SemanticURL



