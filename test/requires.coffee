global.chai = require "chai"
global.chai.config.includeStack = true
global.should = chai.should()
global.Sails = require "sails"
global.request = require "supertest"
