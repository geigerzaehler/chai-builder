var chai = require('chai');
var builder = require('./index.js');
chai.use(builder);
module.exports = chai.should;
