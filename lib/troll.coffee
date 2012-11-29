_ = require 'underscore'

class Option

  constructor: (@name, @description, @opts) ->
    _.extend opts, 'desc': description

  setShort: (short) ->
    @short = short

class Troll
  constructor: ->
    @parsedOpts = {}
    @shortOpts  = {}

  # ----- Public
  getParsedOpts: ->
    @parsedOpts

  getShortOpts: ->
    @shortOpts

  parse: ->
    @handle arg for arg in process.argv

  handle: (arg) ->
    console.log arg

  opt: (name, description, opts) ->
    #option = new Option(name, description, opts)
    @parsedOpts[name] = new Option(name, description, opts)
    _.extend opts, 'desc': description
    @parsedOpts[name] = opts

    if _.has(opts, 'short')
      previousKey = @shortOpts[opts['short']]

      if previousKey
        @parsedOpts[previousKey]['short'] = @findShortFor(previousKey)

      @shortOpts[opts['short']] = name
    else
      short = @findShortFor(name)
      @shortOpts[short] = name
      @parsedOpts[name]['short'] = short


  options: (callback) ->
    callback this
    @generate_parser

  # ----- Private
  generateParser: ->
    console.log 

  findShortFor: (name) ->
    char = @nextAvailableCharacter(name)
    return char if char

    return @nextAvailableCharacter('abcdefghijklmnopqrstuvwxyz')

  nextAvailableCharacter: (list) ->
    for letter in list
      return letter unless _.has(@shortOpts, letter)
      return letter.toUpperCase() unless _.has(@shortOpts, letter.toUpperCase())

#(new Troll).parse()
#
#(new Troll).options (t) -> 
#  t.opt 'foo',    'Some description',               'default': true, 'short': 'F'
#  t.opt 'header', 'Some description of a non-flag', 'default': 'asdf'

exports.Troll = Troll
