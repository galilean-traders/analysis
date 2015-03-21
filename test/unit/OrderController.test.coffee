describe "OrderController and TradeController", ->

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
