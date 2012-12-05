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
    unless @hasShort(short)
      throw new TrollArgumentError("No such opt was defined! (#{short})")

    @shortOpts[short]

  takesValue: (key) ->
    unless @has(key)
      throw new TrollArgumentError("No such opt was defined! (#{key})")

    @parsedOpts[key].takesValue or
      (@hasShort(key) and @parsedOpts[@shortOpts[key]].takesValue)

  opt: (name, description, opts) ->
    @validateOpts(name, opts)

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

    @validateTypeFor(opts)

  banner: (text) ->
    @helpBanner = "  #{text}"

  calculateOptionLength: (k) ->
    return k.length if @parsedOpts[k].type is 'Boolean'
    k.length + 4

  optsWithDefaults: ->
    opt for opt in _.keys(@parsedOpts) when _.has(@parsedOpts[opt], 'default')

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

  validateOpts: (name, opts) ->
    throw new TrollOptError('No options were set') if _.isUndefined(opts)

    unless _.has(opts, 'default') or _.has(opts, 'type')
      throw new TrollOptError("Neither default nor type is set for '#{name}'")

    if _.has(opts, 'default') and _.has(opts, 'required')
      throw new TrollOptError("Can't define both default and required on '#{name}'")

    badOpts = (opt for opt in _.keys(opts) when @validOpt(opt) is false)
    if badOpts.length isnt 0
      throw new TrollOptError("Unrecognized options '#{badOpts.join(', ')}'")

  validOpt: (opt) ->
    _.contains([ 'short', 'type', 'required', 'default' ], opt)

  validateRequired: (opts) ->
    badOpts = (opt for opt in @requiredOpts when _.has(opts, opt) isnt true)
    if badOpts.length isnt 0
      if badOpts.length is 1
        throw new TrollOptError("--#{badOpts[0]} is required. Try --help for more info.")
      else
        badOpts = ("--#{opt}" for opt in badOpts)
        throw new TrollOptError("'#{badOpts.join(', ')}' are required. Try --help for more info.")

  validateTypeFor: (opt) ->
    unless _.contains(['String', 'Boolean', 'Integer', 'Float'], opt.type)
      throw new TrollOptError("Invalid type: #{opt.type}")

class Troll
  constructor: ->
    @opts         = new Options()
    @parsingStack = []
    @commandLine  = _.clone(process.argv).splice(1)
    @givenOpts    = {}

  # ----- Public
  setCommandLine: (@commandLine...) ->

  getCommandLine: ->
    @commandLine = _.flatten(x.split('=') for x in @commandLine[1..-1])

  parse: ->
    @handle arg for arg in @getCommandLine()
    @setDefaultValue(opt) for opt in @opts.optsWithDefaults()

  handle: (arg) ->
    if arg is '--help'
      throw new UsageError()

    if @recognized(arg) and !@haveArgWaiting()
      arg = @stripDashes(arg)

      if @opts.hasShort(arg)
        arg = @opts.longForShort(arg)

      if _.has(@givenOpts, arg)
        throw new TrollArgumentError("--#{arg} specified twice!")

      if @opts.takesValue(arg)
        @parsingStack.push(arg)
        return

      # Doesn't take a value, must be a flag
      @givenOpts[arg] = !(@opts.get(arg).default)

    else if @haveArgWaiting()
      arg = @convert(@parsingStack[0], arg)

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

  setDefaultValue: (opt) ->
    optSpec =  @opts.getParsedOpts()[opt]
    @givenOpts[opt] = optSpec.default unless _.has(@givenOpts, opt)

  convert: (opt, value) ->
    type = @opts.get(opt).type
    retValue = switch type
      when 'Integer' then parseInt(value)
      when 'Float'   then parseFloat(value)
      when 'String'  then value

    if _.contains([ 'Integer', 'Float' ], type) and !(retValue > 0) and !(retValue < 0)
      throw new TrollArgumentError("#{opt} has an invalid value supplied!  Must be a #{type}")

    retValue


  puts: (args...) ->
    console.log args...

  exit: ->
    process.exit()

exports.Troll   = Troll
exports.Options = Options
