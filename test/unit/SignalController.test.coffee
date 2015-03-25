describe "SignalController", ->

    describe "signals", ->
        rawdata = undefined
        invalid_data = ["crap", 0.24]

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

        #it "should get an error with invalid data", (done) ->
            #request sails.hooks.http.app
                #.post "/api/signal/ema5ema10"
                #.set "access-token", token
                #.send invalid_data
                #.expect 'Content-Type', /json/
                #.expect 500, done

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
