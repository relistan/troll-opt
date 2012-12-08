Parser = require('../src/troll').Parser
Options = require('../src/troll').Options
_ = require('underscore')

describe 'Parser', ->

  describe 'parsing the command line', ->
    beforeEach ->
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

    it 'raises when the argument supplied is of the wrong type', ->

