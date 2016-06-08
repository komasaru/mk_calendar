require "spec_helper"
require "date"

describe MkCalendar::Argument do
  context "#self.new(\"20160605\")" do
    let(:a) { MkCalendar::Argument.new("20160605") }

    context "object" do
      it { expect(a).to be_an_instance_of(MkCalendar::Argument) }
    end

    context "get_ymd" do
      subject { a.get_ymd }
      it { expect(subject).to match([2016, 6, 5]) }
    end
  end

  context "#self.new(\"201606050\")" do
    let(:a) { MkCalendar::Argument.new("201606050") }

    context "object" do
      it { expect(a).to be_an_instance_of(MkCalendar::Argument) }
    end

    context "get_ymd" do
      subject { a.get_ymd }
      it { expect(subject).to match([]) }
    end
  end

  context "#self.new(\"20160631\")" do
    let(:a) { MkCalendar::Argument.new("20160631") }

    context "object" do
      it { expect(a).to be_an_instance_of(MkCalendar::Argument) }
    end

    context "get_ymd" do
      subject { a.get_ymd }
      it { expect(subject).to match([]) }
    end
  end
end

