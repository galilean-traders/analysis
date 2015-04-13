var Sails = require("sails");

module.exports = function(grunt) {
    grunt.registerTask('seed', function() {
        done = this.async();
        Sails.lift({log: {level: "error"}}, function(error, server) {
            var sails = server;
            if (error) {
                done(error);
            }
            var params = {
                auth: {
                    email: "fxprova2@ciccio.it",
                    password: "ciarpame",
                },
                oanda_token: "885ac2b8ad30d2292610ecb707431155-32bf7c56bb3db61696674160b00fa68c",
                account_type: "practice",
                account_id: "4827510",
                favorites: [
                    'AUD_CAD',
                    'AUD_CHF',
                    'EUR_GBP',
                    'EUR_HKD',
                    'EUR_JPY',
                    'EUR_NOK',
                    'EUR_USD',
                    'EUR_SEK',
                    'USD_CAD',
                    'USD_CHF',
                    'USD_CNH',
                    'USD_SEK',
                    'USD_SGD'
                ],
                };
            Auth.findOne({email: params.auth.email}).then(function(auth) {
                if (auth) {
                    User.findOne({id: auth.user}).then(function(user) {
                        console.log(user);
                        done();
                    });
                }
                else {
                    User.create(params).then(function(user) {
                        console.log(user);
                        done();
                    })
                }
            })
            .catch(function(error) { done(error); });
        });
    }
    );
};
