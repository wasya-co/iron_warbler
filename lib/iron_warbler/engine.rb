module IronWarbler; end
module Iro; end

class IronWarbler::Engine < ::Rails::Engine
  isolate_namespace Iro
  isolate_namespace IronWarbler
end

