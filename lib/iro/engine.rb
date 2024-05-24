
module Iro; end
module Tda; end

class Iro::Engine < ::Rails::Engine
  isolate_namespace Iro
end

class Iro::InputError < StandardError
end
