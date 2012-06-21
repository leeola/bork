#
# lib/task.coffee
#
# Copyright (c) 2012 Lee Olayvar <leeolayvar@gmail.com>
# MIT Licensed
#


# Task
#
# Desc:
#   A single task entity, with multiple tasks chained before, after, or in
#   parallel with it. Note that instances of this class are designed to be
#   run once and thrown away. To rerun the chain, recreate the chain. Get
#   off my lawn.
class Task
  # (task) -> undefined
  #
  # Params:
  #   task: A function, Task instance. undefined/null is also accepted.
  #
  # Desc:
  #   Initialize a Task object.
  constructor: (task) ->
    if task?
      task = (next) -> next()
    else if task instanceof Task
      task = (next) -> next()
      @seq task
    
    # The fn this task contains.
    @_fn = task
    
    # Simple bools for whether this task has been started and/or completed.
    @_started = false
    @_completed = false
    
    # A list of tasks that are started when this was started (like pars),
    # but these tasks must be completed before this task will call it's seqs
    @_links = []
    # A list of tasks that will be executed when this task starts (assuming
    # all requirements are met)
    @_pars = []
    # A list of tasks that must be completed before this task can start.
    @_reqs = []
    # A list of tasks that will be executed when this task is complete, and
    # all requirements (such as reqs and links) have completed.
    @_seqs = []
  
  # 
  _next: =>
  
  is_req: =>
  
  link: =>
  
  # (task) -> new Task(task) | task
  #
  # Params:
  #   task: A function or an instance of Task
  #
  # Returns:
  #   An instance of Task based on the function/task given.
  #
  # Desc:
  #   When this task is started, start the given task. Or, if the given task
  #   is started, start this task.
  par: (task) =>
    if task instanceof Function
      task = new Task(task)
    
    # Append the new task to this pars, and this pars to the new task.
    # that way when either task gets started, the other one gets started
    # aswell.
    @_pars.push task
    task._pars.push @
    
    # Return the newly given task so that it can be chained.
    return task
  
  # (task) -> this
  #
  # Params:
  #   task: A function or an instance of Task
  #
  # Desc:
  #   Require that the arg-task be completed before this-task executes.
  #   If this-task fails to start (due to reqs/etc), arg-task will start
  #   this-task (via a seq call).
  req: (task) =>
    if task instanceof Function
      task = new Task(task)
    
    @_reqs.push task
    
    # By adding @ as a seq to the given task, we assure that even if the
    # requirement causes this-task to not execute, this-task will still
    # execute *eventually*.
    task.seq @
  
  seq: =>
  
  # () -> undefined
  #
  # Desc:
  #   Start this task chain. Note that start will not actually execute the
  #   task if there are unfinished requirements (such as reqs or links)
  start: =>
    if @_started
      return
    
    # Check the reqs to ensure all have finished.
    for req in @_reqs
      if req._task_completed is false
        return
    
    # Mark the task as started, call the fn, and start all pars.
    @_started = true
    @_fn(@_next)
    for par in @_pars
      par.start()


exports.Task = Task