var passport = require('passport'),
LocalStrategy = require('passport-local').Strategy,
bcrypt = require('bcrypt');

passport.serializeUser(function(user, done) {
    done(null, user.id);
});

passport.deserializeUser(function(id, done) {
    User.findById(id, function(err, user) {
        done(err, user);
    });
});

passport.use(new LocalStrategy({
    usernameField: 'username',
    passwordField: 'password'
},
function(username, password, done) {
    User.findOne({ username: username }).exec(function(err, user) {
        if(err) { return done(err); }
        if(!user) { return done(null, false, { message: 'Unknown user ' + username }); }
        bcrypt.compare(password, user.password, function(err, res) {
            if(!res) return done(null, false, {message: 'Invalid Password'});
            return done(null, user);
        });
    });
}
));
