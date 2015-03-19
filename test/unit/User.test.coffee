describe "User model", ->

    describe "#find()", ->
        it "should check the find function", (done) ->
            User.find()
                .then (results) ->
                    console.log results
                    done()
                .catch done

    describe "#create()", ->
        it "should check the create function", (done) ->
            User.create({
                email: "pasticciaccio@brutto.com"
                password: "ciarpame"
                oanda_token: '885ac2b8ad30d2292610ecb707431155-32bf7c56bb3db61696674160b00fa68c'
                account_type: 'practice'
                account_id: '7905739'
            })
                .exec (err, results) ->
                    if err?
                        console.error err
                        throw err
                    console.log results
                    done()
