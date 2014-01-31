require 'cgi'
require 'uri'
require 'httparty'
require 'hashie'

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'thecurrencycloud/version'
require 'thecurrencycloud/client'
require 'thecurrencycloud/price'
require 'thecurrencycloud/trade'
require 'thecurrencycloud/payment'
require 'thecurrencycloud/beneficiary'
require 'thecurrencycloud/bank'

module TheCurrencyCloud

  # Just allows callers to do TheCurrencyCloud.api_key "..." rather than TheCurrencyCloud::TheCurrencyCloud.api_key "..." etc
  class << self
    def api_key(api_key=nil)
      r = TheCurrencyCloud.api_key api_key
    end

    def base_uri(uri)
      r = TheCurrencyCloud.base_uri uri
    end

    def default_options
      r = TheCurrencyCloud.default_options
    end

    def environment(env)
      case env.to_sym
      when :demo
        uri = "https://devapi.thecurrencycloud.com/api/en/v1.0"
      when :ref
        uri = "http://refapi.thecurrencycloud.com/api/en/v1.0"
      else
        uri = "https://api.thecurrencycloud.com/api/en/v1.0"
      end
      TheCurrencyCloud.base_uri uri
    end
  end

  # Represents a TheCurrencyCloud API error and contains specific data about the error.
  class TheCurrencyCloudError < StandardError
    attr_reader :data
    def initialize(data)
      @data = data
      # @data should contain Code, Message and optionally ResultData
      extra = @data.ResultData ? "\nExtra result data: #{@data.ResultData}" : ""
      super "TheCurrencyCloud API responded with the following error - #{@data.Code}: #{@data.message}#{extra}"
    end
  end

  class ClientError < StandardError; end
  class ServerError < StandardError; end
  class BadRequest < TheCurrencyCloudError; end
  class Unauthorized < TheCurrencyCloudError; end
  class NotFound < ClientError; end
  class Unavailable < StandardError; end

  # Provides high level TheCurrencyCloud functionality/data you'll probably need.
  class TheCurrencyCloud
    include HTTParty
    debug_output $stdout
    RestClient.log = $stdout
    class Parser::DealWithTheCurrencyCloudInvalidJson < HTTParty::Parser
      # The thecurrencycloud API returns an ID as a string when a 201 Created
      # response is returned. Unfortunately this is invalid json.
      def parse
        begin
          super
        rescue MultiJson::DecodeError => e
          body[1..-2] # Strip surrounding quotes and return as is.
        end
      end
    end
    parser Parser::DealWithTheCurrencyCloudInvalidJson
    @@base_uri = "https://api.thecurrencycloud.com/api/en/v1.0"
    @@api_key = ""
    headers({
      'User-Agent' => "thecurrencycloud-ruby-#{VERSION}",
      'Content-Type' => 'application/json; charset=utf-8',
      'Accept-Encoding' => 'gzip, deflate' })
    base_uri @@base_uri

    # Sets the API key which will be used to make calls to the TheCurrencyCloud API.
    def self.api_key(api_key=nil)
      return @@api_key unless api_key
      @@api_key = api_key
    end


    def self.get(*args);      handle_response super end
    def self.post(*args);     handle_response super end
    def self.put(*args);      handle_response super end
    def self.delete(*args);   handle_response super end

    def self.post_form(action,options={})
      response = RestClient.post "#{TheCurrencyCloud.default_options[:base_uri]}#{action}",options
      data = response.body
      handle_response(response)
      return JSON.parse(data)
    end

    def self.handle_response(response) # :nodoc:
      case response.code
      when 400
        raise BadRequest.new(Hashie::Mash.new response)
      when 401
        raise Unauthorized.new(Hashie::Mash.new response)
      when 404
        raise NotFound.new
      when 400...500
        raise ClientError.new
      when 500...600
        raise ServerError.new
      else
        data = (response.body and response.body.length >= 2) ? response.body : nil
        return response if data.nil?
        mash_response = Hashie::Mash.new(JSON.parse(data))
        if mash_response.status == "error"
          raise BadRequest.new(mash_response)
        else
          response
        end
      end
    end
  end
end
