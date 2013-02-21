Parser = require('../src/troll').Parser
Options = require('../src/troll').Options
_ = require('underscore')

describe 'Parser', ->

  describe 'parsing the command line', ->
    options = new Options()
    options.parsedOpts = {
      one:
         default: true,
         desc: 'Option one',
         type: 'boolean',
         takesValue: false,
         short: 'o',
      two:
         default: false,
         desc: 'Option two',
         type: 'boolean',
         takesValue: false,
         short: 't',
      three:
         type: 'integer',
         desc: 'Option three',
         takesValue: true,
         short: 'T',
      four:
         default: 'default for four',
         desc: 'Option four',
         type: 'string',
         takesValue: true,
         short: 'f',
      five:
         default: 'default for five',
         desc: 'Option five',
         type: 'string',
         takesValue: true,
         short: 'F' }

    options.shortOpts = { 
      o: 'one',
      t: 'two',
      T: 'three',
      f: 'four',
      F: 'five' }

    beforeEach ->
      @parser = new Parser(options)
      @opts = @parser.parse([
        '--one', '--three', '1', '--two', '-f=1'
      ])

    it 'builds the correct object from the arguments', ->
      expect(@opts.one).toBe false
      expect(@opts.two).toBe true
      expect(@opts.three).toEqual 1
      expect(@opts.five).toEqual 'default for five'

    it 'sets defaults for options that have them and are not defined on the cli', ->
      expect(@opts.five).toEqual 'default for five'

    it 'handles short options just like long ones', ->
      expect(_.has(@opts, 'four')).toBe true

    it 'raises if the same argument is passed more than once', ->
      expect(=>
        @parser.parse(['test.coffee', '-f', 'shakespeare', '-f', 'foo'])
      ).toThrow('--four specified twice!')

    it 'does type conversion to the desired type', ->
      expect(@opts.three).toEqual 1

    it 'raises when the argument supplied to a flag', ->
      # Note that we can't detect this if it's the last arg on the command line
      expect(=>
        parser = new Parser(options)
        parser.parse(['test.coffee', '-t=badarg', '-f'])
      ).toThrow("Unknown argument: badarg")

  describe 'working with multi-word options', ->

    it 'converts mid-option dashes to camel case', ->
      opts = new Options()
      opts.opt 'twoCases', 'do something', default: true

      parser = new Parser(opts)
      parser.handle '--two-cases'

      expect(_.has(parser.givenOpts, 'twoCases')).toBe true

  describe 'working with the remaining command line options', ->

    beforeEach ->
      opts = new Options()
      opts.opt 'one', 'a boring flag', default: true
      @parser = new Parser(opts)

    it 'does not complain with additional non-dashed arguments', ->
      @parser.parse([ '--one', 'filename', 'filename2' ])
      expect(_.has(@parser.givenOpts, 'one')).toBe true
      expect(_.has(@parser.givenOpts, 'filename')).toBe false

    it 'makes the remaining arguments available in parser.argv', ->
      @parser.parse([ '--one', 'filename', 'filename2' ])
      expect(@parser.argv).toEqual [ 'filename', 'filename2' ]
    
