require "./spec_helper"

describe IP2Country do
  # TODO: Write tests

  it "returns lookuped country name by default language(English) from ip." do
    IP2Country.new.lookup("8.8.8.8").should eq "United States"
  end

  it "returns lookuped country name by specified language from ip" do
    IP2Country.new.lookup("8.8.8.8", "ja").should eq "アメリカ合衆国"
  end

  it "returns lookuped country name by specified default language from ip" do
    IP2Country.new("ja").lookup("8.8.8.8").should eq "アメリカ合衆国"
  end
end
