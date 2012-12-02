_ = require 'underscore'

# Define some custom error classes. For internal signalling.
# Note: these swallow file and line number info!
class UsageError extends Error
  constructor: (@message, ignored...) ->
class TrollArgumentError extends Error
  constructor: (@message, ignored...) ->
class TrollOptError extends Error
  constructor: (@message, ignored...) ->

class Options
  constructor: ->
    @parsedOpts   = {}
    @shortOpts    = {}
    @helpBanner   = ""
    @requiredOpts = []

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

  longForShort: (short) ->
    throw new TrollArgumentError("No such opt was defined! (#{short})") unless @hasShort(short)
    @parsedOpts[@shortOpts[short]]

  takesValue: (key) ->
    throw new TrollArgumentError("No such opt was defined! (#{key})") unless @has(key)
    @parsedOpts[key].takesValue or
      (@hasShort(key) and @parsedOpts[@shortOpts[key]].takesValue)

  opt: (name, description, opts) ->
    throw new TrollOptError('No options were set') if _.isUndefined(opts)

    unless _.has(opts, 'default') or _.has(opts, 'type')
      throw new TrollOptError("Neither default nor type is set for '#{name}'")

    if _.has(opts, 'default') and _.has(opts, 'required')
      throw new TrollOptError("Can't define both default and required on '#{name}'")

    @validateOpts(opts)

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

    if _.has(opts, 'required')
      @requiredOpts.push(name)

  banner: (text) ->
    @helpBanner = "  #{text}"

  calculateOptionLength: (k) ->
    return k.length if @parsedOpts[k].type is 'Boolean'
    k.length + 4

  # ----- Private
  processDefaultFor: (opts) ->
    if _.has(opts, 'default')
      throw new TrollOptError('type defined when default was provided') if opts['type']
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

  validateOpts: (opts) ->
    badOpts = (opt for opt in _.keys(opts) when @validOpt(opt) isnt true)
    if badOpts.length isnt 0
      throw new TrollOptError("Unrecognized options '#{badOpts.join(', ')}'")

  validOpt: (opt) ->
    _.contains([ 'short', 'type', 'required', 'default' ], opt)

  validateRequired: (opts) ->
    badOpts = (opt for opt in @requiredOpts when _.has(opts, opt) isnt true)
    if badOpts.length isnt 0
      if badOpts.length is 1
        throw new TrollOptError("--#{badOpts[0]} is required")
      else
        badOpts = ("--#{opt}" for opt in badOpts)
        throw new TrollOptError("'#{badOpts.join(', ')}' are required")

class Troll
  constructor: ->
    @opts         = new Options()
    @parsingStack   = []
    @commandLine  = _.clone(process.argv).splice(1)
    @givenOpts    = {}

  # ----- Public
  setCommandLine: (@commandLine...) ->

  getCommandLine: ->
    @commandLine = _.flatten(x.split('=') for x in @commandLine[1..-1])

  parse: ->
    @handle arg for arg in @getCommandLine()

  handle: (arg) ->
    if arg is '--help'
      throw new UsageError()

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
      throw new TrollArgumentError("Unknown argument: #{arg}")

  options: (callback) ->
    try
      @parseOptions callback
      @parse()
      @opts.validateRequired(@givenOpts)
      return @givenOpts
    catch error
      if error instanceof UsageError
        @usage()
        @exit()
      else
        throw error

  parseOptions: (callback) ->
    # Parse the options without processing them
    callback @opts

  getOpts: -> @opts

  usage: ->
    @puts "\nUsage: #{@commandLine[0]} [options]"
    @puts @opts.getBanner() if @opts.getBanner().length > 0

    len = @opts.longestOptionLength()
    len = 6 if len < '--help'.length

    @displayOneOpt(opt, len) for opt in @opts.sorted()
    @puts (" " for x in [1..len+2]).join("") + "--help: Display this help text"
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
    output += " (required)" if _.has(opts, 'required') and opts.required
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

  exit: ->
    process.exit()

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
