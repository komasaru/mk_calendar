module MkCalendar
  module Compute
    module_function

    #=========================================================================
    # 休日の計算
    #
    # @param:  year
    # @param:  month
    # @param:  day
    # @return: holiday (漢字１文字)
    #=========================================================================
    def compute_holiday(year, month, day)
      holiday_0 = Array.new  # 変動の祝日用
      holiday_1 = Array.new  # 国民の休日用
      holiday_2 = Array.new  # 振替休日用

      # 変動の祝日の日付･曜日を計算 ( 振替休日,国民の休日を除く )
      Const::HOLIDAY.each do |holiday|
        unless holiday[1] == 99
          unless holiday[2] == 99   # 月日が既定のもの
            jd_jst = gc2jd(year, holiday[1], holiday[2]) + Const::JST_D
            yobi = compute_yobi(jd_jst)
            holiday_0 << [holiday[1], holiday[2], holiday[0], jd_jst, yobi]
          else                      # 月日が不定のもの
            if holiday[3] == 21     # 第2月曜日 ( 8 - 14 の月曜日)
              8.upto(14) do |d|
                jd_jst = gc2jd(year, holiday[1], d) + Const::JST_D
                yobi = compute_yobi(jd_jst)
                holiday_0 << [holiday[1], d, holiday[0], jd_jst, "月"] if yobi == "月"
              end
            elsif holiday[3] == 31  # 第3月曜日 ( 15 - 21 の月曜日)
              15.upto(21) do |d|
                jd_jst = gc2jd(year, holiday[1], d) + Const::JST_D
                yobi = compute_yobi(jd_jst)
                holiday_0 << [holiday[1], d, holiday[0], jd_jst, "月"] if yobi == "月"
              end
            elsif holiday[3] == 80  # 春分の日
              jd_jst = gc2jd(year, holiday[1], 31) + Const::JST_D
              nibun_jd = compute_last_nc(jd_jst, 90)[0]
              d = jd2ymd(nibun_jd)[2]
              wk_jd = gc2jd(year, holiday[1], d) + Const::JST_D
              yobi = compute_yobi(wk_jd)
              holiday_0 << [holiday[1], d, holiday[0], wk_jd, yobi]
            elsif holiday[3] == 81  # 秋分の日
              jd_jst = gc2jd(year, holiday[1], 30) + Const::JST_D
              nibun_jd = compute_last_nc(jd_jst, 90)[0]
              d = jd2ymd(nibun_jd)[2]
              wk_jd = gc2jd(year, holiday[1], d) + Const::JST_D
              yobi = compute_yobi(wk_jd)
              holiday_0 << [holiday[1], d, holiday[0], wk_jd, yobi]
            end
          end
        end
      end

      # 国民の休日計算
      # ( 「国民の祝日」で前後を挟まれた「国民の祝日」でない日 )
      # ( 年またぎは考慮していない(今のところ不要) )
      0.upto(holiday_0.length - 2) do |i|
        if holiday_0[i][3] + 2 == holiday_0[i + 1][3]
          jd = holiday_0[i][3] + 1
          yobi = Const::YOBI[Const::YOBI.index(holiday_0[i][4]) + 1]
          wk_ary = Array.new
          wk_ary << jd2ymd(jd)[1]
          wk_ary << jd2ymd(jd)[2]
          wk_ary << 90
          wk_ary << jd
          wk_ary << yobi
          holiday_1 << wk_ary
        end
      end

      # 振替休日計算
      # ( 「国民の祝日」が日曜日に当たるときは、
      #   その日後においてその日に最も近い「国民の祝日」でない日 )
      0.upto(holiday_0.length - 1) do |i|
        if holiday_0[i][4] == "日"
          next_jd = holiday_0[i][3] + 1
          next_yobi = Const::YOBI[Const::YOBI.index(holiday_0[i][4]) + 1]
          if i == holiday_0.length - 1
            wk_ary = Array.new
            wk_ary << jd2ymd(next_jd)[1]
            wk_ary << jd2ymd(next_jd)[2]
            wk_ary << 91
            wk_ary << next_jd
            wk_ary << next_yobi
          else
            flg_furikae = 0
            plus_day = 1
            while flg_furikae == 0
              if i + plus_day < holiday_0.length
                if next_jd == holiday_0[i + plus_day][3]
                  next_jd += 1
                  next_yobi = next_yobi == "土" ? "日" : Const::YOBI[Const::YOBI.index(next_yobi) + 1]
                  plus_day += 1
                else
                  flg_furikae = 1
                  wk_ary = Array.new
                  wk_ary << jd2ymd(next_jd)[1]
                  wk_ary << jd2ymd(next_jd)[2]
                  wk_ary << 91
                  wk_ary << next_jd
                  wk_ary << next_yobi
                end
              end
            end
          end
          holiday_2 << wk_ary
        end
      end

      # 配列整理
      code = 99
      (holiday_0 + holiday_1 + holiday_2).sort.each do |holiday|
        if holiday[0] == month &&  holiday[1] == day
          code = holiday[2]
          break
        end
      end
      holiday = ""
      res = Const::HOLIDAY.select { |h| h[0] == code }
      holiday = res[0][4] unless res == []
      return holiday
    end

    #=========================================================================
    # 二十四節気の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: sekki_24 (二十四節気の文字列)
    #=========================================================================
    def compute_sekki_24(jd)
      lsun_today     = compute_lambda_sun(jd)
      lsun_tomorrow  = compute_lambda_sun(jd + 1)
      lsun_today0    = 15 * (lsun_today / 15.0).truncate
      lsun_tomorrow0 = 15 * (lsun_tomorrow / 15.0).truncate
      return lsun_today0 == lsun_tomorrow0 ? "" : Const::SEKKI_24[lsun_tomorrow0 / 15]
    end

    #=========================================================================
    # 雑節の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: [雑節コード1, 雑節コード2]
    #=========================================================================
    def compute_zassetsu(jd)
      zassetsu = Array.new

      # 計算対象日の太陽の黄経
      lsun_today = compute_lambda_sun(jd)
      # 計算対象日の翌日の太陽の黄経
      lsun_tomorrow = compute_lambda_sun(jd + 1)
      # 計算対象日の5日前の太陽の黄経(社日計算用)
      lsun_before_5 = compute_lambda_sun(jd - 5)
      # 計算対象日の4日前の太陽の黄経(社日計算用)
      lsun_before_4 = compute_lambda_sun(jd - 4)
      # 計算対象日の5日後の太陽の黄経(社日計算用)
      lsun_after_5  = compute_lambda_sun(jd + 5)
      # 計算対象日の6日後の太陽の黄経(社日計算用)
      lsun_after_6  = compute_lambda_sun(jd + 6)
      # 太陽の黄経の整数部分( 土用, 入梅, 半夏生 計算用 )
      lsun_today0    = lsun_today.truncate
      lsun_tomorrow0 = lsun_tomorrow.truncate

      #### ここから各種雑節計算
      # 0:節分 ( 立春の前日 )
      zassetsu << 0 if compute_sekki_24(jd + 1) == "立春"
      # 1:彼岸入（春） ( 春分の日の3日前 )
      zassetsu << 1 if compute_sekki_24(jd + 3) == "春分"
      # 2:彼岸（春） ( 春分の日 )
      zassetsu << 2 if compute_sekki_24(jd) == "春分"
      # 3:彼岸明（春） ( 春分の日の3日後 )
      zassetsu << 3 if compute_sekki_24(jd - 3) == "春分"
      # 4:社日（春） ( 春分の日に最も近い戊(つちのえ)の日 )
      # * 計算対象日が戊の日の時、
      #   * 4日後までもしくは4日前までに春分の日がある時、
      #       この日が社日
      #   * 5日後が春分の日の時、
      #       * 春分点(黄経0度)が午前なら
      #           この日が社日
      #       * 春分点(黄経0度)が午後なら
      #           この日の10日後が社日
      if (jd % 10).truncate == 4  # 戊の日
        # [ 当日から4日後 ]
        0.upto(4) do |i|
          if compute_sekki_24(jd + i) == "春分"
            zassetsu << 4
            break
          end
        end
        # [ 1日前から4日前 ]
        1.upto(4) do |i|
          if compute_sekki_24(jd - i) == "春分"
            zassetsu << 4
            break
          end
        end
        # [ 5日後 ]
        if compute_sekki_24(jd + 5)  == "春分"
          # 春分の日の黄経(太陽)と翌日の黄経(太陽)の中間点が
          # 0度(360度)以上なら、春分点が午前と判断
          zassetsu << 4 if (lsun_after_5 + lsun_after_6 + 360) / 2.0 >= 360
        end
        # [ 5日前 ]
        if compute_sekki_24(jd - 5) == "春分"
          # 春分の日の黄経(太陽)と翌日の黄経(太陽)の中間点が
          # 0度(360度)未満なら、春分点が午後と判断
          zassetsu << 4 if (lsun_before_4 + lsun_before_5 + 360) / 2.0 < 360
        end
      end
      # 5:土用入（春） ( 黄経(太陽) = 27度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 5 if lsun_tomorrow0 == 27
      end
      # 6:八十八夜 ( 立春から88日目(87日後) )
      zassetsu << 6 if compute_sekki_24(jd - 87) == "立春"
      # 7:入梅 ( 黄経(太陽) = 80度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 7 if lsun_tomorrow0 == 80
      end
      # 8:半夏生  ( 黄経(太陽) = 100度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 8 if lsun_tomorrow0 == 100
      end
      # 9:土用入（夏） ( 黄経(太陽) = 117度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 9 if lsun_tomorrow0 == 117
      end
      # 10:二百十日 ( 立春から210日目(209日後) )
      zassetsu << 10 if compute_sekki_24(jd - 209) == "立春"
      # 11:二百二十日 ( 立春から220日目(219日後) )
      zassetsu << 11 if compute_sekki_24(jd - 219) == "立春"
      # 12:彼岸入（秋） ( 秋分の日の3日前 )
      zassetsu << 12 if compute_sekki_24(jd + 3) == "秋分"
      # 13:彼岸（秋） ( 秋分の日 )
      zassetsu << 13 if compute_sekki_24(jd) == "秋分"
      # 14:彼岸明（秋） ( 秋分の日の3日後 )
      zassetsu << 14 if compute_sekki_24(jd - 3) == "秋分"
      # 15:社日（秋） ( 秋分の日に最も近い戊(つちのえ)の日 )
      # * 計算対象日が戊の日の時、
      #   * 4日後までもしくは4日前までに秋分の日がある時、
      #       この日が社日
      #   * 5日後が秋分の日の時、
      #       * 秋分点(黄経180度)が午前なら
      #           この日が社日
      #       * 秋分点(黄経180度)が午後なら
      #           この日の10日後が社日
      if (jd % 10).truncate == 4 # 戊の日
        # [ 当日から4日後 ]
        0.upto(4) do |i|
          if compute_sekki_24(jd + i) == "秋分"
            zassetsu << 15
            break
          end
        end
        # [ 1日前から4日前 ]
        1.upto(4) do |i|
          if compute_sekki_24(jd - i) == "秋分"
            zassetsu << 15
            break
          end
        end
        # [ 5日後 ]
        if compute_sekki_24(jd + 5) == "秋分"
          # 秋分の日の黄経(太陽)と翌日の黄経(太陽)の中間点が
          # 180度以上なら、秋分点が午前と判断
          zassetsu << 15 if (lsun_after_5 + lsun_after_6) / 2.0 >= 180
        end
        # [ 5日前 ]
        if compute_sekki_24(jd - 5) == "秋分"
          # 秋分の日の黄経(太陽)と翌日の黄経(太陽)の中間点が
          # 180度未満なら、秋分点が午後と判断
          zassetsu << 15 if (lsun_before_4 + lsun_before_5) / 2.0 < 180
        end
      end
      # 16:土用入（秋） ( 黄経(太陽) = 207度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 16 if lsun_tomorrow0 == 207
      end
      # 17:土用入（冬） ( 黄経(太陽) = 297度 )
      unless lsun_today0 == lsun_tomorrow0
        zassetsu << 17 if lsun_tomorrow0 == 297
      end
      return zassetsu.map { |z| Const::ZASSETSU[z] }.join(",")
    end

    #=========================================================================
    # 曜日の計算
    #
    # * 曜日 = ( ユリウス通日 + 2 ) % 7
    #     0: 日曜, 1: 月曜, 2: 火曜, 3: 水曜, 4: 木曜, 5: 金曜, 6: 土曜
    #
    # @param:  jd (ユリウス日(JST))
    # @return: yobi  (漢字１文字)
    #=========================================================================
    def compute_yobi(jd)
      return Const::YOBI[(jd.to_i + 2) % 7]
    end

    #=========================================================================
    # 干支の計算
    #
    # * [ユリウス日(JST) - 10日] を60で割った剰余
    #
    # @param:  jd (ユリウス日(JST))
    # @return  kanshi (漢字２文字)
    #=========================================================================
    def compute_kanshi(jd)
      return Const::KANSHI[(jd.to_i - 10) % 60]
    end

    #=========================================================================
    # 節句の計算
    #
    # @param:  month
    # @param:  day
    # @return: sekku (日本語文字列)
    #=========================================================================
    def compute_sekku(month, day)
      sekku = ""
      res = Const::SEKKU.select { |s| s[1] == month && s[2] == day }
      sekku = res[0][3] unless res == []
      return sekku
    end

    #=========================================================================
    # 太陽視黄経の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: lambda
    #=========================================================================
    def compute_lambda_sun(jd)
      year, month, day, hour, min, sec = jd2ymd(jd - Const::JST_D)
      dt = compute_dt(year, month, day)  # deltaT
      jy = (jd - Const::JST_D + dt / 86400.0 - 2451545.0) / 365.25  # Julian Year
      rm  = 0.0003 * Math.sin(Const::K * norm_angle(329.7  +   44.43  * jy))
      rm += 0.0003 * Math.sin(Const::K * norm_angle(352.5  + 1079.97  * jy))
      rm += 0.0004 * Math.sin(Const::K * norm_angle( 21.1  +  720.02  * jy))
      rm += 0.0004 * Math.sin(Const::K * norm_angle(157.3  +  299.30  * jy))
      rm += 0.0004 * Math.sin(Const::K * norm_angle(234.9  +  315.56  * jy))
      rm += 0.0005 * Math.sin(Const::K * norm_angle(291.2  +   22.81  * jy))
      rm += 0.0005 * Math.sin(Const::K * norm_angle(207.4  +    1.50  * jy))
      rm += 0.0006 * Math.sin(Const::K * norm_angle( 29.8  +  337.18  * jy))
      rm += 0.0007 * Math.sin(Const::K * norm_angle(206.8  +   30.35  * jy))
      rm += 0.0007 * Math.sin(Const::K * norm_angle(153.3  +   90.38  * jy))
      rm += 0.0008 * Math.sin(Const::K * norm_angle(132.5  +  659.29  * jy))
      rm += 0.0013 * Math.sin(Const::K * norm_angle( 81.4  +  225.18  * jy))
      rm += 0.0015 * Math.sin(Const::K * norm_angle(343.2  +  450.37  * jy))
      rm += 0.0018 * Math.sin(Const::K * norm_angle(251.3  +    0.20  * jy))
      rm += 0.0018 * Math.sin(Const::K * norm_angle(297.8  + 4452.67  * jy))
      rm += 0.0020 * Math.sin(Const::K * norm_angle(247.1  +  329.64  * jy))
      rm += 0.0048 * Math.sin(Const::K * norm_angle(234.95 +   19.341 * jy))
      rm += 0.0200 * Math.sin(Const::K * norm_angle(355.05 +  719.981 * jy))
      rm += (1.9146 - 0.00005 * jy) * Math.sin(Const::K * norm_angle(357.538 + 359.991 * jy))
      rm += norm_angle(280.4603 + 360.00769 * jy)
      return norm_angle(rm)
    end

    #=========================================================================
    # 月視黄経の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: lambda
    #=========================================================================
    def compute_lambda_moon(jd)
      year, month, day, hour, min, sec = jd2ymd(jd - Const::JST_D)
      dt = compute_dt(year, month, day)  # deltaT
      jy = (jd - Const::JST_D + dt / 86400.0 - 2451545.0) / 365.25  # Julian Year
      am  = 0.0006 * Math.sin(Const::K * norm_angle( 54.0 + 19.3  * jy))
      am += 0.0006 * Math.sin(Const::K * norm_angle( 71.0 +  0.2  * jy))
      am += 0.0020 * Math.sin(Const::K * norm_angle( 55.0 + 19.34 * jy))
      am += 0.0040 * Math.sin(Const::K * norm_angle(119.5 +  1.33 * jy))
      rm_moon  = 0.0003 * Math.sin(Const::K * norm_angle(280.0   + 23221.3    * jy))
      rm_moon += 0.0003 * Math.sin(Const::K * norm_angle(161.0   +    40.7    * jy))
      rm_moon += 0.0003 * Math.sin(Const::K * norm_angle(311.0   +  5492.0    * jy))
      rm_moon += 0.0003 * Math.sin(Const::K * norm_angle(147.0   + 18089.3    * jy))
      rm_moon += 0.0003 * Math.sin(Const::K * norm_angle( 66.0   +  3494.7    * jy))
      rm_moon += 0.0003 * Math.sin(Const::K * norm_angle( 83.0   +  3814.0    * jy))
      rm_moon += 0.0004 * Math.sin(Const::K * norm_angle( 20.0   +   720.0    * jy))
      rm_moon += 0.0004 * Math.sin(Const::K * norm_angle( 71.0   +  9584.7    * jy))
      rm_moon += 0.0004 * Math.sin(Const::K * norm_angle(278.0   +   120.1    * jy))
      rm_moon += 0.0004 * Math.sin(Const::K * norm_angle(313.0   +   398.7    * jy))
      rm_moon += 0.0005 * Math.sin(Const::K * norm_angle(332.0   +  5091.3    * jy))
      rm_moon += 0.0005 * Math.sin(Const::K * norm_angle(114.0   + 17450.7    * jy))
      rm_moon += 0.0005 * Math.sin(Const::K * norm_angle(181.0   + 19088.0    * jy))
      rm_moon += 0.0005 * Math.sin(Const::K * norm_angle(247.0   + 22582.7    * jy))
      rm_moon += 0.0006 * Math.sin(Const::K * norm_angle(128.0   +  1118.7    * jy))
      rm_moon += 0.0007 * Math.sin(Const::K * norm_angle(216.0   +   278.6    * jy))
      rm_moon += 0.0007 * Math.sin(Const::K * norm_angle(275.0   +  4853.3    * jy))
      rm_moon += 0.0007 * Math.sin(Const::K * norm_angle(140.0   +  4052.0    * jy))
      rm_moon += 0.0008 * Math.sin(Const::K * norm_angle(204.0   +  7906.7    * jy))
      rm_moon += 0.0008 * Math.sin(Const::K * norm_angle(188.0   + 14037.3    * jy))
      rm_moon += 0.0009 * Math.sin(Const::K * norm_angle(218.0   +  8586.0    * jy))
      rm_moon += 0.0011 * Math.sin(Const::K * norm_angle(276.5   + 19208.02   * jy))
      rm_moon += 0.0012 * Math.sin(Const::K * norm_angle(339.0   + 12678.71   * jy))
      rm_moon += 0.0016 * Math.sin(Const::K * norm_angle(242.2   + 18569.38   * jy))
      rm_moon += 0.0018 * Math.sin(Const::K * norm_angle(  4.1   +  4013.29   * jy))
      rm_moon += 0.0020 * Math.sin(Const::K * norm_angle( 55.0   +    19.34   * jy))
      rm_moon += 0.0021 * Math.sin(Const::K * norm_angle(105.6   +  3413.37   * jy))
      rm_moon += 0.0021 * Math.sin(Const::K * norm_angle(175.1   +   719.98   * jy))
      rm_moon += 0.0021 * Math.sin(Const::K * norm_angle( 87.5   +  9903.97   * jy))
      rm_moon += 0.0022 * Math.sin(Const::K * norm_angle(240.6   +  8185.36   * jy))
      rm_moon += 0.0024 * Math.sin(Const::K * norm_angle(252.8   +  9224.66   * jy))
      rm_moon += 0.0024 * Math.sin(Const::K * norm_angle(211.9   +   988.63   * jy))
      rm_moon += 0.0026 * Math.sin(Const::K * norm_angle(107.2   + 13797.39   * jy))
      rm_moon += 0.0027 * Math.sin(Const::K * norm_angle(272.5   +  9183.99   * jy))
      rm_moon += 0.0037 * Math.sin(Const::K * norm_angle(349.1   +  5410.62   * jy))
      rm_moon += 0.0039 * Math.sin(Const::K * norm_angle(111.3   + 17810.68   * jy))
      rm_moon += 0.0040 * Math.sin(Const::K * norm_angle(119.5   +     1.33   * jy))
      rm_moon += 0.0040 * Math.sin(Const::K * norm_angle(145.6   + 18449.32   * jy))
      rm_moon += 0.0040 * Math.sin(Const::K * norm_angle( 13.2   + 13317.34   * jy))
      rm_moon += 0.0048 * Math.sin(Const::K * norm_angle(235.0   +    19.34   * jy))
      rm_moon += 0.0050 * Math.sin(Const::K * norm_angle(295.4   +  4812.66   * jy))
      rm_moon += 0.0052 * Math.sin(Const::K * norm_angle(197.2   +   319.32   * jy))
      rm_moon += 0.0068 * Math.sin(Const::K * norm_angle( 53.2   +  9265.33   * jy))
      rm_moon += 0.0079 * Math.sin(Const::K * norm_angle(278.2   +  4493.34   * jy))
      rm_moon += 0.0085 * Math.sin(Const::K * norm_angle(201.5   +  8266.71   * jy))
      rm_moon += 0.0100 * Math.sin(Const::K * norm_angle( 44.89  + 14315.966  * jy))
      rm_moon += 0.0107 * Math.sin(Const::K * norm_angle(336.44  + 13038.696  * jy))
      rm_moon += 0.0110 * Math.sin(Const::K * norm_angle(231.59  +  4892.052  * jy))
      rm_moon += 0.0125 * Math.sin(Const::K * norm_angle(141.51  + 14436.029  * jy))
      rm_moon += 0.0153 * Math.sin(Const::K * norm_angle(130.84  +   758.698  * jy))
      rm_moon += 0.0305 * Math.sin(Const::K * norm_angle(312.49  +  5131.979  * jy))
      rm_moon += 0.0348 * Math.sin(Const::K * norm_angle(117.84  +  4452.671  * jy))
      rm_moon += 0.0410 * Math.sin(Const::K * norm_angle(137.43  +  4411.998  * jy))
      rm_moon += 0.0459 * Math.sin(Const::K * norm_angle(238.18  +  8545.352  * jy))
      rm_moon += 0.0533 * Math.sin(Const::K * norm_angle( 10.66  + 13677.331  * jy))
      rm_moon += 0.0572 * Math.sin(Const::K * norm_angle(103.21  +  3773.363  * jy))
      rm_moon += 0.0588 * Math.sin(Const::K * norm_angle(214.22  +   638.635  * jy))
      rm_moon += 0.1143 * Math.sin(Const::K * norm_angle(  6.546 +  9664.0404 * jy))
      rm_moon += 0.1856 * Math.sin(Const::K * norm_angle(177.525 +   359.9905 * jy))
      rm_moon += 0.2136 * Math.sin(Const::K * norm_angle(269.926 +  9543.9773 * jy))
      rm_moon += 0.6583 * Math.sin(Const::K * norm_angle(235.700 +  8905.3422 * jy))
      rm_moon += 1.2740 * Math.sin(Const::K * norm_angle(100.738 +  4133.3536 * jy))
      rm_moon += 6.2887 * Math.sin(Const::K * norm_angle(134.961 +  4771.9886 * jy + am))
      rm_moon += norm_angle(218.3161 + 4812.67881 * jy)
      return norm_angle(rm_moon)
    end

    #=========================================================================
    # 月齢(正午)の計算
    #
    # @param:  jd (ユリウス日(JST))
    # @return: moonage
    #=========================================================================
    def compute_moonage(jd)
      return jd - compute_saku(jd)
    end

    #=========================================================================
    # 旧暦の計算
    #
    # * 旧暦一日の六曜
    #     １・７月   : 先勝
    #     ２・８月   : 友引
    #     ３・９月   : 先負
    #     ４・１０月 : 仏滅
    #     ５・１１月 : 大安
    #     ６・１２月 : 赤口
    #   と決まっていて、あとは月末まで順番通り。
    #   よって、月と日をたした数を６で割った余りによって六曜を決定することができます。
    #   ( 旧暦の月 ＋ 旧暦の日 ) ÷ 6 ＝ ？ … 余り
    #   余り 0 : 大安
    #        1 : 赤口
    #        2 : 先勝
    #        3 : 友引
    #        4 : 先負
    #        5 : 仏滅
    #
    # @param:  jd (ユリウス日(JST))
    # @return: [旧暦年, 閏月Flag, 旧暦月, 旧暦日, 六曜]
    #=========================================================================
    def compute_oc(jd)
      jd -= 0.5
      tm0 = jd
      # 二分二至,中気の時刻･黄経用配列宣言
      chu = Array.new(4).map { Array.new(2, 0) }
      # 朔用配列宣言
      saku = Array.new(5, 0)
      # 朔日用配列宣言
      m = Array.new(5).map { Array.new(3, 0) }
      # 旧暦用配列宣言
      kyureki = Array.new(4, 0)

      # 計算対象の直前にあたる二分二至の時刻を計算
      #   chu[0][0] : 二分二至の時刻
      #   chu[0][1] : その時の太陽黄経
      chu[0] = compute_last_nc(tm0, 90)
      # 中気の時刻を計算 ( 3回計算する )
      #   chu[i][0] : 中気の時刻
      #   chu[i][1] : その時の太陽黄経
      1.upto(3) do |i|
        chu[i] = compute_last_nc(chu[i - 1][0] + 32, 30)
      end
      # 計算対象の直前にあたる二分二至の直前の朔の時刻を求める
      saku[0] = compute_saku(chu[0][0])
      # 朔の時刻を求める
      1.upto(4) do |i|
        tm = saku[i-1] + 30
        saku[i] = compute_saku(tm)
        # 前と同じ時刻を計算した場合( 両者の差が26日以内 )には、初期値を
        # +33日にして再実行させる。
        if (saku[i-1].truncate - saku[i].truncate).abs <= 26
          saku[i] = compute_saku(saku[i-1] + 35)
        end
      end
      # saku[1]が二分二至の時刻以前になってしまった場合には、朔をさかのぼり過ぎ
      # たと考えて、朔の時刻を繰り下げて修正する。
      # その際、計算もれ（saku[4]）になっている部分を補うため、朔の時刻を計算
      # する。（近日点通過の近辺で朔があると起こる事があるようだ...？）
      if saku[1].truncate <= chu[0][0].truncate
        0.upto(3) { |i| saku[i] = saku[i+1] }
        saku[4] = compute_saku(saku[3] + 35)
      # saku[0]が二分二至の時刻以後になってしまった場合には、朔をさかのぼり足
      # りないと見て、朔の時刻を繰り上げて修正する。
      # その際、計算もれ（saku[0]）になっている部分を補うため、朔の時刻を計算
      # する。（春分点の近辺で朔があると起こる事があるようだ...？）
      elsif saku[0].truncate > chu[0][0].truncate
        4.downto(1) { |i| saku[i] = saku[i-1] }
        saku[0] = compute_saku(saku[0] - 27)
      end
      # 閏月検索Flagセット
      # （節月で４ヶ月の間に朔が５回あると、閏月がある可能性がある。）
      # leap=0:平月  leap=1:閏月
      leap = 0
      leap = 1 if saku[4].truncate <= chu[3][0].truncate
      # 朔日行列の作成
      # m[i][0] ... 月名 ( 1:正月 2:２月 3:３月 .... )
      # m[i][1] ... 閏フラグ ( 0:平月 1:閏月 )
      # m[i][2] ... 朔日のjd
      m[0][0] = (chu[0][1] / 30.0).truncate + 2
      m[0][0] -= 12 if m[0][0] > 12
      m[0][2] = saku[0].truncate
      m[0][1] = 0
      1.upto(4) do |i|
        if leap == 1 && i != 1
          if chu[i-1][0].truncate <= saku[i-1].truncate ||
             chu[i-1][0].truncate >= saku[i].truncate
            m[i-1][0] = m[i-2][0]
            m[i-1][1] = 1
            m[i-1][2] = saku[i-1].truncate
            leap = 0
          end
        end
        m[i][0] = m[i-1][0] + 1
        m[i][0] -= 12 if m[i][0] > 12
        m[i][2] = saku[i].truncate
        m[i][1] = 0
      end
      # 朔日行列から旧暦を求める。
      state, index = 0, 0
      0.upto(4) do |i|
        index = i
        if tm0.truncate < m[i][2].truncate
          state = 1
          break
        elsif tm0.truncate == m[i][2].truncate
          state = 2
          break
        end
      end
      index -= 1 if state == 1
      kyureki[1] = m[index][1]
      kyureki[2] = m[index][0]
      kyureki[3] = tm0.truncate - m[index][2].truncate + 1
      # 旧暦年の計算
      # （旧暦月が10以上でかつ新暦月より大きい場合には、
      #   まだ年を越していないはず...）
      a = jd2ymd(tm0)
      kyureki[0] = a[0]
      kyureki[0] -= 1 if kyureki[2] > 9 && kyureki[2] > a[1]
      # 六曜
      kyureki[4] = Const::ROKUYO[(kyureki[2] + kyureki[3]) % 6]
      return kyureki
    end

    #=========================================================================
    # Gregorian Calendar -> Julian Day
    #
    # * フリーゲルの公式を使用する
    #   [ JD ] = int( 365.25 × year )
    #          + int( year / 400 )
    #          - int( year / 100 )
    #          + int( 30.59 ( month - 2 ) )
    #          + day
    #          + 1721088
    #   ※上記の int( x ) は厳密には、x を超えない最大の整数
    #     ( ちなみに、[ 準JD ]を求めるなら + 1721088.5 が - 678912 となる )
    #
    # @param:  year
    # @param:  month
    # @param:  day
    # @param:  hour
    # @param:  minute
    # @param:  second
    # @return: jd ( ユリウス日 )
    #=========================================================================
    def gc2jd(year, month, day, hour = 0, min = 0, sec = 0)
      # 1月,2月は前年の13月,14月とする
      if month < 3
        year  -= 1
        month += 12
      end
      # 日付(整数)部分計算
      jd  = (365.25 * year).truncate
      jd += (year / 400.0).truncate
      jd -= (year / 100.0).truncate
      jd += (30.59 * (month - 2)).truncate
      jd += day
      jd += 1721088.125
      # 時間(小数)部分計算
      t  = sec / 3600.0
      t += min / 60.0
      t += hour
      t  = t / 24.0
      return jd + t
    end

    #=========================================================================
    # Julian Day -> UT
    #
    # @param: jd (ユリウス日)
    # @return: [year, month, day, hour, minute, second]
    #=========================================================================
    def jd2ymd(jd)
      ut = Array.new(6, 0)
      x0 = (jd + 68570).truncate
      x1 = (x0 / 36524.25).truncate
      x2 = x0 - (36524.25 * x1 + 0.75).truncate
      x3 = ((x2 + 1) / 365.2425).truncate
      x4 = x2 - (365.25 * x3).truncate + 31
      x5 = (x4.truncate / 30.59).truncate
      x6 = (x5.truncate / 11.0).truncate
      ut[2] = x4 - (30.59 * x5).truncate
      ut[1] = x5 - 12 * x6 + 2
      ut[0] = 100 * (x1 - 49) + x3 + x6
      # 2月30日の補正
      if ut[1]==2 && ut[2] > 28
        if ut[0] % 100 == 0 && ut[0] % 400 == 0
          ut[2] = 29
        elsif ut[0] % 4 == 0
          ut[2] = 29
        else
          ut[2] = 28
        end
      end
      tm = 86400 * (jd - jd.truncate)
      ut[3] = (tm / 3600.0).truncate
      ut[4] = ((tm - 3600 * ut[3]) / 60.0).truncate
      ut[5] = (tm - 3600 * ut[3] - 60 * ut[4]).truncate
      return ut
    end

    #=========================================================================
    # 直前二分二至・中気時刻の計算
    #
    # @param: jd  (ユリウス日)
    # @param: kbn (90: 二分二至, 30: 中気)
    # @return: [二分二至・中気の時刻, その時の黄経]
    #=========================================================================
    def compute_last_nc(jd, kbn)
      jd -= 0.5
      # 時刻引数を分解
      tm1  = jd.truncate  # 整数部分
      tm2  = jd - tm1     # 小数部分
      tm2 -= Const::JST_D

      # 直前の二分二至の黄経 λsun0 を求める
      rm_sun  = compute_lambda_sun(jd + 0.5)
      rm_sun0 = kbn * (rm_sun / kbn.to_f).truncate

      # 繰り返し計算によって直前の二分二至の時刻を計算する
      # （誤差が±1.0 sec以内になったら打ち切る。）
      delta_t1 = 0 ; delta_t2 = 1
      while (delta_t1 + delta_t2).abs > (1.0 / 86400.0)
        # λsun を計算
        t = tm1 + tm2 + Const::JST_D + 0.5
        rm_sun = compute_lambda_sun(t)

        # 黄経差 Δλ＝λsun －λsun0
        delta_rm = rm_sun - rm_sun0

        # Δλの引き込み範囲（±180°）を逸脱した場合には、補正を行う
        case
        when delta_rm >  180; delta_rm -= 360
        when delta_rm < -180; delta_rm += 360
        end

        # 時刻引数の補正値 Δt
        delta_t1  = (delta_rm * 365.2 / 360.0).truncate
        delta_t2  = delta_rm * 365.2 / 360.0 - delta_t1

        # 時刻引数の補正
        tm1 = tm1 - delta_t1
        tm2 = tm2 - delta_t2
        if tm2 < 0
          tm2 += 1
          tm1 -= 1
        end
      end

      # nibun_chu[0] : 時刻引数を合成、DT ==> JST 変換を行い、戻り値とする
      #                ( 補正時刻=0.0sec と仮定して計算 )
      # nibun_chu[1] : 黄経
      nibun_chu = Array.new(2, 0)
      nibun_chu[0]  = tm2 + 9 / 24.0
      nibun_chu[0] += tm1
      nibun_chu[1]  = rm_sun0
      return nibun_chu
    end

    #=========================================================================
    # 角度の正規化
    #
    # @param:  angle
    # @return: angle
    #=========================================================================
    def norm_angle(angle)
      if angle < 0
        angle1  = angle * (-1)
        angle2  = (angle1 / 360.0).truncate
        angle1 -= 360 * angle2
        angle1  = 360 - angle1
      else
        angle1  = (angle / 360.0).truncate
        angle1  = angle - 360.0 * angle1
      end
      return angle1
    end

    #=========================================================================
    # 直近の朔の時刻（JST）の計算
    #
    # @param:  jd (ユリウス日)
    # @return: saku (直前の朔の時刻)
    #=========================================================================
    def compute_saku(jd)
      jd -= 0.5
      lc = 1

      # 時刻引数を分解する
      tm1 = jd.truncate
      tm2 = jd - tm1
      tm2 -= Const::JST_D

      # 繰り返し計算によって朔の時刻を計算する
      # (誤差が±1.0 sec以内になったら打ち切る。)
      delta_t1 = 0 ; delta_t2 = 1
      while (delta_t1 + delta_t2).abs > (1.0 / 86400.0)
        # 太陽の黄経λsun ,月の黄経λmoon を計算
        t = tm1 + tm2 + Const::JST_D + 0.5
        rm_sun  = compute_lambda_sun(t)
        rm_moon = compute_lambda_moon(t)
        # 月と太陽の黄経差Δλ
        # Δλ＝λmoon－λsun
        delta_rm = rm_moon - rm_sun
        # ﾙｰﾌﾟの1回目 ( lc = 1 ) で delta_rm < 0.0 の場合には引き込み範囲に
        # 入るように補正する
        if lc == 1 && delta_rm < 0
          delta_rm = norm_angle(delta_rm)
        #   春分の近くで朔がある場合 ( 0 ≦λsun≦ 20 ) で、月の黄経λmoon≧300 の
        #   場合には、Δλ＝ 360.0 － Δλ と計算して補正する
        elsif rm_sun >= 0 && rm_sun <= 20 && rm_moon >= 300
          delta_rm = norm_angle(delta_rm)
          delta_rm = 360 - delta_rm
        # Δλの引き込み範囲 ( ±40° ) を逸脱した場合には、補正を行う
        elsif delta_rm.abs > 40.0
          delta_rm = norm_angle(delta_rm)
        end
        # 時刻引数の補正値 Δt
        delta_t1  = (delta_rm * 29.530589 / 360.0).truncate
        delta_t2  = delta_rm * 29.530589 / 360.0 - delta_t1
        # 時刻引数の補正
        tm1 = tm1 - delta_t1
        tm2 = tm2 - delta_t2
        if tm2 < 0
          tm2 += 1
          tm1 -= 1
        end
        # ループ回数が15回になったら、初期値 tm を tm-26 とする。
        if lc == 15 && (delta_t1 + delta_t2).abs > (1.0 / 86400.0)
          tm1 = (jd - 26).truncate
          tm2 = 0
        # 初期値を補正したにも関わらず、振動を続ける場合には初期値を答えとして
        # 返して強制的にループを抜け出して異常終了させる。
        elsif lc > 30 && (delta_t1+delta_t2).abs > (1.0 / 86400.0)
          tm1 = jd
          tm2 = 0
          break
        end
        lc += 1
      end
      # 時刻引数を合成、DT ==> JST 変換を行い、戻り値とする
      # （補正時刻=0.0sec と仮定して計算）
      return tm2 + tm1 + 9 / 24.0
    end

    #=========================================================================
    # ΔT の計算
    #
    # * 1972-01-01 以降、うるう秒挿入済みの年+αまでは、以下で算出
    #     TT - UTC = ΔT + DUT1 = TAI + 32.184 - UTC = ΔAT + 32.184
    #   [うるう秒実施日一覧](http://jjy.nict.go.jp/QandA/data/leapsec.html)
    #
    # @param:  year
    # @param:  month
    # @param:  day
    # @return: dt
    #=========================================================================
    def compute_dt(year, month, day)
      ym = sprintf("%04d-%02d", year, month)
      y = year + (month - 0.5) / 12
      case
      when year < -500
        t = (y - 1820) / 100.0
        dt  = -20 + 32 * t ** 2
      when -500 <= year && year < 500
        t = y / 100.0
        dt  = 10583.6
             (-1014.41        + \
             (   33.78311     + \
             (   -5.952053    + \
             (   -0.1798452   + \
             (    0.022174192 + \
             (    0.0090316521) \
             * t) * t) * t) * t) * t) * t
      when 500 <= year && year < 1600
        t = (y - 1000) / 100.0
        dt  = 1574.2         + \
             (-556.01        + \
             (  71.23472     + \
             (   0.319781    + \
             (  -0.8503463   + \
             (  -0.005050998 + \
             (   0.0083572073) \
             * t) * t) * t) * t) * t) * t
      when 1600 <= year && year < 1700
        t = y - 1600
        dt  = 120           + \
             ( -0.9808      + \
             ( -0.01532     + \
             (  1.0 / 7129.0) \
             * t) * t) * t
      when 1700 <= year && year < 1800
        t = y - 1700
        dt  =  8.83           + \
             ( 0.1603         + \
             (-0.0059285      + \
             ( 0.00013336     + \
             (-1.0 / 1174000.0) \
             * t) * t) * t) * t
      when 1800 <= year && year < 1860
        t = y - 1800
        dt  = 13.72          + \
             (-0.332447      + \
             ( 0.0068612     + \
             ( 0.0041116     + \
             (-0.00037436    + \
             ( 0.0000121272  + \
             (-0.0000001699  + \
             ( 0.000000000875) \
             * t) * t) * t) * t) * t) * t) * t
      when 1860 <= year && year < 1900
        t = y - 1860
        dt  =  7.62          + \
             ( 0.5737        + \
             (-0.251754      + \
             ( 0.01680668    + \
             (-0.0004473624  + \
             ( 1.0 / 233174.0) \
             * t) * t) * t) * t) * t
      when 1900 <= year && year < 1920
        t = y - 1900
        dt  = -2.79      + \
             ( 1.494119  + \
             (-0.0598939 + \
             ( 0.0061966 + \
             (-0.000197  ) \
             * t) * t) * t) * t
      when 1920 <= year && year < 1941
        t = y - 1920
        dt  = 21.20     + \
             ( 0.84493  + \
             (-0.076100 + \
             ( 0.0020936) \
             * t) * t) * t
      when 1941 <= year && year < 1961
        t = y - 1950
        dt  = 29.07      + \
             ( 0.407     + \
             (-1 / 233.0 + \
             ( 1 / 2547.0) \
             * t) * t) * t
      when 1961 <= year && year < 1986
        case
        when ym < sprintf("%04d-%02d-%02d", 1972, 1, 1)
          t = y - 1975
          dt = 45.45      + \
              ( 1.067     + \
              (-1 / 260.0 + \
              (-1 / 718.0)  \
              * t) * t) * t
        # NICT Ver.
        when ym < sprintf("%04d-%02d", 1972, 7); dt = Const::TT_TAI + 10
        when ym < sprintf("%04d-%02d", 1973, 1); dt = Const::TT_TAI + 11
        when ym < sprintf("%04d-%02d", 1974, 1); dt = Const::TT_TAI + 12
        when ym < sprintf("%04d-%02d", 1975, 1); dt = Const::TT_TAI + 13
        when ym < sprintf("%04d-%02d", 1976, 1); dt = Const::TT_TAI + 14
        when ym < sprintf("%04d-%02d", 1977, 1); dt = Const::TT_TAI + 15
        when ym < sprintf("%04d-%02d", 1978, 1); dt = Const::TT_TAI + 16
        when ym < sprintf("%04d-%02d", 1979, 1); dt = Const::TT_TAI + 17
        when ym < sprintf("%04d-%02d", 1980, 1); dt = Const::TT_TAI + 18
        when ym < sprintf("%04d-%02d", 1981, 7); dt = Const::TT_TAI + 19
        when ym < sprintf("%04d-%02d", 1982, 7); dt = Const::TT_TAI + 20
        when ym < sprintf("%04d-%02d", 1983, 7); dt = Const::TT_TAI + 21
        when ym < sprintf("%04d-%02d", 1985, 7); dt = Const::TT_TAI + 22
        when ym < sprintf("%04d-%02d", 1988, 1); dt = Const::TT_TAI + 23
        end
      when 1986 <= year && year < 2005
        #t = y - 2000
        #dt  = 63.86         + \
        #     ( 0.3345       + \
        #     (-0.060374     + \
        #     ( 0.0017275    + \
        #     ( 0.000651814  + \
        #     ( 0.00002373599) \
        #     * t) * t) * t) * t) * t
        # NICT Ver.
        case
        when ym < sprintf("%04d-%02d", 1988, 1); dt = Const::TT_TAI + 23
        when ym < sprintf("%04d-%02d", 1990, 1); dt = Const::TT_TAI + 24
        when ym < sprintf("%04d-%02d", 1991, 1); dt = Const::TT_TAI + 25
        when ym < sprintf("%04d-%02d", 1992, 7); dt = Const::TT_TAI + 26
        when ym < sprintf("%04d-%02d", 1993, 7); dt = Const::TT_TAI + 27
        when ym < sprintf("%04d-%02d", 1994, 7); dt = Const::TT_TAI + 28
        when ym < sprintf("%04d-%02d", 1996, 1); dt = Const::TT_TAI + 29
        when ym < sprintf("%04d-%02d", 1997, 7); dt = Const::TT_TAI + 30
        when ym < sprintf("%04d-%02d", 1999, 1); dt = Const::TT_TAI + 31
        when ym < sprintf("%04d-%02d", 2006, 1); dt = Const::TT_TAI + 32
        end
      when 2005 <= year && year < 2050
        case
        when ym < sprintf("%04d-%02d", 2006, 1); dt = Const::TT_TAI + 32
        when ym < sprintf("%04d-%02d", 2009, 1); dt = Const::TT_TAI + 33
        when ym < sprintf("%04d-%02d", 2012, 7); dt = Const::TT_TAI + 34
        when ym < sprintf("%04d-%02d", 2015, 7); dt = Const::TT_TAI + 35
        when ym < sprintf("%04d-%02d", 2018, 1); dt = Const::TT_TAI + 36  # <= 第27回うるう秒実施までの暫定措置
        else
          t = y - 2000
          dt  = 62.92    + \
               ( 0.32217 + \
               ( 0.005589) \
               * t) * t
        end
      when 2050 <= year && year <= 2150
        dt  = -20 \
            + 32 * ((y - 1820) / 100.0) ** 2
            - 0.5628 * (2150 - y)
      when 2150 < year
        t = (y - 1820) / 100.0
        dt  = -20 + 32 * t ** 2
      end
      return dt
    end

    #=========================================================================
    # 六曜の計算
    #
    #
    # @param:  oc_month (旧暦の月)
    # @param:  oc_day   (旧暦の日)
    # @return: rokuyo (漢字2文字)
    #=========================================================================
    def compute_rokuyo(oc_month, oc_day)
      return Const::ROKUYO[(oc_month + oc_day) % 6]
    end
  end
end

