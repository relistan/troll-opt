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

    # Figure out whether the default type needs a value passed
    opts = @processDefaultFor(opts)
    # Figure out if this is a flag or an option with an arg
    @parsedOpts[name] = @processFlagOrOptFor(opts)

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
  processDefaultFor: (opts) ->
    if _.has(opts, 'default')
      throw new Error('type defined when default was provided') if opts['type']
      if _.contains([true, false], opts.default)
        opts['type'] = 'Boolean'
      else
        opts['type'] = opts['default'].constructor.name

    opts

  processFlagOrOptFor: (opts) ->
    if _.has(opts, 'type') and opts.type != 'Boolean'
      opts['takesValue'] = true
    else
      opts['takesValue'] = false

    opts


  findShortFor: (name) ->
    char = @nextAvailableCharacter(name)
    return char if char

    @nextAvailableCharacter('abcdefghijklmnopqrstuvwxyz')

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
