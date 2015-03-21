request = require "supertest"
chai = require "chai"
chai.config.includeStack = true
should = chai.should()

describe "OrderController and TradeController", ->

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
    
    describe "#create()", ->

        it "should place a new sell order sized at 2% of the current balance", (done) ->
            request sails.hooks.http.app
                .post "/api/order/create"
                .set "access-token", token
                .send {
                    instrument: "EUR_USD"
                    adr: 105
                    pip: 0.0001
                    side: "sell"
                }
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.have.property "id"
                    res.body.should.have.property "instrument"
                        .that.equals "EUR_USD"
                    res.body.should.have.property "side"
                        .that.equals "sell"
                    res.body.should.have.property "type"
                        .that.equals "market"
                    res.body.should.have.property "time"
                    res.body.should.have.property "takeProfit"
                    res.body.should.have.property "stopLoss"
                    res.body.should.have.property "trailingStop"
                    return
                .expect 200, done

        it "should place a new buy order sized at 2% of the current balance", (done) ->
            request sails.hooks.http.app
                .post "/api/order/create"
                .set "access-token", token
                .send {
                    instrument: "EUR_USD"
                    adr: 105
                    pip: 0.0001
                    side: "buy"
                }
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.have.property "id"
                    res.body.should.have.property "instrument"
                        .that.equals "EUR_USD"
                    res.body.should.have.property "buy"
                        .that.equals "sell"
                    res.body.should.have.property "type"
                        .that.equals "market"
                    res.body.should.have.property "time"
                    res.body.should.have.property "takeProfit"
                    res.body.should.have.property "stopLoss"
                    res.body.should.have.property "trailingStop"
                .expect 200, done

    describe "#index()", ->

        it "should get the two previous orders", (done) ->
            request sails.hooks.http.app
                .get "/api/trade/index"
                .set "access-token", token
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.be.an "array"
                        .with.length 2
                    return
                .expect 200, done
