require 'thecurrencycloud'
require 'json'
require 'rest_client'

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

    def prices_client_quote(buy_currency, sell_currency, side, amount, options={})
      side = convert_sell_sym(side)
      options.merge!(:buy_currency => buy_currency, :sell_currency => sell_currency, :side  => side, :amount => amount)
      response = TheCurrencyCloud.post_form("/#{token}/prices/client_quote", options)
      mash = Price.new(response)
      return mash.data
    end

    # Returns a list of trades
    def trades
      response = TheCurrencyCloud.get("/#{token}/trades")
      mash = Trade.new(response)
      mash.data.collect{|d| Trade.new(d)}
    end

    # Executes a trade
    def trade_execute(options)
      side = convert_sell_sym(options[:side])
      response = TheCurrencyCloud.post_form("/#{token}/trade/execute", options.merge(:side => side))
      mash = Trade.new(response)
      return mash.data
    end

    # Executes a trade with payment
    def trade_execute_with_payment(options)
      side = convert_sell_sym(options[:side])
      response = TheCurrencyCloud.post_form("/#{token}/trade/execute_with_payment", options.merge(:side => side))
      mash = Trade.new(response)
      return mash.data
    end

    def trade(trade_id)
      response = TheCurrencyCloud.get("/#{token}/trade/#{trade_id}")
      mash = Trade.new(response)
      return mash.data
    end

    # Returns a list of trades
    def payments
      response = get "payments"
      mash = Hashie::Mash.new(response)
      mash.data.collect{|d| Payment.new(d)}
    end

    # Close the session
    def close_session
      response = post "close_session"
      mash = Hashie::Mash.new(response)
      @token = nil
      return mash.data
    end

    private

    def authenticate(login_id)
      response = TheCurrencyCloud.post_form("/authentication/token/new", { :login_id => login_id, :api_key => TheCurrencyCloud.api_key})
      mash = Hashie::Mash.new(response)
      return mash.data
    end

    def get(action, options = {})
      TheCurrencyCloud.get uri_for(action), :query => options
    end

    def post(action, options = {})
      if options.any?
        return post_form(action,options)
      end
      TheCurrencyCloud.post uri_for(action)
    end

    def post_form(action, options = {})
      TheCurrencyCloud.post_form uri_for(action), options
    end

    def put(action, options = {})
      TheCurrencyCloud.put uri_for(action), :data => options
    end

    def uri_for(action)
      "/#{self.token}/#{action}"
    end

    def convert_sell_sym(side)
      if side == :buy || side == 1
        side = 1
      elsif side == :sell || side == 2
        side = 2
      else
        raise "Side must be :buy or :sell"
      end
      return side
    end
  end
end
