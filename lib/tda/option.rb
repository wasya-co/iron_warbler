require 'httparty'

##
## From: https://developer.tdameritrade.com/option-chains/apis/get/marketdata/chains
## FVRR_082021P200
##
class ::Tda::Option
  include ::HTTParty
  base_uri 'https://api.tdameritrade.com'

  ## opts: contractType, strike, date, ticker
  ##
  ## ow = { contractType: 'PUT', ticker: 'GME', date: '2022-12-09' }
  ## out = IronWarbler::Ameritrade::Api.get_option( ow )
  ## query = {:apikey=>"0SMJXXBLWNAMRMK1ZSCFQG2Z7DAN87FS", :toDate=>"2022-12-09", :fromDate=>"2022-12-09", :symbol=>"GME"}
  ##
  def self.get_options _opts
    puts! _opts, '#get_option'
    opts = {}

    #
    # Validate input ???
    #
    validOpts = %i| contractType |
    validOpts.each do |s|
      if _opts[s]
        opts[s] = _opts[s]
      else
        raise Iwa::InputError.new("Invalid input, missing '#{s}'.")
      end
    end
    if _opts[:expirationDate]
      opts[:fromDate] = opts[:toDate] = _opts[:expirationDate]
    else
      raise Iwa::InputError.new("Invalid input, missing 'date'.")
    end
    if _opts[:ticker]
      opts[:symbol] = _opts[:ticker].upcase
    else
      raise Iwa::InputError.new("Invalid input, missing 'ticker'.")
    end

    query = { apikey: ::TD_AME[:apiKey] }.merge opts
    puts! query, 'input opts'

    path = "/v1/marketdata/chains"
    out = self.get path, { query: query }
    timestamp = DateTime.parse out.headers['date']
    ## out = HTTParty.get "https://api.tdameritrade.com#{path}", { query: query }
    out = out.parsed_response.deep_symbolize_keys


    tmp_sym = "#{opts[:contractType].to_s.downcase}ExpDateMap".to_sym
    outs = []
    out = out[tmp_sym]
    out.each do |date, vs|
      vs.each do |strike, _v|
        v = _v[0]
        v = v.except( :lastSize, :optionDeliverablesList, :settlementType,
          :deliverableNote, :pennyPilot, :mini )
        v[:timestamp] = timestamp
        outs.push( v )
      end
    end

    outs.each do |x|
      opi = Iwa::OptionPriceItem.create( x )
      if !opi.persisted?
        puts! opi.errors.full_messages, "Cannot create OptionPriceItem"
      end
    end

    return outs
  end


  ##
  ## _vp_ 2022-11-30
  ##
  def self.get_options_TRASH _opts
    puts! _opts, '#get_options'

    opts = { symbol: _opts[:ticker] }
    query = { apikey: ::TD_AME[:apiKey] }.merge opts
    path = "/v1/marketdata/chains"
    outs = self.get path, { query: query }
    outs = outs.parsed_response # .deep_symbolize_keys
    %w| putExpDateMap callExpDateMap |.each do |exp_date_map|
      outs[exp_date_map].each do |k, vs|
        date = k.split(':')[0]
        puts "#{date} "

        vs.each do |strike, _hash|
          _hash = _hash[0]

          opi_attrs = _hash.select { |_k, _v| %w|
            putCall symbol bid ask last mark
            quoteTimeInLong
            volatility delta gamma theta
            openInterest timevalue
          |.include?(_k) }
          opi_attrs[:timestamp] = Time.at(opi_attrs['quoteTimeInLong']/1000)
          opi_attrs[:interval] = _opts[:interval]

          opi_attrs = opi_attrs.select { |k, v| v != 'NaN' }

          opi = Iwa::OptionPriceItem.create opi_attrs
          if opi.persisted?
            print '.'
          else
            puts! opi.errors.full_messages, "Cannot create OptionPriceItem"
          end
        end
      end
    end
  end

  def self.all
    return ::Tda::OptionCriteria.new()
  end


end

