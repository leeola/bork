#
# Cakefile
#
# !IMPORTANT!
# This Cakefile is severely limited due to the lack of async callbacks in
# CoffeeScript's current Cake implementation. For the time being, Bork is
# used to put some order to the async calls, ensuring that builds are
# called before tests. This however, only works for a handful of commands..
#
# This may actually spark an additional feature in Bork, down the road.
# We'll see.
#
# Copyright (c) 2012 Lee Olayvar <leeolayvar@gmail.com>
# MIT Licensed
#
{spawn} = require 'child_process'
# Once we push version 0.0.1, we need to use the npm version instead
# of the likely unstable ./build/lib version.
bork = require './build/lib'

COFFEE_BIN = './node_modules/coffee-script/bin/coffee'
MOCHA_BIN = './node_modules/mocha/bin/mocha'

exec = (cmd, args=[], cb=->) ->
  bin = spawn cmd, args
  bin.stdout.on 'data', (data) ->
    process.stdout.write data
  bin.stderr.on 'data', (data) ->
    process.stderr.write data
  bin.on 'exit', cb

# We're going to give the bork task instance a different name, to avoid
# overlapping Cakefile.task.
btask = bork()


task 'build', 'build all', ->
  invoke 'build:lib'
  invoke 'build:test'
  btask.start()

task 'build:lib', 'build lib', ->
  btask.link (done) ->
    console.log 'build lib start'
    exec COFFEE_BIN, ['-co', './build/lib', './lib'], -> console.log 'build lib done'; done()

task 'build:test', 'build test', ->
  btask.link (done) ->
    console.log 'build test start'
    exec COFFEE_BIN, ['-co', './build/test', './test'], -> console.log 'build test done'; done()

task 'test', 'build test, then run it', ->
  invoke 'build:test'
  invoke 'test:nobuild'
  btask.start()

task 'test:all', 'build all, and run the tests', ->
  invoke 'build:lib'
  invoke 'build:test'
  invoke 'test:nobuild'
  btask.start()

task 'test:nobuild', 'just run the tests, don\'t build anything', ->
  btask.seq (done) ->
    console.log 'test start'
    exec MOCHA_BIN, ['./test'], -> console.log 'test done'; done()

task 'prepublish', 'Build all, test all. Designed to work before `npm publish`', ->
  invoke 'build:lib'
  invoke 'build:test'
  invoke 'test:nobuild'
  btask.start()
