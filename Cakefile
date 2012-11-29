{spawn} = require 'child_process'
{print} = require 'util'

test = (callback) ->
  jasmine = spawn 'jasmine-node', ['--coffee', 'spec',]
  jasmine.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  jasmine.stdout.on 'data', (data) ->
    print data.toString()
  jasmine.on 'exit', (code) ->
    callback?() if code is 0

task 'test', 'Run all tests', ->
  test()
