Troll     = require('../src/troll').Troll
util      = require('util')
_ = require('underscore')

describe 'Troll', ->

  describe 'handling options', ->
    beforeEach ->
      @troll = new Troll()
    
    it 'handles more than one option', ->
      @troll.parseOptions (t) ->
        t.opt 'one', 'Option one', default: true
        t.opt 'two', 'Option two', default: true

      expect(@troll.getOpts().getParsedOpts().one.short).toEqual 'o'
      expect(@troll.getOpts().getParsedOpts().two.short).toEqual 't'

    it 'resolves shorthand options assigned by hand that collide', ->
      @troll.parseOptions (t) ->
        t.opt 'header', 'Add a new header', default: 'X-Shakespeare'
        t.opt 'collision', 'A colliding opt', short: 'h', type: 'string'

      expect(@troll.getOpts().getShortOpts()['h']).toEqual 'collision'
      expect(@troll.getOpts().getParsedOpts()['header']['short']).toEqual 'H'

  describe 'generating help output', ->
    beforeEach ->
      @troll = new Troll()
      @troll.setCommandLine('test.coffee', '--one', '--three', 'yehaw', '--two')
      @troll.options (t) ->
        t.banner 'We few, we happy few, we band of brothers'
        t.opt 'one',  'Option one', default: true
        t.opt 'two',  'Option two', default: true
        t.opt 'three','Option three', type: 'string', required: true

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

    it 'guarantees that required arguments are supplied', ->
      expect(->
        troll = new Troll()
        troll.setCommandLine('')

        spyOn(troll, 'puts').andCallFake((args...) ->)
        spyOn(troll, 'exit').andCallFake(-> )

        troll.options (t) ->
          t.opt 'one', 'Option one', required: true, type: 'string'

      ).toThrow('--one is required. Try --help for more info.')
