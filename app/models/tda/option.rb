
require 'httparty'

class Tda::Option

  include ::HTTParty
  base_uri 'https://api.tdameritrade.com'


  ##
  ## 2023-02-05 _vp_ :: Gets the entire chain
  ##
  def self.get_chain params
    opts = { symbol: params[:ticker] } ## use 'GME' as symbol here even though a symbol is eg 'GME_021023P2.5'
    query = { apikey: ::TD_AMERITRADE[:apiKey] }.merge opts
    puts! query, 'input opts'

    path = "/v1/marketdata/chains"
    out = self.get path, { query: query }
    timestamp = DateTime.parse out.headers['date']
    out = out.parsed_response.deep_symbolize_keys


    outs = []
    %w| put call |.each do |contractType|
      tmp_sym = "#{contractType}ExpDateMap".to_sym
      _out = out[tmp_sym]
      _out.each do |date, vs| ## date="2023-02-10:5"
        vs.each do |strike, _v| ## strike="18.5"
          v = _v[0] ## v={} many attrs
          v = v.except( :lastSize, :optionDeliverablesList, :settlementType,
            :deliverableNote, :pennyPilot, :mini )
          v.each do |k, i|
            if i == 'NaN'
              v[k] = nil
            end
          end

          v[:timestamp] = timestamp
          v[:ticker] = params[:ticker]
          outs.push( v )
        end
      end
    end

    outs.each do |x|
      opi = ::Iro::OptionPriceItem.create( x )
      if !opi.persisted?
        puts! opi.errors.full_messages, "Cannot create OptionPriceItem"
      end
    end
  end

  ##
  ## 2023-03-18 _vp_ This is what I should be using to check if a position should be rolled.
  ##
  def self.get_quote params
    OpenStruct.new ::Tda::Option.get_quotes(params)[0]
  end

  ##
  ## params: contractType, strike, expirationDate, ticker
  ##
  ## ow = { contractType: 'PUT', ticker: 'GME', date: '2022-12-09' }
  ## query = {:apikey=>"<>", :toDate=>"2022-12-09", :fromDate=>"2022-12-09", :symbol=>"GME"}
  ##
  ## 2023-02-04 _vp_ :: Too specific, but I want the entire chain, every 1-min
  ## 2023-02-06 _vp_ :: Continue.
  ##
  def self.get_quotes params
    # puts! params, 'Tda::Option#get_quotes'
    opts = {}

    #
    # Validate input ???
    #
    validOpts = %i| contractType |
    validOpts.each do |s|
      if params[s]
        opts[s] = params[s]
      else
        raise Iro::InputError.new("Invalid input, missing '#{s}'.")
      end
    end
    if params[:expirationDate]
      opts[:fromDate] = opts[:toDate] = params[:expirationDate]
    else
      raise Iro::InputError.new("Invalid input, missing 'date'.")
    end
    if params[:ticker]
      opts[:symbol] = params[:ticker].upcase
    else
      raise Iro::InputError.new("Invalid input, missing 'ticker'.")
    end

    if params[:strike]
      opts[:strike] = params[:strike]
    end

    query = { apikey: ::TD_AMERITRADE[:apiKey] }.merge opts
    # puts! query, 'input opts'

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

    # puts! outs, 'outs'
    return outs
  end


end

=begin

outs = Tda::Option.get_quotes({
  contractType: 'CALL', strike: 20.0, expirationDate: '2024-01-12',
  ticker: 'GME',
})

=end
