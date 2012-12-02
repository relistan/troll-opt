Options = require('../lib/troll').Options
_ = require('underscore')

describe 'Options', ->

  describe 'without a shorthand defined', ->
    beforeEach ->
      @opts = new Options()
      @opts.opt 'header', 'Add a new header', default: 'X-Shakespeare'
  
    it 'finds the correct shorthand option flag', ->
      expect(_.has @opts.getShortOpts(), 'h').toBe true
  
    it 'adds the correct longhand option flag', ->
      expect(_.has @opts.getParsedOpts(), 'header').toBe true
  
    it 'correctly builds the options', ->
      expect(@opts.getParsedOpts().header.default).toEqual 'X-Shakespeare'
      expect(@opts.getParsedOpts().header.short).toEqual 'h'

  describe 'with a shorthand defined', ->
    beforeEach ->
      @opts = new Options()
      @opts.opt 'header', 'Add a new header', short: 'F', default: 'X-Shakespeare'

    it 'assigns the correct shorthand option flag', ->
      expect(_.has(@opts.getShortOpts(), 'F')).toBe true

  describe 'with collisions in shorthand opts', ->
    beforeEach ->
      @opts = new Options()

    it 'capitalizes the character if the lower case is not available', ->
      @opts.getShortOpts().h = 'foo'
      @opts.opt 'header', 'Add a new header', default: 'X-Shakespeare'

      expect(_.has @opts.getShortOpts(), 'H').toBe true

    it 'finds the next available character when the first is not available', ->
      @opts.getShortOpts().h = 'foo'
      @opts.getShortOpts().H = 'foo'
      @opts.opt 'header', 'Add a new header', default: 'X-Shakespeare'

      expect(_.has @opts.getShortOpts(), 'e').toBe true

    it 'tries multiple options when earlier options are not available', ->
      @opts.getShortOpts().h = 'foo'
      @opts.getShortOpts().H = 'foo'
      @opts.getShortOpts().e = 'foo'
      @opts.getShortOpts().E = 'foo'
      @opts.opt 'header', 'Add a new header', default: 'X-Shakespeare'

      expect(_.has @opts.getShortOpts(), 'a').toBe true

  describe 'handles required arguments', ->

    it 'detects required opts', ->
      opts = new Options()
      opts.opt 'header', 'Add a header', type: 'str', required: 'true'

      expect(opts.requiredOpts['header']).toBe true
      expect(_.has(opts.requiredOpts, 'asdf')).toBe false

  describe 'validates the passed arguments', ->
    beforeEach ->
      @opts = new Options()

    it 'requires an argument if type is defined', ->
      @opts.opt 'header', 'Add a header', type: 'str'
      expect(@opts.getParsedOpts().header.takesValue).toBe true

    it 'does not require an argument if type is undefined and default is a boolean', ->
      @opts.opt 'silent', 'Enable silent mode', default: false
      expect(@opts.getParsedOpts().silent.takesValue).toBe false

    it 'requires an argument if type is undefined and default is not a boolean', ->
      @opts.opt 'header', 'Add a header', default: 'X-Something'
      expect(@opts.getParsedOpts().header.takesValue).toBe true

    it 'sets the right type based on the provided default', ->
      @opts.opt 'header', 'Add a header', default: 'X-Something'
      expect(@opts.getParsedOpts().header.type).toEqual 'String'

      @opts.opt 'silent', 'Enable silent mode', default: false
      expect(@opts.getParsedOpts().silent.type).toEqual 'Boolean'

    it 'raises when the type was set and a default was provided', ->
      expect( =>
          @opts.opt 'header', 'Add a header', default: 'X-Something', type: 'String'
      ).toThrow('type defined when default was provided')

    it 'raises when no options are set', ->
      expect( => @opts.opt 'header', 'Add a header' ).toThrow('No options were set')

    it 'raises when neither type nor default are set', ->
      expect( => @opts.opt 'header', 'Add a header', required: true ).toThrow(
        'Neither default nor type is set for \'header\'')

    it 'raises when unknown settings are passed', ->
      expect( => @opts.opt 'header', 'Add a header', type: 'Boolean', asdf: true ).toThrow(
        'Unrecognized options \'asdf\'')

  describe 'usage banners', ->
  
    it 'can store a text argument', ->
      opts = new Options()
      banner = 'This is the banner'
      opts.banner banner

      expect(opts.getBanner()).toEqual "  #{banner}"
