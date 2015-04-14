var Sails = require("sails");

module.exports = function(grunt) {
    grunt.registerTask('seed', function() {
        done = this.async();
        Sails.lift({log: {level: "error"}}, function(error, server) {
            var sails = server;
            if (error) {
                done(error);
            }
            var statuses = ["buy", "sell", "false"]
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

            var attempts = []
            params.favorites.forEach(function(instrument) {
                var d = new Date("October 13, 1981 8:00:00");
                var adr = Math.random() < 0.5? true: false
                while (d < new Date("October 13, 1981 20:00:00")) {
                    var attempt = {
                        time: d,
                        instrument: instrument,
                        adr: adr,
                        stoch: statuses[Math.floor(Math.random() * 3)],
                        rsi: statuses[Math.floor(Math.random() * 3)],
                        ema5ema10: statuses[Math.floor(Math.random() * 3)],
                    }
                    var status = attempt.adr && attempt.ema5ema10 != "false" && attempt.ema5ema10 == attempt.rsi && attempt.rsi == attempt.stoch;
                    attempt.status = status? attempt.ema5ema10: "false";
                    attempts.push(attempt);
                    d = new Date(d.getTime() + 5 * 60 * 1000) // add 5 minutes
                }
            });

            function createAttempts(user) {
                console.log("user", user);
                return TradeAttempt.destroy({
                    user: user.id,
                    time: {
                        ">": new Date("October 13, 1981"),
                        "<": new Date("October 14, 1981")
                    }
                })
                    .then(function(destroyed_attempts) {
                        console.log("destroyed", destroyed_attempts.length);
                        attempts = attempts.map(function(attempt) {
                            attempt.user = user.id
                            return attempt
                        });
                        return TradeAttempt.create(attempts).then(function(created_attempts) {
                            console.log("created", created_attempts.length);
                        });
                    });
            }

            Auth.findOne({email: params.auth.email}).then(function(auth) {
                if (auth) {
                    User.findOne({id: auth.user})
                    .then(createAttempts)
                    .then(done);
                }
                else {
                    User.create(params)
                    .then(createAttempts)
                    .then(done);
                }
            }
                                                         )
            .catch(done);
        });
    }
    );
};
