
module Iro; end
module IronWarbler; end

class IronWarbler::Engine < ::Rails::Engine
  isolate_namespace Iro
  isolate_namespace IronWarbler
end

