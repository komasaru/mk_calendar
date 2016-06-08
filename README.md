# MkCalendar

## Introduction

This is the gem library which calculates calendar datas, including old-calendar.

### Computable items

julian day(utc), julian day(jst), holiday, sekki_24, zassetsu,  
yobi, kanshi, sekku, lambda_sun, lambda_moon, moonage,  
old-calendar(year, month, day, leap flag), rokuyo

### Original Text

[旧暦計算サンプルプログラム](http://www.vector.co.jp/soft/dos/personal/se016093.html)  
Copyright (C) 1993,1994 by H.Takano

### Remark

However, the above program includes some problems for calculating the future  
old-calendar datas. So, I have done some adjustments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mk_calendar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mk_calendar

## Usage

### Instantiation

``` ruby
require 'mk_calendar'

obj = MkCalendar.new

# Otherwise
obj = MkCalendar.new("20160608")
```

### Calculation

``` ruby
obj.calc

# Otherwise
obj.calc_holiday
obj.calc_sekki_24
obj.calc_zassetsu
obj.calc_yobi
obj.calc_kanshi
obj.calc_sekku
obj.calc_lambda_sun
obj.calc_lambda_moon
obj.calc_moonage
obj.calc_oc
obj.calc_rokuyo
```

### Getting values

``` ruby
puts o.year, o.month, o.day, o.jd, o.jd_jst
puts o.holiday
puts o.sekki_24
puts o.zassetsu
puts o.yobi
puts o.kanshi
puts o.sekku
puts o.lambda_sun
puts o.lambda_moon
puts o.moonage
puts o.oc_year, o.oc_leap, o.oc_month, o.oc_day
puts o.rokuyo
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec mk_calendar` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/komasaru/mk_calendar.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

