((global, factory)->
  if typeof module == 'object' && typeof require == 'function'
    module.exports = factory()
  if typeof define == 'function' && define.amd
    define(factory)
  else
    global.mochaBuilder = factory()
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


    class Expectation
      constructor: ->
        @label = 'should'
        @_chain = []

      # Create and run a chai assertion for the target that is
      # equivalent to the expectation.
      test: (target)->
        propertyChain = this._chain.slice()
        assertion = new Assertion(target)
        while prop = propertyChain.pop()
          {name, callArgs} = prop
          receiver = assertion
          assertion = assertion[name]
          if callArgs
            assertion = assertion.apply(receiver, callArgs)


    assertionPropertyNames = Object.getOwnPropertyNames(Assertion.prototype)
    assertionChainableMethods = Object.keys(Assertion.prototype.__methods)

    # Extend the Expectation prototype with chai language properties
    assertionPropertyNames.forEach (name)->
      if assertionChainableMethods.indexOf(name) >= 0
        Object.defineProperty Expectation.prototype, name, get: ->
          next = (callArgs...)->
            chainCall(this, name, callArgs)
          next.__proto__ = chainProperty(this, name)
          return next
        return

      descriptor = Object.getOwnPropertyDescriptor(Assertion.prototype, name)
      if typeof descriptor.value == 'function'
        Expectation.prototype[name] = (callArgs...)->
          chainCall(this, name, callArgs)
      else if typeof descriptor.get == 'function'
        Object.defineProperty Expectation.prototype, name, get: ->
          chainProperty(this, name)


    chai.should = new Expectation


    # Utilities

    chainProperty = (base, name)->
      next = new Expectation
      next._chain = base._chain.slice()
      next._chain.unshift({name})
      next.label = base.label + ' ' + name
      return next

    chainCall = (base, methodName, callArgs)->
      next = new Expectation
      next._chain = base._chain.slice()
      next._chain.unshift({name: methodName, callArgs})
      next.label = base.label + ' ' + methodName + ' ' + callArgs.join(' ')
      return next
