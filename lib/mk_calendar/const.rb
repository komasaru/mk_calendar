module MkCalendar
  module Const
    USAGE     = "[USAGE] `MkCalendar.new(半角数字８桁)` or `MkCalendar.new`"
    MSG_ERR_1 = "[ERROR] 妥当な日付ではありません。"
    PI = 3.141592653589793238462
    K  = 0.017453292519943295
    JST_D = 0.375  # = 9.0 / 24.0
    TT_TAI = 32.184
    YOBI   = ["日", "月", "火", "水", "木", "金", "土"]
    ROKUYO = ["大安", "赤口", "先勝", "友引", "先負", "仏滅"]
    KANSHI = [
      "甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉",
      "甲戌", "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛巳", "壬午", "癸未",
      "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳",
      "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", "庚子", "辛丑", "壬寅", "癸卯",
      "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", "壬子", "癸丑",
      "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"
    ]
    SEKKI_24 = [
      "春分", "清明", "穀雨", "立夏", "小満", "芒種",
      "夏至", "小暑", "大暑", "立秋", "処暑", "白露",
      "秋分", "寒露", "霜降", "立冬", "小雪", "大雪",
      "冬至", "小寒", "大寒", "立春", "雨水", "啓蟄"
    ]
    SEKKU = [
      [0, 1, 7, "人日"],
      [1, 3, 3, "上巳"],
      [2, 5, 5, "端午"],
      [3, 7, 7, "七夕"],
      [4, 9, 9, "重陽"]
    ]
    ZASSETSU = [
      "節分"      , "彼岸入(春)", "彼岸(春)"  , "彼岸明(春)",
      "社日(春)"  , "土用入(春)", "八十八夜"  , "入梅"      ,
      "半夏生"    , "土用入(夏)", "二百十日"  , "二百二十日",
      "彼岸入(秋)", "彼岸(秋)"  , "彼岸明(秋)", "社日(秋)"  ,
      "土用入(秋)", "土用入(冬)"
    ]
    HOLIDAY = [
      [ 0,  1,  1, 99, "元日"        ],
      [ 1,  1, 99, 21, "成人の日"    ],
      [ 2,  2, 11, 99, "建国記念の日"],
      [ 3,  3, 99, 80, "春分の日"    ],
      [ 4,  4, 29, 99, "昭和の日"    ],
      [ 5,  5,  3, 99, "憲法記念日"  ],
      [ 6,  5,  4, 99, "みどりの日"  ],
      [ 7,  5,  5, 99, "こどもの日"  ],
      [ 8,  7, 99, 31, "海の日"      ],
      [ 9,  8, 11, 99, "山の日"      ],
      [10,  9, 99, 31, "敬老の日"    ],
      [11,  9, 99, 81, "秋分の日"    ],
      [12, 10, 99, 21, "体育の日"    ],
      [13, 11,  3, 99, "文化の日"    ],
      [14, 11, 23, 99, "勤労感謝の日"],
      [15, 12, 23, 99, "天皇誕生日"  ],
      [90, 99, 99, 99, "国民の休日"  ],
      [91, 99, 99, 99, "振替休日"    ]
    ]
  end
end

