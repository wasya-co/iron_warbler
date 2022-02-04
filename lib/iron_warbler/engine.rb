
module IronWarbler
  class Engine < ::Rails::Engine
    isolate_namespace IronWarbler

    initializer "iron_warbler.assets.precompile" do |app|
      app.config.assets.precompile << %w( iron_warbler/application.js iron_warbler/application.css iron_warbler/application.scss )
      # app.config.assets.precompile << %w( iron_warbler/materialize.js iron_warbler/materialize.css )
    end
  end
end
