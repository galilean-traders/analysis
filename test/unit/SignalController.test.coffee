request = require "supertest"
chai = require "chai"
chai.config.includeStack = true
should = chai.should()

describe "SignalController", ->

    new_user = {
        email: "pasticciacci@obrutto.divia.merulana"
        password: "ciarpame"
        oanda_token: "885ac2b8ad30d2292610ecb707431155-32bf7c56bb3db61696674160b00fa68c"
        account_type: "practice"
        account_id: "7905739"
    }

    token = undefined

    before (done) ->
        # create the user before testing the controller
        request sails.hooks.http.app
            .post "/api/user/create"
            .send new_user
            .expect (res) ->
                token = res.body.token
                return
            .expect 200, done

    after (done) ->
        # delete the user after the tests
        request sails.hooks.http.app
            .delete "/api/user/delete"
            .set "access-token", token
            .expect 200, done
    
    describe "signals", ->
        rawdata = undefined

        this.timeout 6000
        before (done) ->
            # get the raw data
            request sails.hooks.http.app
                .get "/api/instrument/rawdata?name=EUR_USD&count=20&granularity=M5"
                .set "access-token", token
                .expect (res) ->
                    rawdata = res.body
                    return
                .expect 200, done

        it "should get ema5ema10", (done) ->
            request sails.hooks.http.app
                .post "/api/signal/ema5ema10"
                .set "access-token", token
                .send rawdata
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should get rsi", (done) ->
            request sails.hooks.http.app
                .post "/api/signal/rsi"
                .set "access-token", token
                .send rawdata
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should get adr", (done) ->
            request sails.hooks.http.app
                .post "/api/signal/adr"
                .set "access-token", token
                .send {candles: rawdata, pip: 0.0001}
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should get stoch", (done) ->
            request sails.hooks.http.app
                .post "/api/signal/stoch"
                .set "access-token", token
                .send rawdata
                .expect 'Content-Type', /json/
                .expect 200, done
