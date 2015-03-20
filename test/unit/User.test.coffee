describe "User model", ->

    new_user = {
        auth:
            email: "pasticciaccio@brutto.divia.merulana"
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
                    done()

    describe "#find()", ->
        it "should check the find function", (done) ->
            User.find()
                .then (results) ->
                    done()
                .catch done

    describe "#update()", ->
        it "should check the update function", (done) ->
            User.find().limit(1)
                .then (user) ->
                    User.update({id: user.id}, {account_type: "sandbox"})
                        .then (results) ->
                            done()
                        .catch done
                .catch done

    describe "#destroy()", ->
        it "should check the destroy function", (done) ->
            Auth.findOne(email: new_user.auth.email)
                .exec (error, auth) ->
                    User.destroy auth.user
                        .exec (error, user) ->
                            if error?
                                throw error
                            else
                                done()
