{expect} = require('chai')
should = require('../use')


# These tests use a meta language to compare the `expect` and `should`
# syntax.

# Create a test that compares the result of `expectation.test(target)`
# with that of `tester(subject)`.
compare = (subject, expectation, tester)->
  thrown = null
  try
    tester(subject)
  catch e
    thrown = e.message

  label = subject + ' ' + expectation.message
  if thrown
    label = 'fail: ' + label
  else
    label = 'test: ' + label

  it label, ->
    if thrown
      expect(-> expectation.test(subject)).to.throw(thrown)
    else
      expectation.test(subject)

# Return an object with a chainable compare method.
#
# The method calls `compare` on all of its subjects.
subjects = (targets)->
  compare: (expectation, tester)->
    for target in targets
      compare target, expectation, tester
    return this


######################
# Actual test logic
######################

describe 'equal', ->
  subjects([null, 1, 2])
  .compare(
    should.equal(1)
    (it)-> expect(it).equal(1)
  ).compare(
    should.not.equal(1)
    (it)-> expect(it).not.equal(1)
  )


describe 'undefined', ->
  subjects([null, undefined, {}])
  .compare(
    should.be.undefined
    (it)-> expect(it).to.be.undefined
  ).compare(
    should.not.be.undefined
    (it)-> expect(it).not.to.be.undefined
  )


describe 'property', ->
  subjects([5, {x: 5}, {x: 4}, {x: {y: 3}}])
  .compare(
    should.have.property('x')
    (it)-> expect(it).to.have.property('x')
  ).compare(
    should.not.have.property('x')
    (it)-> expect(it).not.to.have.property('x')
  ).compare(
    should.have.property('x').that.equals(5)
    (it)-> expect(it).to.have.property('x').that.equals(5)
  ).compare(
    should.have.property('x').that.not.equals(5)
    (it)-> expect(it).to.have.property('x').that.not.equals(5)
  ).compare(
    should.have.property('x').with.keys('y')
    (it)-> expect(it).to.have.property('x').with.keys('y')
  ).compare(
    should.have.property('x').not.with.keys('y')
    (it)-> expect(it).to.have.property('x').not.with.keys('y')
  )
