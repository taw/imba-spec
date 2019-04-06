# This is the worst testing library ever, but we need to start somewhere
import "chalk" as chalk
import "stringify-any" as stringify
import { deepEqual } from 'fast-equals'
let equal = deepEqual

# Private export
export let defined-tests = []

let current-test-case = null
let current-test-group = null
let level = 0

let def extract-location(stack-trace)
  stack-trace

let def log-indented(msg)
  let indent = "".pad-start(level*2)
  console.log indent + msg

class TestCase
  def initialize(msg, loc, parent, block)
    @msg = msg
    @loc = loc
    @parent = parent
    @block = block

  def assert-equal(a, b)
    if equal(a, b)
      log-indented chalk.green("OK")
    else
      log-indented chalk.red("FAIL: {stringify(a)} != {stringify(b)}")

  def create-context
    let context-blocks = {}
    let tg = @parent

    while tg
      let lets = tg.lets
      for k, v of lets
        # Could be already overriden by a sub-group
        unless context-blocks[k]
          context-blocks[k] = v
      tg = tg:_parent

    let context = {}
    let context-called = {}
    let context-values = {}
    let context-done = {}

    for k, v of context-blocks
      context[k] = do
        if context-done[k]
          context-values[k]
        else if context-called[k]
          throw Error.new("Declaration {k} called cyclically")
        else
          context-called[k] = true
          let result = v(context)
          context-done[k] = true
          context-values[k] = result
    context

  def run
    log-indented @msg
    let context = create-context
    try
      level += 1
      current-test-case = this
      @block(context)
    catch e
      for line in e:stack.split("\n")
        log-indented chalk.red(line)
    level -= 1
    current-test-case = null

class TestGroup
  prop lets

  def initialize(msg, loc, parent, block)
    @msg = msg
    @loc = loc
    @parent = parent
    @lets = {}
    @children = []

    current-test-group = this
    block()
    current-test-group = @parent

  def describe(msg, loc, block)
    @children.push TestGroup.new(msg, loc, this, block)

  def it(msg, loc, block)
    @children.push TestCase.new(msg, loc, this, block)

  def declare(name, block)
    @lets[name] = block

  def run
    log-indented @msg
    level += 1
    @children.for-each do |c|
      c.run
    level -= 1

export def describe(msg, block)
  let e = Error.new
  let loc = extract-location(e:stack)

  if current-test-group
    current-test-group.describe(msg, loc, block)
  else
    let tg = TestGroup.new(msg, loc, null, block)
    defined-tests.push(tg)

export def declare(name, block)
  if current-test-group
    current-test-group.declare(name, block)
  else
    throw Error.new("Cannot call it outside describe block")

export def it(msg, block)
  let e = Error.new
  let loc = extract-location(e:stack)

  if current-test-group
    current-test-group.it(msg, loc, block)
  else
    throw Error.new("Cannot call it outside describe block")

export def assert-equal(a, b)
  if current-test-case
    current-test-case.assert-equal(a, b)
  else
    throw Error.new("Cannot call assert-equal outside it block")
