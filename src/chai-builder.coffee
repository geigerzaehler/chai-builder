((global, factory)->
  if typeof module == 'object' && typeof require == 'function'
    module.exports = factory()
  else
    factory()
) this, (chai)->

  # Adds the `chai.should` property and registers all chai language
  # properties.
  #
  # We call `should` an *expectation*.
  #
  # Every property that is defined on `chai.Assertion` is available on
  # an expectation. Retrieving such a property will yield a new
  # expectation and record the property name.
  #
  #     should.be.defined.and.true
  #
  # The property can also be called as a method, in which case it
  # again returns an expectation and records the arguments.
  #
  #     should.be.defined.and.equal(2).and.not.equal(4)
  #
  # Expectations are immutable and can be passed around easily. For
  # example the following does not yield a contradiction
  #
  #     base = should.be.defined
  #     base.and.equal(2).test(2)
  #     base.and.equal(4).test(4)
  #
  use = (chai, utils)->

    {Assertion} = chai

    # List of chai language property names
    chaiProperties = Object.getOwnPropertyNames(Assertion.prototype)

    expectationProto = Object.create(null)

    # Create properties that record the accessed name in the
    # expectation.
    each chaiProperties, (name)->
      Object.defineProperty expectationProto, name, get: chain(name)

    # Create and run a chai assertion for the target that is equivalent
    # to `expectation`.
    testExpectation = (target, expectation)->
      propertyChain = expectation._chain.slice()
      assertion = new Assertion(target)
      while prop = propertyChain.pop()
        {name, callArgs} = prop
        receiver = assertion
        assertion = assertion[name]
        if callArgs
          assertion = assertion.apply(receiver, callArgs)


    # Add the `test` method to the `expectation` prototype.
    expectationProto.test = (target)->
      testExpectation(target, this)

    chai.should = Object.create(expectationProto)
    chai.should.label = 'should'


  # Create a getter method that returns a copy of the receiver and adds
  # its name to the front of the `_chain` property.
  #
  #   chain(name).call(obj)._chain[0].name == name
  #
  # You can call the returned copy as a method. This will again return
  # a copy with the arguments of the call recorded.
  #
  #   chain(name).call(obj).call(obj, x)._chain[0].callArgs == [x]
  #
  chain = (name)-> ->

    # The object that the getter returns.
    #
    # Must be a function so that we can use it as a method.
    next = (args...)->
      next._chain[0].callArgs = args
      next.label += ' ' + args.join(' ')
      return next
    next.__proto__ = Object.create(this)
    next._chain = (this._chain || []).slice()
    next._chain.unshift({name})
    next.label += ' ' + name
    return next

  each = (array, iterator)->
    iterator(val) for val in array

  return use
