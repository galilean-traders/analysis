chai = require "chai"
chai.config.includeStack = true
should = chai.should()

describe "User", ->

    new_user = {
        auth:
            email: "pasticciaccio@brutt.divia.merulana"
            password: "ciarpame"
        oanda_token: "885ac2b8ad30d2292610ecb707431155-32bf7c56bb3db61696674160b00fa68c"
        account_type: "practice"
        account_id: "7905739"
    }

    describe "#create()", ->
        it "should check the create function", (done) ->
            User.create new_user
                .then (user) ->
                    should.exist user
                    user.should
                        .have.property "oanda_token"
                        .that.equals new_user.oanda_token
                    user.should
                        .have.property "account_type"
                        .that.equals new_user.account_type
                    user.should
                        .have.property "account_id"
                        .that.equals new_user.account_id
                    user.should.have.property "auth"
                    done()
                .catch done

    describe "#find()", ->
        it "should check the find function", (done) ->
            User.find().limit(1)
                .then (results) ->
                    results.should.have.length 1
                    done()
                .catch done

    describe "#update()", ->
        auth = undefined
        before (done) ->
            Auth.findOne(email: new_user.auth.email)
                .then (_auth) ->
                    auth = _auth
                    done()
                .catch done

        it "should update the account type", (done) ->
            User.update({id: auth.user}, {account_type: "sandbox"})
                .then (user) ->
                    user.should.have.length 1
                    user[0].account_type.should.equal "sandbox"
                    done()
                .catch done

        it "should update the email", (done) ->
            User.update({id: auth.user}, {email: "another@mail.com"})
                .then (user) ->
                    user.should.have.length 1
                    Auth.findOne user[0].auth
                        .then (updated_auth) ->
                            updated_auth.should.have.property "email"
                                .that.equals "another@mail.com"
                            done()
                        .catch done
                .catch done

        it "should update the password", (done) ->
            User.update({id: auth.user}, {password: "passauord"})
                .then (user) ->
                    user.should.have.length 1
                    Auth.findOne user[0].auth
                        .then (updated_auth) ->
                            updated_auth.should.have.property "password"
                                .that.not.equals auth.password
                            done()
                        .catch done
                .catch done

    describe "#destroy()", ->
        it "should check the destroy function", (done) ->
            Auth.findOne(email: new_user.auth.email)
                .then (auth) ->
                    User.destroy auth.user
                        .then (user) ->
                            User.find(user)
                                .then (dead_user) ->
                                    dead_user.should.be.empty
                                    done()
                                .catch done
                        .catch done
                .catch done
