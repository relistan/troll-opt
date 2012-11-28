Troll = require('../lib/troll').Troll
_ = require('underscore')

describe 'Troll', ->

  describe 'defining one option', ->

    describe 'without a shorthand defined', ->
      beforeEach ->
        @troll = new Troll()
        @troll.opt 'header', 'Add a new header', default: 'X-Shakespeare'
  
      it 'finds the correct shorthand option flag', ->
        expect(_.has @troll.getShortOpts(), 'h').toBe true
  
      it 'adds the correct longhand option flag', ->
        expect(_.has @troll.getParsedOpts(), 'header').toBe true
  
      it 'correctly builds the options', ->
        expect(@troll.getParsedOpts().header.default).toEqual 'X-Shakespeare'
        expect(@troll.getParsedOpts().header.short).toEqual 'h'

    describe 'with a shorthand defined', ->
      beforeEach ->
        @troll = new Troll()
        @troll.opt 'header', 'Add a new header', short: 'F', default: 'X-Shakespeare'

      it 'assigns the correct shorthand option flag', ->
        expect(_.has(@troll.getShortOpts(), 'F')).toBe true

    describe 'with collisions in shorthand opts', ->
      beforeEach ->
        @troll = new Troll()

      it 'capitalizes the character if the lower case is not available', ->
        @troll.getShortOpts()['h'] = 'foo'
        @troll.opt 'header', 'Add a new header', default: 'X-Shakespeare'

        expect(_.has @troll.getShortOpts(), 'H').toBe true

      it 'finds the next available character when the first is not available', ->
        @troll.getShortOpts()['h'] = 'foo'
        @troll.getShortOpts()['H'] = 'foo'
        @troll.opt 'header', 'Add a new header', default: 'X-Shakespeare'

        expect(_.has @troll.getShortOpts(), 'e').toBe true

      it 'tries multiple options when earlier options are not available', ->
        @troll.getShortOpts()['h'] = 'foo'
        @troll.getShortOpts()['H'] = 'foo'
        @troll.getShortOpts()['e'] = 'foo'
        @troll.getShortOpts()['E'] = 'foo'
        @troll.opt 'header', 'Add a new header', default: 'X-Shakespeare'

        expect(_.has @troll.getShortOpts(), 'a').toBe true

      it 'resolves shorthand options assigned by hand that collide', ->
        @troll.opt 'collision', 'A colliding opt', short: 'F'

        expect(@troll.getShortOpts()['F']).toEqual 'collision'

  describe 'defining multiple options', ->
    
    it 'handles more than one option', ->
      troll = new Troll()
      troll.options (t) ->
        t.opt 'one', 'Option one', default: true
        t.opt 'two', 'Option two', default: true

      expect(troll.getParsedOpts().one.short).toEqual 'o'
      expect(troll.getParsedOpts().two.short).toEqual 't'
