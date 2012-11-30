_ = require 'underscore'

class Options
  constructor: ->
    @parsedOpts = {}
    @shortOpts  = {}

  # ----- Public
  getParsedOpts: ->
    @parsedOpts

  getShortOpts: ->
    @shortOpts

  opt: (name, description, opts) ->
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

  # ----- Private
  findShortFor: (name) ->
    char = @nextAvailableCharacter(name)
    return char if char

    return @nextAvailableCharacter('abcdefghijklmnopqrstuvwxyz')

  nextAvailableCharacter: (list) ->
    for letter in list
      return letter unless _.has(@shortOpts, letter)
      return letter.toUpperCase() unless _.has(@shortOpts, letter.toUpperCase())

class Troll
  constructor: ->
    @opts = new Options()

  # ----- Public
  parse: ->
    @handle arg for arg in process.argv

  handle: (arg) ->
    console.log arg

  options: (callback) ->
    callback @opts
    @generate_parser

  getOpts: -> @opts

  # ----- Private
  generateParser: ->
    console.log 

#(new Troll).parse()
#
#(new Troll).options (t) -> 
#  t.opt 'foo',    'Some description',               'default': true, 'short': 'F'
#  t.opt 'header', 'Some description of a non-flag', 'default': 'asdf'

exports.Troll = Troll
exports.Options = Options
