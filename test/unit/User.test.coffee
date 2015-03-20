describe "User model", ->

    new_user = {
        auth:
            email: "paticiacio@bruttodiva.mierulana"
            password: "ciarpame"
        oanda_token: "885ac2b8ad30d2292610ecb707431155-32bf7c56bb3db61696674160b00fa68c"
        account_type: "practice"
        account_id: "7905739"
    }

    describe "#create()", ->
        it "should check the create function", (done) ->
            User.create new_user
                .exec (err, user) ->
                    if err?
                        console.error err
                        throw err
                    console.log user
                    done()

    describe "#find()", ->
        it "should check the find function", (done) ->
            Auth.find()
                .then (results) ->
                    console.log results
                .catch done
            User.find()
                .then (results) ->
                    console.log results
                    done()
                .catch done

    describe "#destroy()", ->
        it "should check the destroy function", (done) ->
            Auth.findOne(email: new_user.auth.email)
                .then (auth) ->
                    User.findOne(auth.user).then (user) ->
                        console.log user
                        user.destroy()
                        done()
                .catch done
