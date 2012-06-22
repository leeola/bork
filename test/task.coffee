#
# test/task.coffee
#
# Copyright (c) 2012 Lee Olayvar <leeolayvar@gmail.com>
# MIT Licensed
#
should = require 'should'


# There are here so my IDE will shut the hell up.
before = global.before
before_each = global.beforeEach
describe = global.describe
it = global.it


describe 'Task', ->
  {Task} = require '../lib/task'
  
  describe '#constructor', ->
    describe 'with no args', ->
      task = undefined
      before ->
        task = new Task()
      
      it 'should create a function of it\'s own', ->
        task._fn.should.be.an.instanceof Function
    
    describe 'with a function arg', ->
      task = undefined
      fn = undefined
      before ->
        fn = ->
        task = new Task fn
      
      it 'should store the given function', ->
        task._fn.should.equal fn
    
    describe 'with a task as an arg', ->
      task = undefined
      arg_task = undefined
      before ->
        arg_task = new Task()
        task = new Task arg_task
      
      it 'should store the arg_task as a seq', ->
        task._seqs.should.eql [arg_task]
  
  describe '#is_req', ->
  
  describe '#link', ->
  
  describe '#par', ->
  
  describe '#req', ->
  
  describe '#seq', ->
