class IP2Country::IP2CC

  FILE_NAME = IP2Country::CACHE_DIR + "/conversion.dat"

  def self.cache_update : Bool
    modified = Registrar.cache_update
    if modified
      table = Hash(Range(IPAddr, IPAddr), String).new
      Dir.glob(Registrar::CACHE_DIR + "/*.dat").each do |dat_file|
        File.each_line(dat_file) do |line|
          next if line =~ /^#/ || line !~ /\|ipv4\|/
          tmp = line.chomp.split("|")
          next if tmp.size < 8
          registorer, cc, ver, start_ip, ip_num, date, desc = tmp
          min = IPAddr.new(start_ip)
          max = min + (ip_num.to_u32 - 1)
          table[min .. max] = cc
        end
      end
      ranges = table.keys.sort{|a,b| a.begin <=> b.begin}
      File.open(FILE_NAME, "w") do |fp|
        until ranges.empty?
          range = ranges.shift
          cc = table[range]
          if !ranges.empty? && range.end.succ == ranges.first.begin && table[ranges.first] == cc
            range = range.begin .. ranges.first.end
            ranges.shift
          end
          fp.puts [range.begin, range.end, cc].join("\t")
        end
      end
      STDERR.puts "[IP2Coutnry] IP to CC conversion table updated."
    else
      STDERR.puts "[IP2Coutnry] IP to CC conversion table not modified."\
    end
    return modified
  end

  @table : Hash(UInt8, Array(Tuple(Range(IPAddr, IPAddr), String)))
  @cache : Hash(UInt32, String)

  def initialize
    @table = Hash(UInt8, Array(Tuple(Range(IPAddr, IPAddr), String))).new do |h,k|
      h[k] = Array(Tuple(Range(IPAddr, IPAddr), String)).new
    end
    File.each_line(FILE_NAME) do |line|
      min, max, cc = line.chomp.split("\t")
      min_ip = IPAddr.new(min)
      max_ip = IPAddr.new(max)
      range = min_ip .. max_ip
      (min_ip.octet(0)..max_ip.octet(0)).each do |class_a|
        @table[class_a] << {range, cc}
      end
    end
    @cache = Hash(UInt32, String).new
  end

  def lookup(addr : IPAddr) : String
    return @cache[addr.value] if @cache.has_key?(addr.value)
    cc = ""
    @table[addr.octet(0)].each do |tpl|
      range = tpl[0]
      if range === addr
        cc = tpl[1]
        break
      end
    end
    @cache[addr.value] = cc
    return cc
  end

  class Registrar

    LIST = [] of self

    CACHE_DIR = IP2Country::CACHE_DIR + "/registrar"

    def self.cache_update
      Dir.mkdir_p(CACHE_DIR) unless File.directory?(CACHE_DIR)
      modified = false
      LIST.each do |registorer|
        modified = true if registorer.cache_update
      end
      return modified
    end

    getter name
    getter uri
    getter cache_file
    getter mtime

    @name : String
    @uri : URI
    @cache_file : String
    @mtime : Time

    def initialize(@name, uri_string : String)
      @uri = URI.parse(uri_string)
      @cache_file = CACHE_DIR + "/#{@name}.dat"
      @mtime = File.exists?(@cache_file) ? File.stat(@cache_file).mtime : Time.new(2000, 1, 1)
    end

    def cache_update : Bool
      modified = false
      http = HTTP::Client.new(@uri)
      headers = HTTP::Headers.new
      headers["If-modified-since"] = HTTP.rfc1123_date(@mtime)
      responce = http.get(@uri.path.not_nil!, headers)
      case responce.status_code
      when 200
        STDERR.puts "[IP2Coutnry] IP allocation table of #{@name} is updated."
        File.write(@cache_file, responce.body)
        modified = true
      when 304
        STDERR.puts "[IP2Coutnry] IP allocation table of #{@name} is not modified."
      when 404
        STDERR.puts "[IP2Coutnry] IP allocation table of #{@name} is not found."
      else
        STDERR.puts "[IP2Coutnry] Receive status code #{responce.status_code} for IP allocation table of #{@name}."
      end
      return modified
    end

    def to_s(io)
      io << "<IPLocator::Registrar " << @name << ">"
    end

    IP2Country::REGISTRARS.each do |name, uri_string|
      LIST << Registrar.new(name, uri_string)
    end

  end

end
