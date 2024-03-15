module Iro::ApplicationHelper

  def pp_delta delta
    '%.2f' % delta rescue '-'
  end

end
