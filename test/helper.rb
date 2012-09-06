require 'test/unit'
require 'pathname'

require 'shoulda'
require 'matchy'
require 'mocha'
require 'fakeweb'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'thecurrencycloud'

FakeWeb.allow_net_connect = false

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

def stub_request(method, api_key, url, filename, status=nil)
  options = {:body => "", :params => :any }
  options.merge!({:body => fixture_file(filename)}) if filename
  options.merge!({:status => status}) if status
  options.merge!(:content_type => "application/json; charset=utf-8")
  # Register both http (port 443) and https as HTTParty calls them both.
  FakeWeb.register_uri(method, "https://api.thecurrencycloud.com/api/en/v1.0/#{url}", options)
#  FakeWeb.register_uri(method, "http://api.thecurrencycloud.com:443/api/en/v1.0/#{url}", options)
end

def stub_get(*args); stub_request(:get, *args) end
def stub_post(*args); stub_request(:post, *args) end
def stub_put(*args); stub_request(:put, *args) end
def stub_delete(*args); stub_request(:delete, *args) end
