request = require "supertest"
chai = require "chai"
chai.config.includeStack = true
should = chai.should()

describe "UserController and AuthController", ->

    new_user = {
        email: "pasticciacci@obrutto.divia.merulana"
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

    describe "#login()", ->
        it "should login", (done) ->
            request sails.hooks.http.app
                .post "/api/auth/login"
                .send new_user
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.have.property "token"
                    return
                .expect 200, done

    describe "#delete(), #update() and #findOne()", ->
        token = undefined
        before (done) ->
            request sails.hooks.http.app
                .post "/api/auth/login"
                .send new_user
                .end (error, res) ->
                    token = res.body.token
                    done()

        it "should update account type", (done) ->
            request sails.hooks.http.app
                .put "/api/user/update"
                .send {account_type: "sandbox"}
                .set "access-token", token
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should update email", (done) ->
            request sails.hooks.http.app
                .put "/api/user/update"
                .send {email: "se.vuol@ballare.signor.contino"}
                .set "access-token", token
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should update password", (done) ->
            request sails.hooks.http.app
                .put "/api/user/update"
                .send {password: "cicciopaffincio"}
                .set "access-token", token
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should delete user", (done) ->
            request sails.hooks.http.app
                .delete "/api/user/delete"
                .set "access-token", token
                .expect 'Content-Type', /json/
                .expect 200, done
