require File.dirname(__FILE__) + '/helper'

class TheCurrencyCloudTest < Test::Unit::TestCase
  context "set environment" do 
    should "set base_uri for ref" do 
      TheCurrencyCloud.environment :ref
      assert_equal 'http://refapi.thecurrencycloud.com/api/en/v1.0', TheCurrencyCloud.default_options[:base_uri]
    end
  end
  context "when the TheCurrencyCloud API responds with an error" do
    setup do
      @api_key = '123123123123123123123'
      TheCurrencyCloud.environment :live
      TheCurrencyCloud.api_key @api_key
    end

    { ["400", "Bad Request"]  => TheCurrencyCloud::BadRequest,
      ["401", "Unauthorized"] => TheCurrencyCloud::Unauthorized,
      ["404", "Not Found"]    => TheCurrencyCloud::NotFound,
      ["500", "Server Error"] => TheCurrencyCloud::ServerError
    }.each do |status, exception|
      context "#{status.first}, a get" do
        should "raise a #{exception.name} error" do
          stub_post(@api_key, "authentication/token/new", "authentication_success.json")
          @client = TheCurrencyCloud::Client.new('321iuhiuhi1u23hi2u3')          
          stub_get(@api_key, "d58440e120d6012dc05423001a48acdf/trades", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
          lambda { c = @client.trades }.should raise_error(exception)
        end
      end
    end
  end
end
