'use strict';

/**
 * This is trash, post-install hook does the aliasing
 */
module.exports = {
  additionalModulePaths: [ 'app-js' ],
  webpackAliases: {
    // '$src': 'app-js',
  },
  jestAliases: {
    '^src/(.*)$': '<rootDir>/app-js/$1',
  },
}
