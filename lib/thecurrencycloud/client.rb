require 'thecurrencycloud'
require 'json'

module TheCurrencyCloud
  # Represents a client and associated functionality.
  class Client
    attr_reader :client_id, :token

    def initialize(client_id)
      @client_id = client_id
      @token = authenticate(client_id)
    end

    def prices_market(ccy_pair,options={})
      response = get "prices/market/#{ccy_pair.upcase}", options
      mash = Price.new(response)
      return mash.data
    end

    # Returns a list of trades
    def trades
      response = get "trades"
      mash = Trade.new(response)
      mash.data.collect{|d| Trade.new(d)}
    end

    # Executes a trade
    def trade_execute(options)
      response = post "trade/execute", options
      mash = Trade.new(response)
      return mash.data
    end

    # Close the session
    def close_session
      response = post "close_session"
      mash = Hashie::Mash.new(response)
      @token = nil
      return true
    end

    private

    def authenticate(login_id)
      response = TheCurrencyCloud.post "/authentication/token/new", :query => { :login_id => login_id, :api_key => TheCurrencyCloud.api_key}
      mash = Hashie::Mash.new(response)
      return mash.data
    end

    def get(action, options = {})
      TheCurrencyCloud.get uri_for(action), :query => options
    end

    def post(action, options = {})
      TheCurrencyCloud.post uri_for(action), :query => options
    end

    def put(action, options = {})
      TheCurrencyCloud.put uri_for(action), :query => options
    end

    def uri_for(action)
      "/#{self.token}/#{action}"
    end
  end
end
