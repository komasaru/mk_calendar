require "spec_helper"

describe MkCalendar::Compute do
  let(:c) { MkCalendar::Compute }

  context "#gc2jd" do
    subject { c.gc2jd(2016, 6, 5) }
    it { expect(subject).to eq 2457544.125 }
  end

  context "#jd2ymd" do
    subject { c.jd2ymd(2457544.5) }
    it { expect(subject).to match([2016, 6, 5, 12, 0, 0]) }
  end

  context "#compute_last_nc (1)" do
    subject { c.compute_last_nc(2457478.0, 90) }
    it { expect(subject).to match([be_within(1.0e-4).of(2457467.5623), 0]) }
  end

  context "#compute_last_nc (2)" do
    subject { c.compute_last_nc(2457499.5623189886, 30) }
    it { expect(subject).to match([be_within(1.0e-4).of(2457498.0204), 30]) }
  end

  context "#compute_saku" do
    subject { c.compute_saku(2457544.125) }
    it { expect(subject).to be_within(1.0e-4).of(2457515.1871) }
  end

  context "#norm_angle" do
    subject { c.norm_angle(1051.4215) }
    it { expect(subject).to be_within(1.0e-4).of(331.4215) }
  end

  context "#compute_dt (case: A.D.2012)" do
    subject { c.compute_dt(2012, 6, 1) }
    it { expect(subject).to be_within(1.0e-3).of(66.184) }
  end

  context "#compute_dt (case: A.D.2016)" do
    subject { c.compute_dt(2016, 6, 5) }
    it { expect(subject).to be_within(1.0e-3).of(68.184) }
  end

  context "#compute_dt (case: A.D.2030)" do
    subject { c.compute_dt(2030, 5, 21) }
    it { expect(subject).to be_within(1.0e-3).of(77.615) }
  end

  context "#compute_dt (case: A.D.1952)" do
    subject { c.compute_dt(1952, 6, 22) }
    it { expect(subject).to be_within(1.0e-3).of(29.870) }
  end

  context "#compute_dt (case: A.D.500)" do
    subject { c.compute_dt(500, 7, 25) }
    it { expect(subject).to be_within(1.0e-3).of(5710.045) }
  end

  context "#gc2j2000" do
    subject { c.gc2j2000(2016, 6, 5) }
    it { expect(subject).to be_within(1.0e-3).of(5999.125) }
  end

  context "#compute_holiday (1)" do
    subject { c.compute_holiday(2016, 5, 3) }
    it { expect(subject).to eq "憲法記念日" }
  end

  context "#compute_holiday (2)" do
    subject { c.compute_holiday(2016, 5, 5) }
    it { expect(subject).to eq "こどもの日" }
  end

  context "#compute_holiday (3)" do
    subject { c.compute_holiday(2016, 6, 5) }
    it { expect(subject).to eq "" }
  end

  context "#compute_holiday (4)" do
    subject { c.compute_holiday(2016, 6, 5) }
    it { expect(subject).to eq "" }
  end

  context "#compute_sekki_24 (1)" do
    subject { c.compute_sekki_24(2457544.5) }  # 2016-06-05
    it { expect(subject).to eq "芒種" }
  end

  context "#compute_sekki_24 (2)" do
    subject { c.compute_sekki_24(2457467.5) }  # 2016-03-20
    it { expect(subject).to eq "春分" }
  end

  context "#compute_sekki_24 (3)" do
    subject { c.compute_sekki_24(2457545.5) }  # 2016-06-06
    it { expect(subject).to eq "" }
  end

  context "#compute_sekki_24 (4)" do
    subject { c.compute_sekki_24(2457468.5) }  # 2016-03-21
    it { expect(subject).to eq "" }
  end

  context "#compute_zassetsu (1)" do
    subject { c.compute_zassetsu(2457549.5) }  # 2016-06-10
    it { expect(subject).to eq "入梅" }
  end

  context "#compute_zassetsu (2)" do
    subject { c.compute_zassetsu(2457464.5) }  # 2016-03-17
    it { expect(subject).to eq "彼岸入(春),社日(春)" }
  end

  context "#compute_zassetsu (3)" do
    subject { c.compute_zassetsu(2457544.5) }  # 2016-06-05
    it { expect(subject).to eq "" }
  end

  context "#compute_yobi (1)" do
    subject { c.compute_yobi(2457544.5) }  # 2016-06-05
    it { expect(subject).to eq "日" }
  end

  context "#compute_yobi (2)" do
    subject { c.compute_yobi(2457547.5) }  # 2016-06-08
    it { expect(subject).to eq "水" }
  end

  context "#compute_kanshi (1)" do
    subject { c.compute_kanshi(2457544.5) }  # 2016-06-05
    it { expect(subject).to eq "戊午" }
  end

  context "#compute_kanshi (2)" do
    subject { c.compute_kanshi(2457547.5) }  # 2016-06-08
    it { expect(subject).to eq "辛酉" }
  end

  context "#compute_sekku (1)" do
    subject { c.compute_sekku(5, 5) }
    it { expect(subject).to eq "端午" }
  end

  context "#compute_sekku (2)" do
    subject { c.compute_sekku(7, 7) }
    it { expect(subject).to eq "七夕" }
  end

  context "#compute_sekku (3)" do
    subject { c.compute_sekku(6, 8) }
    it { expect(subject).to eq "" }
  end

  context "#compute_lambda_sun (1)" do
    subject { c.compute_lambda_sun(2457544.5) }  # 2016-06-05
    it { expect(subject).to be_within(1.0e-10).of(74.4085130901) }
  end

  context "#compute_lambda_sun (2)" do
    subject { c.compute_lambda_sun(2457547.5) }  # 2016-06-08
    it { expect(subject).to be_within(1.0e-10).of(77.2804999540) }
  end

  context "#compute_lambda_moon (1)" do
    subject { c.compute_lambda_moon(2457544.5) }  # 2016-06-05
    it { expect(subject).to be_within(1.0e-10).of(67.4513755710) }
  end

  context "#compute_lambda_moon (2)" do
    subject { c.compute_lambda_moon(2457547.5) }  # 2016-06-08
    it { expect(subject).to be_within(1.0e-10).of(110.9388074049) }
  end

  context "#compute_moonage (1)" do
    subject { c.compute_moonage(2457544.5) }  # 2016-06-05
    it { expect(subject).to be_within(1.0e-2).of(29.31) }
  end

  context "#compute_moonage (2)" do
    subject { c.compute_moonage(2457547.5) }  # 2016-06-08
    it { expect(subject).to be_within(1.0e-2).of(3.00) }
  end

  context "#compute_oc (1)" do
    subject { c.compute_oc(2457544.5) }  # 2016-06-05
    it { expect(subject).to match([2016, 0, 5, 1, "大安"]) }
  end

  context "#compute_oc (2)" do
    subject { c.compute_oc(2457547.5) }  # 2016-06-08
    it { expect(subject).to match([2016, 0, 5, 4, "友引"]) }
  end

  context "#compute_oc (3)" do
    subject { c.compute_oc(2456957.5) }  # 2014-10-27
    it { expect(subject).to match([2014, 1, 9, 4, "赤口"]) }
  end

  context "#compute_oc (4)" do
    subject { c.compute_oc(2457572.5) }  # 2016-07-03
    it { expect(subject).to match([2016, 0, 5, 29, "先負"]) }
  end

  context "#compute_oc (5)" do
    subject { c.compute_oc(2457573.5) }  # 2016-07-04
    it { expect(subject).to match([2016, 0, 6, 1, "赤口"]) }
  end

  context "#compute_oc (6)" do
    subject { c.compute_oc(2457809.5) }  # 2017-02-25
    it { expect(subject).to match([2017, 0, 1, 29, "大安"]) }
  end

  context "#compute_oc (7)" do
    subject { c.compute_oc(2457810.5) }  # 2017-02-26
    it { expect(subject).to match([2017, 0, 2, 1, "友引"]) }
  end

  context "#compute_oc (8)" do
    subject { c.compute_oc(2457839.5) }  # 2017-03-27
    it { expect(subject).to match([2017, 0, 2, 30, "先勝"]) }
  end

  context "#compute_oc (9)" do
    subject { c.compute_oc(2457840.5) }  # 2017-03-28
    it { expect(subject).to match([2017, 0, 3, 1, "先負"]) }
  end
end

