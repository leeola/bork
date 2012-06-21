#
# lib/index.coffee
#
# Copyright (c) 2012 Lee Olayvar <leeolayvar@gmail.com>
# MIT Licensed
#
task = require './task'

create = (task) -> return new task.Task(task)


exports = module.exports = create
exports.create = create
exports.task = task