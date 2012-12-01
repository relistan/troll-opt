_ = require 'underscore'

class Options
  constructor: ->
    @parsedOpts = {}
    @shortOpts  = {}
    @helpBanner = ""

  # ----- Public
  getParsedOpts: ->
    @parsedOpts

  getShortOpts: ->
    @shortOpts

  getBanner: ->
    @helpBanner

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

  banner: (text) ->
    @helpBanner = "  #{text}"

  calculateOptionLength: (k) ->
    return k.length if @parsedOpts[k].type is 'Boolean'
    k.length + 4

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

  displayTypeFor: (type) ->
    type[0].toLowerCase()

  sorted: ->
    optsList = _.pairs @parsedOpts
    _.sortBy(optsList, (n) -> n)

  longestOptionLength: ->
    lengths = (@calculateOptionLength(k) for k in _.keys(@parsedOpts))
    _.sortBy(lengths, (x) -> 0 - x)[0]


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

  displayOpts: ->
    # TODO: find out how to get the actual script name that was invoked
    console.log "\nUsage: #{process.argv[0]} [options]"
    console.log @opts.getBanner()

    len = @opts.longestOptionLength()
    @displayOneOpt(opt, len) for opt in @opts.sorted()

  # ----- Private

  displayOneOpt: (opt, len) ->
    name = opt[0]
    opts = opt[1]

    output =  @spacePad("#{name}", len + 1)
    output += ", -#{opts.short}"
    output += " <#{@opts.displayTypeFor(opts.type)}>" if opts.type != 'Boolean'
    output += ": #{opts.desc}"
    output += " (default: #{opts.default})" if _.has(opts, 'default')
    console.log output

  spacePad: (str, len) ->
    strlen = @opts.calculateOptionLength(str)
    pad = (" " for x in [strlen..len]).join("")
    "#{pad}--#{str}"

  generateParser: ->
    console.log


#(new Troll).parse()
#
#(new Troll).options (t) -> 
#  t.opt 'foo',    'Some description',               'default': true, 'short': 'F'
#  t.opt 'header', 'Some description of a non-flag', 'default': 'asdf'

# Usage: foo sub_command [options]
#   Sub commands: list, fetch. Try foo cmd --help for more options.
#   --username, -u <s>:   Foo Username (default: asdf)
#   --password, -p <s>:   Foo Password (default: asdf)
#       --wsdl, -w <s>:   The Foo wsdl URL to connect to (default: http://foo)
#           --help, -h:   Show this message


exports.Troll = Troll
exports.Options = Options
