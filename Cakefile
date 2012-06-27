#
# Cakefile
#
# Copyright (c) 2012 Lee Olayvar <leeolayvar@gmail.com>
# MIT Licensed
#
{spawn} = require 'child_process'


COFFEE_BIN = './node_modules/coffee-script/bin/coffee'
MOCHA_BIN = './node_modules/mocha/bin/mocha'

exec = (cmd, args=[], cb=->) ->
  bin = spawn cmd, args
  bin.stdout.on 'data', (data) ->
    process.stdout.write data
  bin.stderr.on 'data', (data) ->
    process.stderr.write data
  bin.on 'exit', cb

task 'build', 'build all', ->
  invoke 'build:lib'
  invoke 'build:test'

task 'build:lib', 'build lib', ->
  exec COFFEE_BIN, ['-co', './build/lib', './lib']

task 'build:test', 'build test', ->
  exec COFFEE_BIN, ['-co', './build/test', './test']

task 'test', 'build test, then run it', ->
  invoke 'build:test'
  invoke 'test:nobuild'

task 'test:all', 'build all, and run the tests', ->
  invoke 'build'
  invoke 'test:nobuild'

task 'test:nobuild', 'just run the tests, don\'t build anything', ->
  exec MOCHA_BIN, ['./test']
