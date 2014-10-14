First Class Expectations
========================

A [chai][] plugin to separate expectations from the the values they are tested on.

```javascript
var expect = require('chai').expect;
var should = require('chai-buider/use');

var expectation = should.equal(4);
expectation.test(4);
expect(4).to.equal(4);
```

This example shows the correspondence beetween the `expect` syntax and
`should` builder syntax. This extends to all of chai’s language
properties—so in general the following are equivalent.

```javascript
should.a.b.c.test(target);
expect(target).a.b.c

should.a.b.f(x, y).test(target);
expect(target).a.b.f(x,y)
```

Expecation also have a `label` property that describes the expectation

```javascript
should.be.defined.and.equal(4).label
// -> 'should be defined and equal 4'
```

Use Cases
---------

Building custom expecations.

```javascript
var shouldHaveAddress =
  should.have.property('address')
        .as.an('object')
        .and.with.key('name')
var shouldHaveExtendedAddress = 
  shouldHaveAddress.with.key('street').and.key('city')

shouldHaveAddress.test({address: {name: 'Willy'}})
shouldHaveExtendedAddress.test({address: {
  name: 'Willy',
  street: 'Chocolate Lane',
  city: 'Tiny Town'
}})
```

Running labeled tests.

```javascript
function test(subject, expecations) {
  expectations.forEach(function(expectation)) {
    consol.log('test: ' + subject + expectation.label);
    expectation.test(subject);
  }
}
```

The plugin integrates nicely with [mocha-when-then][].

```coffeescript

shouldHaveAddress = should.have.property('address')
shouldHaveAddress.label = 'should have address'

Given 'person', {address: {name: 'Willy'}}
Then 'person', shouldHaveAddress.with.key('name')

When -> @person.address.street = 'Chocolate Lane'
And  -> @person.address.city = 'Tiny Town'
Then 'person', shouldHaveAdress.with.key('street')
And  'person', shouldHaveAdress.with.key('city')
```

This creates the following test lables

```
person should have address with key name
person should have address with key street
person should have address with key city
```

[chai]: http://chaijs.com/
[mocha-when-then]: https://github.com/geigerzaehler/mocha-when-then
