require "mk_calendar/version"
require "mk_calendar/argument"
require "mk_calendar/const"
require "mk_calendar/calendar"

module MkCalendar
  def self.new(args = ARGV)
    ymd = MkCalendar::Argument.new(args).get_ymd
    return if ymd == []
    return MkCalendar::Calendar.new(ymd)
  end
end
