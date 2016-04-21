# IP2Country

IP(v4) address to country name converter for **Crystal**.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  ip2country:
    github: arcage/ip2country
```

## Usage

```crystal
require "ip2country"

# Create a converter object.
ip2country = IP2Country.new

# Country name lookup by IP address string.
ip2country.lookup("8.8.8.8", "en") # => "United States"
ip2country.lookup("8.8.8.8", "fr") # => "États-Unis"
ip2country.lookup("8.8.8.8", "es") # => "Estados Unidos"
ip2country.lookup("8.8.8.8", "de") # => "Vereinigte Staaten"
ip2country.lookup("8.8.8.8", "ja") # => "アメリカ合衆国"
ip2country.lookup("8.8.8.8", "zh") # => "美国"
ip2country.lookup("8.8.8.8", "ko") # => "미국"
ip2country.lookup("8.8.8.8")       # => "United States"(English is default)

# You can specify the default language.
ip2country = IP2Country.new("ja")
ip2country.lookup("8.8.8.8")       # => "アメリカ合衆国"

# Get a hash of country names in all supported languages
ip2country.lookup_all("8.8.8.8")
# => {"de" => "Vereinigte Staaten", "en" => "United States", "es" => "Estados Unidos", "fr" => "États-Unis", "ja" => "アメリカ合衆国", "ko" => "미국", "pt" => "Estados Unidos", "zh" => "美国"}
```

At the first time you use, this library will fetch some conversion tables, and cache them.

This may take a while.

When you want to update cache of tables, you can call `IP2Country.cache_update` explicitly.

_Notice: You **should not** call it every time you use this library._

# Special thanks

This library uses conversion tables(**ISO 3166-1 alpha-2** country codes to country names) provided by [umpirsky/country-list](https://github.com/umpirsky/country-list) &copy; Saša Stamenković <umpirsky@gmail.com>(license is  [here](https://github.com/umpirsky/country-list/blob/master/LICENSE)).

It supports many kinds of file formats(CSV, JSON, YAML, etc...) and many kinds of languages.

I sincerely respect this great work.

## Contributors

- [arcage](https://github.com/arcage) ʕ·ᴥ·ʔAKJ - creator, maintainer
