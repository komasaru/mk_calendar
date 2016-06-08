require "spec_helper"

describe MkCalendar::Const do
  context "USAGE" do
    it do
      expect(MkCalendar::Const::USAGE).to \
      eq "[USAGE] `MkCalendar.new(半角数字８桁)` or `MkCalendar.new`"
    end
  end

  context "MSG_ERR_1" do
    it do
      expect(MkCalendar::Const::MSG_ERR_1).to \
      eq "[ERROR] 妥当な日付ではありません。"
    end
  end

  context "PI" do
    it do
      expect(MkCalendar::Const::PI).to \
      be_within(1.0e-21).of(3.141592653589793238462)
    end
  end

  context "K" do
    it do
      expect(MkCalendar::Const::K).to \
      be_within(1.0e-18).of(0.017453292519943295)
    end
  end

  context "JST_D" do
    it do
      expect(MkCalendar::Const::JST_D).to \
      be_within(1.0e-3).of(0.375)
    end
  end

  context "YOBI" do
    it do
      expect(MkCalendar::Const::YOBI).to \
      match(["日", "月", "火", "水", "木", "金", "土"])
    end
  end

  context "ROKUYO" do
    it do
      expect(MkCalendar::Const::ROKUYO).to \
      match(["大安", "赤口", "先勝", "友引", "先負", "仏滅"])
    end
  end

  context "KANSHI" do
    it do
      expect(MkCalendar::Const::KANSHI).to \
      match([
        "甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉",
        "甲戌", "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛巳", "壬午", "癸未",
        "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳",
        "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", "庚子", "辛丑", "壬寅", "癸卯",
        "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", "壬子", "癸丑",
        "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"
      ])
    end
  end

  context "SEKKI_24" do
    it do
      expect(MkCalendar::Const::SEKKI_24).to \
      match([
        "春分", "清明", "穀雨", "立夏", "小満", "芒種",
        "夏至", "小暑", "大暑", "立秋", "処暑", "白露",
        "秋分", "寒露", "霜降", "立冬", "小雪", "大雪",
        "冬至", "小寒", "大寒", "立春", "雨水", "啓蟄"
      ])
    end
  end

  context "SEKKU" do
    it do
      expect(MkCalendar::Const::SEKKU).to \
      match([
        [0, 1, 7, "人日"],
        [1, 3, 3, "上巳"],
        [2, 5, 5, "端午"],
        [3, 7, 7, "七夕"],
        [4, 9, 9, "重陽"]
      ])
    end
  end

  context "ZASSETSU" do
    it do
      expect(MkCalendar::Const::ZASSETSU).to \
      match([
        "節分"      , "彼岸入(春)", "彼岸(春)"  , "彼岸明(春)",
        "社日(春)"  , "土用入(春)", "八十八夜"  , "入梅"      ,
        "半夏生"    , "土用入(夏)", "二百十日"  , "二百二十日",
        "彼岸入(秋)", "彼岸(秋)"  , "彼岸明(秋)", "社日(秋)"  ,
        "土用入(秋)", "土用入(冬)"
      ])
    end
  end

  context "HOLIDAY" do
    it do
      expect(MkCalendar::Const::HOLIDAY).to \
      match([
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
      ])
    end
  end
end

