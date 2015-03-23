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
                    precision: 5 # how many decimal places
                    side: "sell"
                }
                .expect 'Content-Type', /json/
                .expect (res) ->
                    parsed = JSON.parse res.body
                    console.log parsed
                    if "code" in parsed 
                        if parsed.code is 24
                            # instrument trading is halted, cannot go on with
                            # the test
                            return "instrument trading halted on oanda, try during open market hours: http://fxtrade.oanda.com/help/policies/weekend-exposure-limits"
                        else
                            return "#{parsed.code}, #{parsed.message}"
                    parsed.should.have.property "instrument"
                        .that.equals "EUR_USD"
                    parsed.should.have.property "time"
                    parsed.should.have.property "price"
                    parsed.should.have.property "tradeOpened"
                    parsed.tradeOpened.should.have.property "side"
                        .that.equals "sell"
                    parsed.tradeOpened.should.have.property "id"
                    parsed.tradeOpened.should.have.property "takeProfit"
                    parsed.tradeOpened.should.have.property "stopLoss"
                    parsed.tradeOpened.should.have.property "trailingStop"
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
                    precision: 5 # how many decimal places
                    side: "buy"
                }
                .expect 'Content-Type', /json/
                .expect (res) ->
                    parsed = JSON.parse res.body
                    console.log parsed
                    if "code" in parsed 
                        if parsed.code is 24
                            # instrument trading is halted, cannot go on with
                            # the test
                            return "instrument trading halted on oanda, try during open market hours: http://fxtrade.oanda.com/help/policies/weekend-exposure-limits"
                        else
                            return "#{parsed.code}, #{parsed.message}"
                    parsed.should.have.property "instrument"
                        .that.equals "EUR_USD"
                    parsed.should.have.property "time"
                    parsed.should.have.property "price"
                    parsed.should.have.property "tradeOpened"
                    parsed.tradeOpened.should.have.property "side"
                        .that.equals "buy"
                    parsed.tradeOpened.should.have.property "id"
                    parsed.tradeOpened.should.have.property "takeProfit"
                    parsed.tradeOpened.should.have.property "stopLoss"
                    parsed.tradeOpened.should.have.property "trailingStop"
                    return
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
