
class IP2Country::CC2Country
  CACHE_DIR = IP2Country::CACHE_DIR + "/country"

  def self.cache_update : Bool
    Dir.mkdir_p(CACHE_DIR) unless File.directory?(CACHE_DIR)
    modified = false
    IP2Country::LANGS.each do |lang|
      uri = URI.parse("https://raw.githubusercontent.com/umpirsky/country-list/master/data/#{lang}/country.yaml")
      cache_file = CACHE_DIR + "/#{lang}.yaml"
      mtime = File.exists?(cache_file) ? File.stat(cache_file).mtime : Time.new(2000, 1, 1)
      http = HTTP::Client.new(uri)
      headers = HTTP::Headers.new
      headers["If-modified-since"] = HTTP.rfc1123_date(mtime)
      responce = http.get(uri.path.not_nil!, headers)
      case responce.status_code
      when 200
        STDERR.puts "[IP2Coutnry] Country code table(#{lang}) is updated."
        File.write(cache_file, responce.body)
        modified = true
      when 304
        STDERR.puts "[IP2Coutnry] Country code table(#{lang}) is not modified."
      when 404
        STDERR.puts "[IP2Coutnry] Country code table(#{lang}) is not found."
      else
        STDERR.puts "[IP2Coutnry] Receive status code #{responce.status_code} for country code table(#{lang})."
      end
    end
    return modified
  end

  def initialize()
    @table = Hash(String, Hash(String, String)).new do |h,k|
      h[k] = Hash(String, String).new
    end
    Dir.glob(CACHE_DIR + "/*.yaml").each do |file|
      lang = File.basename(file, ".yaml")
      data = YAML.parse(File.read(file)).as_h
      data.each do |cc, name|
        @table[cc as String][lang] = name as String
      end
    end
  end

  def lookup(cc : String, lang : String) : String
    if @table.has_key?(cc)
      if @table[cc].has_key?(lang)
        @table[cc][lang]
      else
        @table[cc]["en"]
      end
    else
      "[UNKNOWN]"
    end
  end

  def lookup_all(cc : String) : Hash(String, String)
    @table[cc]? || { "en" => "[UNKNOWN]" }
  end

end
