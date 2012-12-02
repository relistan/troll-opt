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

  get: (key) ->
    @parsedOpts[key]

  has: (key) ->
    _.has(@parsedOpts, key)

  hasShort: (key) ->
    _.has(@shortOpts, key)

  takesValue: (key) ->
    throw new TrollArgumentException('No such opt was defined!') unless @has(key)
    @parsedOpts[key].takesValue or
      (_.has(@shortOpts, key) and @parsedOpts[@shortOpts[key]].takesValue)

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
    @opts         = new Options()
    @parsingStack   = []
    @commandLine  = process.argv.splice(1)
    @givenOpts    = {}

  # ----- Public
  setCommandLine: (@commandLine...) ->

  getCommandLine: ->
    @commandLine = _.flatten(x.split('=') for x in @commandLine[1..-1])

  parse: ->
    @handle arg for arg in @getCommandLine()

  handle: (arg) ->
    if arg is '--help'
      throw new UsageException()

    if @recognized(arg) and !@haveArgWaiting()
      arg = @stripDashes(arg)

      if @opts.hasShort(arg)
        arg = @opts.longForShort(arg)

      if @opts.takesValue(arg)
        @parsingStack.push(arg)
        return

      # Doesn't take a value, must be a flag
      @givenOpts[arg] = !(@opts.get(arg).default)

    else if @haveArgWaiting()
      @givenOpts[@parsingStack[0]] = arg
      @parsingStack = []

    else
      throw new TrollArgumentException("Unknown argument: #{arg}")

  options: (callback) ->
    try
      @parseOptions callback
      @parse()
      @givenOpts
    catch UsageException
      @usage()
      process.exit()

  parseOptions: (callback) ->
    # Parse the options without processing them
    callback @opts

  getOpts: -> @opts

  usage: ->
    @puts "\nUsage: #{@commandLine[0]} [options]"
    @puts @opts.getBanner() if @opts.getBanner().length > 0

    len = @opts.longestOptionLength()
    @displayOneOpt(opt, len) for opt in @opts.sorted()
    @puts ""

  # ----- Private
  displayOneOpt: (opt, len) ->
    name = opt[0]
    opts = opt[1]

    output =  @spacePad("#{name}", len + 1)
    output += ", -#{opts.short}"
    output += " <#{@opts.displayTypeFor(opts.type)}>" if opts.type != 'Boolean'
    output += ": #{opts.desc}"
    output += " (default: #{opts.default})" if _.has(opts, 'default')
    @puts output

  spacePad: (str, len) ->
    strlen = @opts.calculateOptionLength(str)
    pad = (" " for x in [strlen..len]).join("")
    "#{pad}--#{str}"

  recognized: (arg) ->
    bareArg = @stripDashes(arg)
    (arg.match(/^--/) and @opts.has(bareArg)) or
       (arg.match(/^-/)  and @opts.hasShort(bareArg))

  stripDashes: (arg) ->
    arg.replace(/^-+/, '')

  haveArgWaiting: ->
    @parsingStack.length != 0

  puts: (args...) ->
    console.log args...

class UsageException extends Error
class TrollArgumentException extends Error

#(new Troll).options (t) -> 
#  t.opt 'foo',    'Some description',               'default': true, 'short': 'F'
#  t.opt 'header', 'Some description of a non-flag', 'default': 'asdf'

# Usage: foo sub_command [options]
#   Sub commands: list, fetch. Try foo cmd --help for more options.
#   --username, -u <s>:   Foo Username (default: asdf)
#   --password, -p <s>:   Foo Password (default: asdf)
#       --wsdl, -w <s>:   The Foo wsdl URL to connect to (default: http://foo)
#           --help, -h:   Show this message


exports.Troll   = Troll
exports.Options = Options
