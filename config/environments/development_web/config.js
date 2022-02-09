
module.exports = {
  "apiOrigin": "http://localhost:3001",
  // "apiOrigin": "https://manager.piousbox.com",

  "appIndexPath": "src/index", // @TODO: remove?

  "domain": "tgm.piousbox.com", // required! 20210831

  // "debug": true,
  "debug": false,

  // "homeLocation": "/en/locations/show/threev1",
  // "homeLocation": "/en/locations/show/earth",
  "homeLocation": "/en/locations/show/construct0",

  "requireLogin": false,

  routes: {
    loginWithPasswordPath: "/api/users/login.json",
  },
};
