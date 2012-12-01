Troll     = require('../lib/troll').Troll
Options   = require('../lib/troll').Options
CaptureIO = require('./helpers/captureio').CaptureIO
util      = require('util')
_ = require('underscore')

describe 'Troll', ->

  describe 'handling options', ->
    beforeEach ->
      @Troll = new Troll()
    
    it 'handles more than one option', ->
      @Troll.options (t) ->
        t.opt 'one', 'Option one', default: true
        t.opt 'two', 'Option two', default: true

      expect(@Troll.getOpts().getParsedOpts().one.short).toEqual 'o'
      expect(@Troll.getOpts().getParsedOpts().two.short).toEqual 't'

    it 'resolves shorthand options assigned by hand that collide', ->
      @Troll.options (t) ->
        t.opt 'header', 'Add a new header', default: 'X-Shakespeare'
        t.opt 'collision', 'A colliding opt', short: 'h'

      expect(@Troll.getOpts().getShortOpts()['h']).toEqual 'collision'
      expect(@Troll.getOpts().getParsedOpts()['header']['short']).toEqual 'H'

  describe 'generating help output', ->
    beforeEach ->
      @troll = new Troll()
      @troll.options (t) ->
        t.opt 'one',  'Option one', default: true
        t.opt 'two',  'Option two', default: true
        t.opt 'three','Option three', type: 'String'
        t.banner 'We few, we happy few, we band of brothers'

      # Capture stdout so we can inspect it
      @buffer = ""
      capture = new CaptureIO()
      unhook = capture.hookStdout((string, encoding, fd) =>
        @buffer += string
      )

      @troll.displayOpts()

      # Unhook from stdout so we get real output
      unhook()

    it 'prints the banner', ->
      expect(@buffer).toMatch /We few, we happy few/

    it 'formats the complex options', ->
      expect(@buffer).toMatch /--three, -T <s>: Option three/

    it 'formats the flags', ->
      expect(@buffer).toMatch /--two, -t: Option two \(default: true\)/

    it 'gets the right spacing at the beginning of the line', ->
      expect(@buffer).toMatch /[ ]{8}--one/
