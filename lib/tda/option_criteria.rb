
class Tda::OptionCriteria

  def initialize *args
    @opts = {}
    @filter_opts = []
    @sort_by = []
    return self
  end

  def where opts
    if String == opts.class
      opts = opts.strip.split

      if opts.length != 3
        raise '#where opts.length must be 3!'
      end
      @filter_opts.push( opts )

    else
      opts.each do |k, v|
        @opts[k] = v
      end

    end
    return self
  end

  ## This can only work with one sorting.
  def order_by h
    h.each do |k, v|
      @sort_by = [k, v.to_sym]
    end
    return self
  end

  def limit
    raise 'Tda::OptionCriteria#limit is not implemented - zz4'
  end

  def first
    out = Tda::Option.get_options(@opts)

    filter_opts = @filter_opts[0]
    out = out.select do |x|
      x[filter_opts[0].to_sym].send( filter_opts[1], filter_opts[2].to_f )
    end

    out = out.sort do |a, b|
      puts! a, 'a'
      puts! a[@sort_by[0]], 'more'

      t = @sort_by[1].to_sym == 'desc' ? '>' : '<='
      puts! t, 't'

      tt = b[@sort_by[0]]
      puts! tt, 'tt'

      return a[@sort_by[0]].send( t, tt )
    end

    out = out[0]
    out
  end


end
