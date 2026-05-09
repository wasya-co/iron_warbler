
Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w(
  wco/application.js
  wco/application.css

  iron_warbler/application.js
  iron_warbler/application.css

  builds/app.js
);
