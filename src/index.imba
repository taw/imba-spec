# This is the worst testing library ever, but we need to start somewhere
import "chalk" as chalk
import "stringify-any" as stringify
import { deepEqual } from 'fast-equals'
let equal = deepEqual

# Have some kind of test runner class, not a global
let level = 0

def log-indented(msg)
  let indent = "".padStart(level*2, )
  console.log(indent+msg)

export def test(msg, block)
  log-indented(msg)
  try
    level += 1
    block()
  catch e
    log-indented chalk.red("ERROR: {e}")
  level -=1

export def assert-equal(a, b)
  if equal(a, b)
    log-indented chalk.green("OK")
  else
    log-indented chalk.red("FAIL: {stringify(a)} != {stringify(b)}")
