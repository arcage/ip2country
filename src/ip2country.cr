
require "http/client"
require "uri"
require "yaml"

class IP2Country
  VERSION = "0.1.0"

  CACHE_DIR = File.expand_path(File.dirname(__FILE__)) + "/cache"
  REGISTRARS = {
    "ARIN" => "http://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest",
    "RIPE" => "http://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-extended-latest",
    "APNIC" => "https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest",
    "LACNIC" => "http://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest",
    "AFRINIC" => "http://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest"
  }
  LANGS = Set.new ["en", "fr", "de", "es", "pt", "ja", "ko", "zh"]

  def self.cache_update
    STDERR.puts "[IP2Coutnry] Fetching conversion tables."
    CC2Country.cache_update
    IP2CC.cache_update
  end

  def initialize(@default_lang = "en")
    unless File.directory?(CACHE_DIR)
      STDERR.puts "[IP2Coutnry] Conversion tables not found."
      IP2Country.cache_update
    end
    @conversion = IP2CC.new
    @country_code = CC2Country.new
  end

  def lookup(addr : IPAddr, lang : String = @default_lang) : String
    @country_code.lookup(@conversion.lookup(addr), lang)
  end

  def lookup(addr : String, lang : String =@default_lang) : String
    lookup(IPAddr.new(addr), lang)
  end

  def lookup_all(addr : IPAddr) : Hash(String, String)
    @country_code.lookup_all(@conversion.lookup(addr))
  end

  def lookup_all(addr : String) : Hash(String, String)
    lookup_all(IPAddr.new(addr))
  end
end

require "./ip2country/*"
