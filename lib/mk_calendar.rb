require "mk_calendar/version"
require "mk_calendar/argument"
require "mk_calendar/const"
require "mk_calendar/calendar"

module MkCalendar
  def self.new(arg = ARGV[0])
    arg ||= Time.now.strftime("%Y%m%d")
    ymd = MkCalendar::Argument.new(arg).get_ymd
    return if ymd == ""
    return MkCalendar::Calendar.new(ymd)
  end
end
