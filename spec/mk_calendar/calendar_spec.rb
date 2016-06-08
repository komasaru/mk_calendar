require "spec_helper"

describe MkCalendar::Calendar do
  context "#new([2016, 6, 5])" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }

    context "object" do
      it { expect(c).to be_an_instance_of(MkCalendar::Calendar) }
    end

    context "year" do
      it { expect(c.instance_variable_get(:@year)).to eq 2016 }
    end

    context "month" do
      it { expect(c.instance_variable_get(:@month)).to eq 6 }
    end

    context "day" do
      it { expect(c.instance_variable_get(:@day)).to eq 5 }
    end

    context "jd" do
      let(:year)  { c.instance_variable_get(:@year)  }
      let(:month) { c.instance_variable_get(:@month) }
      let(:day)   { c.instance_variable_get(:@day)   }
      subject { c.send(:gc2jd, year, month, day) }
      before { subject }
      it { expect(c.jd).to be_within(1.0e-3).of(2457544.125) }
    end
  end

  context "#calc_holiday (case: holiday)" do
    let(:c) { MkCalendar::Calendar.new([2016, 5, 3]) }
    subject { c.calc_holiday }
    before { subject }
    it { expect(c.holiday).to eq "憲法記念日" }
  end

  context "#calc_holiday (case: non-holiday)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.calc_holiday }
    before { subject }
    it { expect(c.holiday).to eq "" }
  end

  context "#calc_sekki_24 (case: sekki_24)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.calc_sekki_24 }
    before { subject }
    it { expect(c.sekki_24).to eq "芒種" }
  end

  context "#calc_sekki_24 (case: non-sekki_24)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 6]) }
    subject { c.calc_sekki_24 }
    before { subject }
    it { expect(c.sekki_24).to eq "" }
  end

  context "#calc_zassetsu (case: one-zassetsu)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 10]) }
    subject { c.calc_zassetsu }
    before { subject }
    it { expect(c.zassetsu).to eq "入梅" }
  end

  context "#calc_zassetsu (case: two-zassetsu)" do
    let(:c) { MkCalendar::Calendar.new([2016, 3, 17]) }
    subject { c.calc_zassetsu }
    before { subject }
    it { expect(c.zassetsu).to eq "彼岸入(春),社日(春)" }
  end

  context "#calc_zassetsu (case: non-zassetsu)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.calc_zassetsu}
    before { subject }
    it { expect(c.zassetsu).to eq "" }
  end

  context "#calc_yobi" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 6]) }
    subject { c.calc_yobi }
    before { subject }
    it { expect(c.yobi).to eq "月" }
  end

  context "#calc_kanshi" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.calc_kanshi }
    before { subject }
    it { expect(c.kanshi).to eq "戊午" }
  end

  context "#calc_sekku (case: sekku)" do
    let(:c) { MkCalendar::Calendar.new([2016, 5, 5]) }
    subject { c.calc_sekku }
    before { subject }
    it { expect(c.sekku).to eq "端午" }
  end

  context "#calc_sekku (case: non-sekku)" do
    let(:c) { MkCalendar::Calendar.new([2016, 5, 6]) }
    subject { c.calc_sekku }
    before { subject }
    it { expect(c.sekku).to eq "" }
  end

  context "#calc_lambda_sun" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.calc_lambda_sun }
    before { subject }
    it { expect(c.lambda_sun).to be_within(1.0e-10).of(74.4085130901) }
  end

  context "#calc_lambda_moon" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.calc_lambda_moon }
    before { subject }
    it { expect(c.lambda_moon).to be_within(1.0e-10).of(67.4513755710) }
  end

  context "#calc_moonage" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.calc_moonage }
    before { subject }
    it { expect(c.moonage).to be_within(1.0e-2).of(29.31) }
  end

  context "#calc_oc (case: non-leap)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.calc_oc }
    before { subject }
    it do
      expect(c.oc_year ).to eq 2016
      expect(c.oc_leap ).to eq 0
      expect(c.oc_month).to eq 5
      expect(c.oc_day  ).to eq 1
    end
  end

  context "#calc_oc (case: leap)" do
    let(:c) { MkCalendar::Calendar.new([2014, 10, 27]) }
    subject { c.calc_oc }
    before { subject }
    it do
      expect(c.oc_year ).to eq 2014
      expect(c.oc_leap ).to eq 1
      expect(c.oc_month).to eq 9
      expect(c.oc_day  ).to eq 4
    end
  end

  context "#calc_rokuyo" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject do
      c.calc_oc
      c.calc_rokuyo
    end
    before { subject }
    it { expect(c.rokuyo).to eq "大安" }
  end

  context "#calc" do
    context "- regular day" do
      let(:c) { MkCalendar::Calendar.new([2016, 6, 6]) }
      subject { c.calc }
      before { subject }
      it do
        expect(c.instance_variable_get(:@jd         )).to be_within(1.0e-3).of(2457545.125)
        expect(c.instance_variable_get(:@jd_jst     )).to be_within(1.0e-1).of(2457545.5)
        expect(c.instance_variable_get(:@holiday    )).to eq ""
        expect(c.instance_variable_get(:@sekki_24   )).to eq ""
        expect(c.instance_variable_get(:@zassetsu   )).to eq ""
        expect(c.instance_variable_get(:@yobi       )).to eq "月"
        expect(c.instance_variable_get(:@kanshi     )).to eq "己未"
        expect(c.instance_variable_get(:@sekku      )).to eq ""
        expect(c.instance_variable_get(:@lambda_sun )).to be_within(1.0e-4).of(75.3661)
        expect(c.instance_variable_get(:@lambda_moon)).to be_within(1.0e-4).of(82.2670)
        expect(c.instance_variable_get(:@moonage    )).to be_within(1.0e-4).of(0.9999)
        expect(c.instance_variable_get(:@oc_year    )).to eq 2016
        expect(c.instance_variable_get(:@oc_leap    )).to eq 0
        expect(c.instance_variable_get(:@oc_month   )).to eq 5
        expect(c.instance_variable_get(:@oc_day     )).to eq 2
        expect(c.instance_variable_get(:@rokuyo     )).to eq "赤口"
      end
    end

    context "- special day(1)" do
      let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
      subject { c.calc }
      before { subject }
      it do
        expect(c.instance_variable_get(:@jd         )).to be_within(1.0e-3).of(2457544.125)
        expect(c.instance_variable_get(:@jd_jst     )).to be_within(1.0e-1).of(2457544.5)
        expect(c.instance_variable_get(:@holiday    )).to eq ""
        expect(c.instance_variable_get(:@sekki_24   )).to eq "芒種"
        expect(c.instance_variable_get(:@zassetsu   )).to eq ""
        expect(c.instance_variable_get(:@yobi       )).to eq "日"
        expect(c.instance_variable_get(:@kanshi     )).to eq "戊午"
        expect(c.instance_variable_get(:@sekku      )).to eq ""
        expect(c.instance_variable_get(:@lambda_sun )).to be_within(1.0e-4).of(74.4085)
        expect(c.instance_variable_get(:@lambda_moon)).to be_within(1.0e-4).of(67.4514)
        expect(c.instance_variable_get(:@moonage    )).to be_within(1.0e-4).of(29.3129)
        expect(c.instance_variable_get(:@oc_year    )).to eq 2016
        expect(c.instance_variable_get(:@oc_leap    )).to eq 0
        expect(c.instance_variable_get(:@oc_month   )).to eq 5
        expect(c.instance_variable_get(:@oc_day     )).to eq 1
        expect(c.instance_variable_get(:@rokuyo     )).to eq "大安"
      end
    end

    context "- special day(2)" do
      let(:c) { MkCalendar::Calendar.new([2016, 3, 17]) }
      subject { c.calc }
      before { subject }
      it do
        expect(c.instance_variable_get(:@jd         )).to be_within(1.0e-3).of(2457464.125)
        expect(c.instance_variable_get(:@jd_jst     )).to be_within(1.0e-1).of(2457464.5)
        expect(c.instance_variable_get(:@holiday    )).to eq ""
        expect(c.instance_variable_get(:@sekki_24   )).to eq ""
        expect(c.instance_variable_get(:@zassetsu   )).to eq "彼岸入(春),社日(春)"
        expect(c.instance_variable_get(:@yobi       )).to eq "木"
        expect(c.instance_variable_get(:@kanshi     )).to eq "戊戌"
        expect(c.instance_variable_get(:@sekku      )).to eq ""
        expect(c.instance_variable_get(:@lambda_sun )).to be_within(1.0e-4).of(356.4578)
        expect(c.instance_variable_get(:@lambda_moon)).to be_within(1.0e-4).of(97.8368)
        expect(c.instance_variable_get(:@moonage    )).to be_within(1.0e-4).of(8.0453)
        expect(c.instance_variable_get(:@oc_year    )).to eq 2016
        expect(c.instance_variable_get(:@oc_leap    )).to eq 0
        expect(c.instance_variable_get(:@oc_month   )).to eq 2
        expect(c.instance_variable_get(:@oc_day     )).to eq 9
        expect(c.instance_variable_get(:@rokuyo     )).to eq "仏滅"
      end
    end

    context "- special day(3)" do
      let(:c) { MkCalendar::Calendar.new([2016, 3, 20]) }
      subject { c.calc }
      before { subject }
      it do
        expect(c.instance_variable_get(:@jd         )).to be_within(1.0e-3).of(2457467.125)
        expect(c.instance_variable_get(:@jd_jst     )).to be_within(1.0e-1).of(2457467.5)
        expect(c.instance_variable_get(:@holiday    )).to eq "春分の日"
        expect(c.instance_variable_get(:@sekki_24   )).to eq "春分"
        expect(c.instance_variable_get(:@zassetsu   )).to eq "彼岸(春)"
        expect(c.instance_variable_get(:@yobi       )).to eq "日"
        expect(c.instance_variable_get(:@kanshi     )).to eq "辛丑"
        expect(c.instance_variable_get(:@sekku      )).to eq ""
        expect(c.instance_variable_get(:@lambda_sun )).to be_within(1.0e-4).of(359.4414)
        expect(c.instance_variable_get(:@lambda_moon)).to be_within(1.0e-4).of(136.3118)
        expect(c.instance_variable_get(:@moonage    )).to be_within(1.0e-4).of(11.0453)
        expect(c.instance_variable_get(:@oc_year    )).to eq 2016
        expect(c.instance_variable_get(:@oc_leap    )).to eq 0
        expect(c.instance_variable_get(:@oc_month   )).to eq 2
        expect(c.instance_variable_get(:@oc_day     )).to eq 12
        expect(c.instance_variable_get(:@rokuyo     )).to eq "先勝"
      end
    end

    context "- special day(4)" do
      let(:c) { MkCalendar::Calendar.new([2016, 7, 7]) }
      subject { c.calc }
      before { subject }
      it do
        expect(c.instance_variable_get(:@jd         )).to be_within(1.0e-3).of(2457576.125)
        expect(c.instance_variable_get(:@jd_jst     )).to be_within(1.0e-1).of(2457576.5)
        expect(c.instance_variable_get(:@holiday    )).to eq ""
        expect(c.instance_variable_get(:@sekki_24   )).to eq "小暑"
        expect(c.instance_variable_get(:@zassetsu   )).to eq ""
        expect(c.instance_variable_get(:@yobi       )).to eq "木"
        expect(c.instance_variable_get(:@kanshi     )).to eq "庚寅"
        expect(c.instance_variable_get(:@sekku      )).to eq "七夕"
        expect(c.instance_variable_get(:@lambda_sun )).to be_within(1.0e-4).of(104.9569)
        expect(c.instance_variable_get(:@lambda_moon)).to be_within(1.0e-4).of(132.7095)
        expect(c.instance_variable_get(:@moonage    )).to be_within(1.0e-4).of(2.6657)
        expect(c.instance_variable_get(:@oc_year    )).to eq 2016
        expect(c.instance_variable_get(:@oc_leap    )).to eq 0
        expect(c.instance_variable_get(:@oc_month   )).to eq 6
        expect(c.instance_variable_get(:@oc_day     )).to eq 4
        expect(c.instance_variable_get(:@rokuyo     )).to eq "先負"
      end
    end
  end

  context "#gc2jd" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:gc2jd, c.year, c.month, c.day, 0, 0, 0) }
    it { expect(subject).to eq 2457544.125 }
  end

  context "#jd2ymd" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:jd2ymd, c.jd_jst) }
    it { expect(subject).to match([2016, 6, 5, 12, 0, 0]) }
  end

  context "#compute_last_nc (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_last_nc, 2457478.0, 90) }
    it { expect(subject).to match([be_within(1.0e-4).of(2457467.5623), 0]) }
  end

  context "#compute_last_nc (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_last_nc, 2457499.5623189886, 30) }
    it { expect(subject).to match([be_within(1.0e-4).of(2457498.0204), 30]) }
  end

  context "#compute_saku" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_saku, c.jd) }
    it { expect(subject).to be_within(1.0e-4).of(2457515.1871) }
  end

  context "#norm_angle" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:norm_angle, 1051.4215) }
    it { expect(subject).to be_within(1.0e-4).of(331.4215) }
  end

  context "#compute_dt (case: A.D.2012)" do
    let(:c) { MkCalendar::Calendar.new([2012, 6, 1]) }
    subject { c.send(:compute_dt, c.year, c.month, c.day) }
    it { expect(subject).to be_within(1.0e-3).of(66.184) }
  end

  context "#compute_dt (case: A.D.2016)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_dt, c.year, c.month, c.day) }
    it { expect(subject).to be_within(1.0e-3).of(68.184) }
  end

  context "#compute_dt (case: A.D.2030)" do
    let(:c) { MkCalendar::Calendar.new([2030, 5, 21]) }
    subject { c.send(:compute_dt, c.year, c.month, c.day) }
    it { expect(subject).to be_within(1.0e-3).of(77.615) }
  end

  context "#compute_dt (case: A.D.1952)" do
    let(:c) { MkCalendar::Calendar.new([1952, 6, 22]) }
    subject { c.send(:compute_dt, c.year, c.month, c.day) }
    it { expect(subject).to be_within(1.0e-3).of(29.870) }
  end

  context "#compute_dt (case: A.D.500)" do
    let(:c) { MkCalendar::Calendar.new([500, 7, 25]) }
    subject { c.send(:compute_dt, c.year, c.month, c.day) }
    it { expect(subject).to be_within(1.0e-3).of(5710.045) }
  end

  context "#gc2j2000" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:gc2j2000, c.year, c.month, c.day) }
    it { expect(subject).to be_within(1.0e-3).of(5999.125) }
  end

  context "#compute_holiday (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 5, 3]) }
    subject { c.send(:compute_holiday) }
    it { expect(subject).to eq "憲法記念日" }
  end

  context "#compute_holiday (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 5, 5]) }
    subject { c.send(:compute_holiday, 2016) }
    it { expect(subject).to eq "こどもの日" }
  end

  context "#compute_holiday (3)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_holiday) }
    it { expect(subject).to eq "" }
  end

  context "#compute_holiday (4)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_holiday, 2016) }
    it { expect(subject).to eq "" }
  end

  context "#compute_sekki_24 (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_sekki_24) }
    it { expect(subject).to eq "芒種" }
  end

  context "#compute_sekki_24 (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_sekki_24, 2457467.5) }  # 2016-03-20
    it { expect(subject).to eq "春分" }
  end

  context "#compute_sekki_24 (3)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 6]) }
    subject { c.send(:compute_sekki_24) }
    it { expect(subject).to eq "" }
  end

  context "#compute_sekki_24 (4)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 6]) }
    subject { c.send(:compute_sekki_24, 2457468.5) }  # 2016-03-21
    it { expect(subject).to eq "" }
  end

  context "#compute_zassetsu (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 10]) }
    subject { c.send(:compute_zassetsu) }
    it { expect(subject).to eq "入梅" }
  end

  context "#compute_zassetsu (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_zassetsu, 2457549.5) }  # 2016-06-10
    it { expect(subject).to eq "入梅" }
  end

  context "#compute_zassetsu (3)" do
    let(:c) { MkCalendar::Calendar.new([2016, 3, 17]) }
    subject { c.send(:compute_zassetsu) }
    it { expect(subject).to eq "彼岸入(春),社日(春)" }
  end

  context "#compute_zassetsu (4)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_zassetsu, 2457464.5) }  # 2016-03-17
    it { expect(subject).to eq "彼岸入(春),社日(春)" }
  end

  context "#compute_zassetsu (5)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_zassetsu) }
    it { expect(subject).to eq "" }
  end

  context "#compute_zassetsu (6)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 10]) }
    subject { c.send(:compute_zassetsu, 2457544.5) }  # 2016-06-05
    it { expect(subject).to eq "" }
  end

  context "#compute_yobi (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 6]) }
    subject { c.send(:compute_yobi) }
    it { expect(subject).to eq "月" }
  end

  context "#compute_yobi (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 6]) }
    subject { c.send(:compute_yobi, 2457547.5) }  # 2016-06-08
    it { expect(subject).to eq "水" }
  end

  context "#compute_kanshi (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_kanshi) }
    it { expect(subject).to eq "戊午" }
  end

  context "#compute_kanshi (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_kanshi, 2457547.5) }  # 2016-06-08
    it { expect(subject).to eq "辛酉" }
  end

  context "#compute_sekku (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 5, 5]) }
    subject { c.send(:compute_sekku) }
    it { expect(subject).to eq "端午" }
  end

  context "#compute_sekku (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 8]) }
    subject { c.send(:compute_sekku, 7, 7) }
    it { expect(subject).to eq "七夕" }
  end

  context "#compute_sekku (3)" do
    let(:c) { MkCalendar::Calendar.new([2016, 5, 6]) }
    subject { c.send(:compute_sekku) }
    it { expect(subject).to eq "" }
  end

  context "#compute_sekku (4)" do
    let(:c) { MkCalendar::Calendar.new([2016, 7, 7]) }
    subject { c.send(:compute_sekku, 6, 8) }
    it { expect(subject).to eq "" }
  end

  context "#compute_lambda_sun (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_lambda_sun) }
    it { expect(subject).to be_within(1.0e-10).of(74.4085130901) }
  end

  context "#compute_lambda_sun (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_lambda_sun, 2457547.5) }  # 2016-06-08
    it { expect(subject).to be_within(1.0e-10).of(77.2804999540) }
  end

  context "#compute_lambda_moon (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_lambda_moon) }
    it { expect(subject).to be_within(1.0e-10).of(67.4513755710) }
  end

  context "#compute_lambda_moon (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_lambda_moon, 2457547.5) }  # 2016-06-08
    it { expect(subject).to be_within(1.0e-10).of(110.9388074049) }
  end

  context "#compute_moonage (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_moonage) }
    it { expect(subject).to be_within(1.0e-2).of(29.31) }
  end

  context "#compute_moonage (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_moonage, 2457547.5) }  # 2016-06-08
    it { expect(subject).to be_within(1.0e-2).of(3.00) }
  end

  context "#compute_oc (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_oc) }
    it { expect(subject).to match([2016, 0, 5, 1]) }
  end

  context "#compute_oc (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_oc, 2457547.5) }  # 2016-06-08
    it { expect(subject).to match([2016, 0, 5, 4]) }
  end

  context "#compute_oc (3)" do
    let(:c) { MkCalendar::Calendar.new([2014, 10, 27]) }
    subject { c.send(:compute_oc) }
    it { expect(subject).to match([2014, 1, 9, 4]) }
  end

  context "#compute_oc (4)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_oc, 2456957.5) }  # 2014-10-27
    it { expect(subject).to match([2014, 1, 9, 4]) }
  end

  context "#compute_oc (5)" do
    let(:c) { MkCalendar::Calendar.new([2016, 7, 3]) }
    subject { c.send(:compute_oc) }
    it { expect(subject).to match([2016, 0, 5, 29]) }
  end

  context "#compute_oc (6)" do
    let(:c) { MkCalendar::Calendar.new([2016, 7, 4]) }
    subject { c.send(:compute_oc) }
    it { expect(subject).to match([2016, 0, 6, 1]) }
  end

  context "#compute_oc (7)" do
    let(:c) { MkCalendar::Calendar.new([2017, 2, 25]) }
    subject { c.send(:compute_oc) }
    it { expect(subject).to match([2017, 0, 1, 29]) }
  end

  context "#compute_oc (8)" do
    let(:c) { MkCalendar::Calendar.new([2017, 2, 26]) }
    subject { c.send(:compute_oc) }
    it { expect(subject).to match([2017, 0, 2, 1]) }
  end

  context "#compute_oc (9)" do
    let(:c) { MkCalendar::Calendar.new([2017, 3, 27]) }
    subject { c.send(:compute_oc) }
    it { expect(subject).to match([2017, 0, 2, 30]) }
  end

  context "#compute_oc (10)" do
    let(:c) { MkCalendar::Calendar.new([2017, 3, 28]) }
    subject { c.send(:compute_oc) }
    it { expect(subject).to match([2017, 0, 3, 1]) }
  end

  context "#compute_rokuyo (1)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_rokuyo, 5, 1) }
    it { expect(subject).to eq "大安" }
  end

  context "#compute_rokuyo (2)" do
    let(:c) { MkCalendar::Calendar.new([2016, 6, 5]) }
    subject { c.send(:compute_rokuyo, 5, 4) }  # 2016-06-08
    it { expect(subject).to eq "友引" }
  end
end

