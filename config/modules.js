'use strict';

module.exports = {
  additionalModulePaths: [ 'app-js' ],
  webpackAliases: {
    // '$src': 'app-js',
  },
  jestAliases: {
    '^src/(.*)$': '<rootDir>/app-js/$1',
  },
}