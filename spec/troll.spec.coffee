Troll     = require('../lib/troll').Troll
Options   = require('../lib/troll').Options
util      = require('util')
_ = require('underscore')

describe 'Troll', ->

  describe 'handling options', ->
    beforeEach ->
      @Troll = new Troll()
    
    it 'handles more than one option', ->
      @Troll.parseOptions (t) ->
        t.opt 'one', 'Option one', default: true
        t.opt 'two', 'Option two', default: true

      expect(@Troll.getOpts().getParsedOpts().one.short).toEqual 'o'
      expect(@Troll.getOpts().getParsedOpts().two.short).toEqual 't'

    it 'resolves shorthand options assigned by hand that collide', ->
      @Troll.parseOptions (t) ->
        t.opt 'header', 'Add a new header', default: 'X-Shakespeare'
        t.opt 'collision', 'A colliding opt', short: 'h', type: 'String'

      expect(@Troll.getOpts().getShortOpts()['h']).toEqual 'collision'
      expect(@Troll.getOpts().getParsedOpts()['header']['short']).toEqual 'H'

  describe 'generating help output', ->
    beforeEach ->
      @troll = new Troll()
      @troll.setCommandLine('test.coffee', '--one', '--three', 'yehaw', '--two')
      @troll.options (t) ->
        t.banner 'We few, we happy few, we band of brothers'
        t.opt 'one',  'Option one', default: true
        t.opt 'two',  'Option two', default: true
        t.opt 'three','Option three', type: 'String', required: true

      spyOn(@troll, 'puts').andCallFake((args...) => @buffer += x for x in args)

      @troll.usage()

    it 'prints the banner', ->
      expect(@buffer).toMatch /We few, we happy few/

    it 'formats the complex options', ->
      expect(@buffer).toMatch /--three, -T <s>: Option three/

    it 'formats the flags', ->
      expect(@buffer).toMatch /--two, -t: Option two \(default: true\)/

    it 'gets the right spacing at the beginning of the line', ->
      expect(@buffer).toMatch /[ ]{8}--one/

    it 'shows the default setting for an option', ->
      expect(@buffer).toMatch /Option two \(default: true\)/

    it 'shows which options are required', ->
      expect(@buffer).toMatch /Option three \(required\)/

    it 'adds the --help flag to the output', ->
      expect(@buffer).toMatch /--help/

  describe 'parsing the command line', ->
    beforeEach ->
      @troll = new Troll()
      @troll.setCommandLine(
        'test.coffee', '--one', '--three', 'yehaw', '--two', '--four=awesome'
      )

      spyOn(@troll, 'puts').andCallFake((args...) ->)

      @opts = @troll.options (t) ->
        t.banner 'We few, we happy few, we band of brothers'
        t.opt 'one',  'Option one', default: true
        t.opt 'two',  'Option two', default: false
        t.opt 'three','Option three', type: 'String'
        t.opt 'four' ,'Option four', default: 'default for four'
        t.opt 'five' ,'Option five', default: 'default for five'

    it 'builds the correct object from the arguments', ->
      expect(@opts.one).toBe false
      expect(@opts.two).toBe true
      expect(@opts.three).toEqual 'yehaw'
      expect(@opts.four).toEqual 'awesome'

    it 'sets defaults for options that have them and are not defined on the cli', ->
      expect(@opts.five).toEqual 'default for five'

    it 'guarantees that required arguments are supplied', ->
      expect(->
        troll = new Troll()
        troll.setCommandLine('')

        spyOn(troll, 'puts').andCallFake((args...) ->)
        spyOn(troll, 'exit').andCallFake(-> )

        troll.options (t) ->
          t.opt 'one', 'Option one', required: true, type: 'String'

      ).toThrow('--one is required')

