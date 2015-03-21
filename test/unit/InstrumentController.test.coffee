request = require "supertest"
chai = require "chai"
chai.config.includeStack = true
should = chai.should()

describe "InstrumentController", ->

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
    
    describe "#index()", ->
        it "should get a list of instruments", (done) ->
            request sails.hooks.http.app
                .get "/api/instrument/index"
                .set "access-token", token
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.be.an "array"
                    return
                .expect 200, done

        it "should make multiple requests without exceeding the oanda limit", (done) ->
            this.timeout 6000
            request sails.hooks.http.app
                .get "/api/instrument/index"
                .set "access-token", token
                .expect 200
                .end ->
                    request sails.hooks.http.app
                        .get "/api/instrument/index"
                        .set "access-token", token
                        .expect 200
                        .end ->
                            request sails.hooks.http.app
                                .get "/api/instrument/index"
                                .set "access-token", token
                                .expect 200
                                .end ->
                                    request sails.hooks.http.app
                                        .get "/api/instrument/index"
                                        .set "access-token", token
                                        .expect 200, done

    describe "#rawdata()", ->
        it "should get EUR_USD rawdata", (done) ->
            request sails.hooks.http.app
                .get "/api/instrument/rawdata?name=EUR_USD&count=15&granularity=M5"
                .set "access-token", token
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.be.an "array"
                        .with.length 15
                    res.body[0].should.have.property "time"
                    res.body[0].should.have.property "openMid"
                    res.body[0].should.have.property "highMid"
                    res.body[0].should.have.property "lowMid"
                    res.body[0].should.have.property "closeMid"
                    res.body[0].should.have.property "complete"
                    res.body[0].should.have.property "volume"
                    return
                .expect 200, done

    describe "statistical functions", ->
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

        it "should get ema5", (done) ->
            request sails.hooks.http.app
                .post "/api/instrument/ema5"
                .set "access-token", token
                .send rawdata
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should get ema10", (done) ->
            request sails.hooks.http.app
                .post "/api/instrument/ema10"
                .set "access-token", token
                .send rawdata
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should get stoch", (done) ->
            request sails.hooks.http.app
                .post "/api/instrument/stoch"
                .set "access-token", token
                .send rawdata
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should get rsi", (done) ->
            request sails.hooks.http.app
                .post "/api/instrument/rsi"
                .set "access-token", token
                .send rawdata
                .expect 'Content-Type', /json/
                .expect 200, done

        it "should get adr", (done) ->
            request sails.hooks.http.app
                .post "/api/instrument/adr"
                .set "access-token", token
                .send {candles: rawdata, pip: 0.0001}
                .expect 'Content-Type', /json/
                .expect 200, done
