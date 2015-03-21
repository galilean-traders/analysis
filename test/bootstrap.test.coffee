global.new_user = {
    email: "pasticciacci@obrutto.divia.merulana"
    password: "ciarpame"
    oanda_token: "885ac2b8ad30d2292610ecb707431155-32bf7c56bb3db61696674160b00fa68c"
    account_type: "practice"
    account_id: "7905739"
}

global.token = undefined

before (done) ->
    this.timeout 0
    Sails.lift {log: {level: "error"}}, (error, server) ->
        sails = server
        if error?
            return done(error)
        # create a user before testing the controllers
        request sails.hooks.http.app
            .post "/api/user/create"
            .send new_user
            .expect (res) ->
                global.token = res.body.token
                return
            .end ->
                done(error, sails)

after (done) ->
    # delete the user after the tests
    request sails.hooks.http.app
        .delete "/api/user/delete"
        .set "access-token", global.token
        .expect 200
        .end ->
            sails.lower(done)
