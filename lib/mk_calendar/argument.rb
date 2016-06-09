require 'date'

module MkCalendar
  class Argument
    def initialize(arg)
      @date = arg
    end

    #=========================================================================
    # 引数取得
    #
    # * コマンドライン引数を取得して日時の妥当性チェックを行う
    # * コマンドライン引数無指定なら、現在日とする。
    #
    # @return: jst (UNIX time)
    #=========================================================================
    def get_ymd
      unless @date =~ /^\d{8}$/
        puts Const::USAGE
        return []
      end
      year  = @date[0,4].to_i
      month = @date[4,2].to_i
      day   = @date[6,2].to_i
      unless Date.valid_date?(year, month, day)
        puts Const::MSG_ERR_1
        return []
      end
      return [year, month, day]
    end
  end
end
