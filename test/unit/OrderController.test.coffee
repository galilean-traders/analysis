describe "OrderController and TradeController", ->

    describe "order and trade lifecycle", ->

        buy_trade_id = undefined
        sell_trade_id = undefined

        it "should place a new sell order sized at 2% of the current balance", (done) ->
            this.timeout 6000
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
                    sell_trade_id = parsed.tradeOpened.id
                    return
                .expect 200, done

        it "should place a new buy order sized at 2% of the current balance", (done) ->
            this.timeout 6000
            request sails.hooks.http.app
                .post "/api/order/create"
                .set "access-token", token
                .send {
                    instrument: "EUR_CHF"
                    adr: 105
                    pip: 0.0001
                    precision: 5 # how many decimal places
                    side: "buy"
                }
                .expect 'Content-Type', /json/
                .expect (res) ->
                    parsed = JSON.parse res.body
                    if "code" in parsed 
                        if parsed.code is 24
                            # instrument trading is halted, cannot go on with
                            # the test
                            return "instrument trading halted on oanda, try during open market hours: http://fxtrade.oanda.com/help/policies/weekend-exposure-limits"
                        else
                            return "#{parsed.code}, #{parsed.message}"
                    parsed.should.have.property "instrument"
                        .that.equals "EUR_CHF"
                    parsed.should.have.property "time"
                    parsed.should.have.property "price"
                    parsed.should.have.property "tradeOpened"
                    parsed.tradeOpened.should.have.property "side"
                        .that.equals "buy"
                    parsed.tradeOpened.should.have.property "id"
                    parsed.tradeOpened.should.have.property "takeProfit"
                    parsed.tradeOpened.should.have.property "stopLoss"
                    parsed.tradeOpened.should.have.property "trailingStop"
                    buy_trade_id = parsed.tradeOpened.id
                    return
                .expect 200, done

        it "should get the two open trades", (done) ->
            request sails.hooks.http.app
                .get "/api/trade/index"
                .set "access-token", token
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.be.an "array"
                    res.body
                        .filter (d) -> d.id is buy_trade_id
                        .should.not.be.empty
                    res.body
                        .filter (d) -> d.id is sell_trade_id
                        .should.not.be.empty
                    return
                .expect 200, done

        it "should delete the sell trade", (done) ->
            request sails.hooks.http.app
                .delete "/api/trade/delete"
                .set "access-token", token
                .send {trade_id: sell_trade_id}
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.have.property "id"
                    res.body.should.have.property "price"
                    res.body.should.have.property "instrument"
                        .that.equals "EUR_USD"
                    res.body.should.have.property "profit"
                    res.body.should.have.property "side"
                        .that.equals "sell"
                    res.body.should.have.property "time"
                    return
                .expect 200, done

        it "should delete the buy trade", (done) ->
            request sails.hooks.http.app
                .delete "/api/trade/delete"
                .set "access-token", token
                .send {trade_id: buy_trade_id}
                .expect 'Content-Type', /json/
                .expect (res) ->
                    res.body.should.have.property "id"
                    res.body.should.have.property "price"
                    res.body.should.have.property "instrument"
                        .that.equals "EUR_CHF"
                    res.body.should.have.property "profit"
                    res.body.should.have.property "side"
                        .that.equals "buy"
                    res.body.should.have.property "time"
                    return
                .expect 200, done
