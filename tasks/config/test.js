module.exports = function(grunt) {

    grunt.config.set('mochaTest', {
        test: {
            options: {
                reporter: 'spec',
                quiet: false, // Optionally suppress output to standard out (defaults to false) 
                require: ["coffee-script/register", "test/requires.coffee"],
                clearRequireCache: false // Optionally clear the require cache before running tests (defaults to false) 
            },
            src: ['test/bootstrap.test.coffee', 'test/**/*.coffee']
        }
    });

    // Add the grunt-mocha-test tasks. 
    grunt.loadNpmTasks('grunt-mocha-test');
};
