require 'spec_helper'

describe Councillor do
  describe "#prefixed_name" do
    it { expect(create(:councillor, name: "Steve").prefixed_name).to eq "local councillor Steve" }
  end

  describe "validations" do
    it { expect(Councillor.new).to_not be_valid }
    it { expect(Councillor.new(authority: create(:authority))).to_not be_valid }
    it { expect(Councillor.new(authority: create(:authority), image_url: "http://foobar.com")).to_not be_valid }

    it { expect(Councillor.new(authority: create(:authority), email: "foo@bar.com")).to be_valid }
    it { expect(Councillor.new(authority: create(:authority), email: "foo@bar.com", image_url: "https://foobar.com")).to be_valid }
  end

  describe "#writeit_id" do
    it "combines the popolo_id with the authority popolo_url" do
      expect(create(:councillor, popolo_id: "authority/foo_bar").writeit_id)
        .to eql "https://raw.githubusercontent.com/openaustralia/australian_local_councillors_popolo/master/nsw_local_councillor_popolo.json/person/authority/foo_bar"
    end
  end
end
