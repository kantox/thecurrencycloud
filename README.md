A ruby library which implements the complete functionality of v1 of the [The Currency Cloud API](http://connect.thecurrencycloud.com/).

## Installation

    gem install thecurrencycloud

## Examples

### Basic usage
Retrieve an exchange rate for a ccy pair

    require 'thecurrencycloud'

    TheCurrencyCloud.api_key 'your_api_key'

    tcc = TheCurrencyCloud::Client.new('login_id')
    prices = tcc.prices("GBP","EUR")
    puts "#{p.bid_price}: #{c.bid_price_timestamp}"
    puts "#{p.market_price}"

Results in:

    0.8364: 20110218-10:37:11
    0.8366

### Handling errors
If The Currency Cloud API returns an error, an exception will be thrown. For example, if ccypair isn't found for Exchange rates:

    require 'thecurrencycloud'

    TheCurrencyCloud.api_key 'your_api_key'

    begin
        tcc = TheCurrencyCloud::Client.new('login_id')
        prices = tcc.prices("EUR","XYZ")
      rescue TheCurrencyCloud::BadRequest => br
        puts "Bad request error: #{br}"
        puts "Error Code:    #{br.data.Code}"
        puts "Error Message: #{br.data.Message}"
      rescue Exception => e
        puts "Error: #{e}"
    end

Results in:

    Bad request error: The TheCurrencyCloud API responded with the following error - 304: Authentication Failed
    Error Code:    304
    Error Message: Unknown Currency Pair: EURXYZ

### Expected input and output
The best way of finding out the expected input and output of a particular method in a particular class is to use the unit tests as a reference.
