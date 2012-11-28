Troll = require('../lib/troll').Troll
_ = require('underscore')

describe 'Troll', ->

  describe 'defining one option', ->

    describe 'without a shorthand defined', ->
      beforeEach ->
        @troll = new Troll()
        @troll.opt 'header', 'Add a new header', default: 'X-Shakespeare'
  
      it 'finds the correct shorthand option flag', ->
        expect(_.has @troll.getParsedOpts(), 'h').toBe true
  
      it 'adds the correct lognhand option flag', ->
        expect(_.has @troll.getParsedOpts(), 'header').toBe true
  
      it 'correctly builds the options', ->
        expect(@troll.getParsedOpts().h.default).toEqual 'X-Shakespeare'
        expect(@troll.getParsedOpts().h.default).toEqual 'X-Shakespeare'

    describe 'with a shorthand defined', ->
      beforeEach ->
        @troll = new Troll()
        @troll.opt 'header', 'Add a new header', short: 'F', default: 'X-Shakespeare'

      it 'assigns the correct shorthand option flag', ->
        expect(_.has(@troll.getParsedOpts(), 'F')).toBe true

   describe 'with collisions in shorthand opts', ->
      beforeEach ->
        @troll = new Troll()

      it 'capitalizes the character if the lower case is not available', ->
        @troll.getParsedOpts()['h'] = 'foo'
        @troll.opt 'header', 'Add a new header', default: 'X-Shakespeare'

        expect(_.has @troll.getParsedOpts(), 'H').toBe true

      it 'finds the next available character when the first is not available', ->
        @troll.getParsedOpts()['h'] = 'foo'
        @troll.getParsedOpts()['H'] = 'foo'
        @troll.opt 'header', 'Add a new header', default: 'X-Shakespeare'

        expect(_.has @troll.getParsedOpts(), 'e').toBe true
