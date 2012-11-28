_ = require 'underscore'

class Troll
  constructor: ->
    @parsedOpts = {}

  # ----- Public
  getParsedOpts: ->
    return @parsedOpts

  parse: ->
    @handle arg for arg in process.argv

  handle: (arg) ->
    console.log arg

  opt: (name, description, opts) ->
    _.extend opts, 'desc': description
    @parsedOpts[name] = opts
    if _.has(opts, 'short')
      @parsedOpts[opts['short']] = opts
    else
      @parsedOpts[@findShortFor(name)] = opts

  options: (callback) ->
    callback this
    @generate_parser
    console.log @parsedOpts

  # ----- Private
  generateParser: ->
    console.log 

  findShortFor: (name) ->
    char = @nextAvailableCharacter(name)
    return char if char

    return @nextAvailableCharacter('abcdefghijklmnopqrstuvwxyz')

  nextAvailableCharacter: (list) ->
    for letter in list
      return letter unless _.has(@parsedOpts, letter)
      return letter.toUpperCase() unless _.has(@parsedOpts, letter.toUpperCase())

#(new Troll).parse()
#
#(new Troll).options (t) -> 
#  t.opt 'foo',    'Some description',               'default': true, 'short': 'F'
#  t.opt 'header', 'Some description of a non-flag', 'default': 'asdf'

exports.Troll = Troll
