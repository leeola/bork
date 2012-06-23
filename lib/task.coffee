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
    # Simple bools for whether this task has been started and/or completed.
    @_started = false
    @_completed = false
    @_started_seqs = false
    
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
    
    if not task?
      task = (next) -> next()
    else if task instanceof Task
      @seq task
      task = (next) -> next()
    
    # The fn this task contains.
    @_fn = task
  
  # () -> undefined
  #
  # Desc:
  #   This method is given as the callback to `@_fn`, and when called,
  #   signals the completion of the given task.
  _next: =>
    @_completed = true
    @_start_seqs()
  
  # () -> undefined
  #
  # Desc:
  #   Start all of the `@_links` seqs.
  #   
  #   This method is called by `@_next` when this-task is the last task to
  #   be completed. Since it is the last, it needs to start all of the other
  #   tasks children, because they were waiting on this task *(because they're
  #   linked.. get it?)*.
  _start_link_seqs: =>
    for link in @_links
      link._start_seqs()
  
  # () -> undefined
  #
  # Desc:
  #   Start all of the seq tasks given to this Task.
  _start_seqs: =>
    if @started_seqs()
      return
    
    # Ensure that our seq's never get called if any @_links have not yet
    # completed.
    for link in @_links
      if not link.completed()
        return
    
    # All children requirements have been met, so, call the children!
    @_started_seqs = true
    for seq in @_seqs
      seq.start()
    
    # Since we looped through all of the linked tasks (a few lines up) and
    # saw that all of them are completed, we know that out of all of the
    # linked tasks, this task was the last to complete. So, we need to
    # start their seqs, since they waited for this task to complete.
    @_start_link_seqs()
  
  # () -> bool
  #
  # Desc:
  #   Checks whether or not this Task has been completed or not. Completed is
  #   defined as the task function itself having called it's function
  #   argument *(@_next)*.
  completed: =>
    return @_completed
  
  # (task) -> this
  #
  # Params:
  #   task: A function or an instance of Task
  #
  # Returns:
  #   Returns `@`. By returning this task, we allow code flow such as..
  #   ```
  #     task = new Task
  #     other = new Task
  #     task.seq(fn).is_req(other).seq(diff_fn)
  #   ```
  #   where if you were forced to use `@req`, you would have to have
  #   expose the object, like..
  #   ```
  #     task = new Task
  #     other = new Task
  #     seq_task = task.seq(fn)
  #     other.req(seq_task)
  #     seq_task.seq(diff_fn)
  #   ```
  #
  # Desc:
  #   This is essentially the reverse of `@req`. The difference being, that
  #   this method sets the completion of this-task as a requirement for the
  #   arg-task. It's just a shorthand method, designed for readability and
  #   code flow, so a requirement can be set inline.
  is_req: (task) =>
    if task instanceof Function
      task = new Task task
    task.req @
    return @
  
  # (task) -> new Task(task) | task
  #
  # Params:
  #   task: A function or an instance of Task
  #
  # Returns:
  #   An instance of Task based on the function/task given.
  #
  # Desc:
  #   This is essentially the same as `@par`. The difference being that while
  #   this-task and arg-task are both started at the same time, neither task
  #   will call their children (seqs) until both are completed. To phrase
  #   it differently, they execute in parallel, but their completion is
  #   dependant on their linked tasks.
  link: (task) =>
    if task instanceof Function
      task = new Task task
    @_links.push task
    task._links.push @
    return task
  
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
      task = new Task task
    
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
      task = new Task task
    @_reqs.push task
    # By adding @ as a seq to the given task, we assure that even if the
    # requirement causes this-task to not execute, this-task will still
    # execute *eventually*.
    task.seq @
    return @
  
  # (task) -> new Task(task_fn) | task
  #
  # Params:
  #   task: A function or Task instance
  #
  # Desc:
  #   Execute the given task after this task is complete, and all links
  #   have been completed.
  seq: (task) =>
    if task instanceof Function
      task = new Task task
    @_seqs.push task
    return task
  
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
    @_fn @_next
    for par in @_pars
      par.start()
    
    for link in @_links
      link.start()
  
  # () -> bool
  #
  # Desc:
  #   Checks whether or not this Task has been started or not. Started is
  #   defined as `@start()` being called, and all requirements being met.
  started: =>
    return @_started
  
  # () -> bool
  #
  # Desc:
  #   Checks whether or not this Task has started the seq tasks contained.
  started_seqs: =>
    return @_started_seqs


# (task) -> new Task(task_fn) | task
#
# Params:
#   task: A function or Task instance
#
# Desc:
#   A simple Task creation function, so you can avoid the `new` syntax if
#   preferred.
exports.create = (task) -> return new task.Task(task)
exports.Task = Task