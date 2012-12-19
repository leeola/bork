# 
# # Test Index
# 
# Execute this, or any sub file to test that specific collection of tests.
dork = require 'dork'




exports.options = require './options'
exports.task = require './task'
if require.main is module then dork.run()