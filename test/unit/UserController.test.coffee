request = require "supertest"
chai = require "chai"
chai.config.includeStack = true
should = chai.should()

describe "UserController", ->

    new_user = {
        email: "pasticciaccio@brutto.divia.merulana"
        password: "ciarpame"
        oanda_token: "885ac2b8ad30d2292610ecb707431155-32bf7c56bb3db61696674160b00fa68c"
        account_type: "practice"
        account_id: "7905739"
    }
    
    describe "#create()", ->

        it "should create a user", (done) ->
            request sails.hooks.http.app
                .post "/api/user/create"
                .send new_user
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.have.property "token"
                    return
                .expect 200, done
