require File.dirname(__FILE__) + '/helper'

class ClientTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      TheCurrencyCloud.api_key @api_key
      stub_post(@api_key, "authentication/token/new", "authentication_success.json")
      @client = TheCurrencyCloud::Client.new('321iuhiuhi1u23hi2u3')
      @client.client_id.should == '321iuhiuhi1u23hi2u3'
    end

    should "accept a token as a param" do
      @client = TheCurrencyCloud::Client.new('321iuhiuhi1u23hi2u3', '32323232323223')
      @client.api_key.should == '32323232323223'
    end

    should "set a token" do
      @client.token.should == 'd58440e120d6012dc05423001a48acdf'
    end

    should "get trades" do
      stub_get(@api_key, "d58440e120d6012dc05423001a48acdf/trades", "trades.json")
      trades = @client.trades
      trades.class.should == Array
      trades.first.trade_id.should == "20110208-XVBFCV"
    end

    should "get market prices" do
      stub_get(@api_key, "d58440e120d6012dc05423001a48acdf/prices/market/EURGBP", "prices_market.json")
      prices = @client.prices_market("EURGBP")
      prices.offer_price.should == 0.8368
    end

    should "execute a trade" do
      stub_post(@api_key, "d58440e120d6012dc05423001a48acdf/trade/execute", "trade_execute_success.json")
      trade = @client.trade_execute(:buy_currency => "EUR", :sell_currency => "GBP", :amount => 10000.00,  :side => 1, :term_agreement => true, :reason => "a reason")
      trade.trade_id.should == "20100708-KLXRNT"
    end

    should "add payment" do
      stub_post(@api_key, "d58440e120d6012dc05423001a48acdf/payment/add", "payment_add.json")
      resp = @client.add_payment(:trade_id => "20130430-XXXXXX", currency: 'EUR',
                                 amount: '1000.00', beneficiary_id: '18c752e0-c98c-012d-2335-24201ac3f236')
      resp.message.should == "Your payment was saved"
    end

    context "close a session" do
      should "clear the token" do
        stub_post(@api_key, "d58440e120d6012dc05423001a48acdf/close_session", "authentication_close.json")
        @client.close_session
        @client.token.should == nil
      end
    end
  end
end
