struct IP2Country::IPAddr
  include Comparable(self)

  ROUGH_FORMAT = /\A(\d{1,3}\.){3}\d{1,3}\z/

  getter value

  @value : UInt32

  def initialize(@value)
  end

  def initialize(addr : String)
    raise "error" unless addr =~ ROUGH_FORMAT
    octets = addr.split(/\./).map(&.to_u32)
    raise "error" unless octets.size == 4
    value = 0u32
    (0..3).each do |index|
      raise "error" unless (0..255) === octets[index]
      value += (octets[index] << ((3 - index) * 8))
    end
    initialize(value)
  rescue
    raise "IP address format Error(#{addr})"
  end

  def <=>(other : self)
    self.value <=> other.value
  end

  def +(other : Int)
    IPAddr.new(@value + other)
  end

  def succ
    self + 1
  end

  def octet(index : Int) : UInt8
    ((@value >> ((3 - index) * 8)) & 255).to_u8
  end

  def octets
    (0..3).map { |i| octet(i) }
  end

  def inspect(io)
    io << "<IPAddr " << to_s << ">"
  end

  def to_s(io)
    io << octets.join(".")
  end
end
