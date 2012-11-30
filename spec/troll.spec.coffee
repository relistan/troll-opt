Troll   = require('../lib/troll').Troll
Options = require('../lib/troll').Options
_ = require('underscore')

describe 'Troll', ->

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

