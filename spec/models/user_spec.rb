require 'spec_helper'

describe User do
  before :each do
    @address = "24 Bruce Road, Glenbrook, NSW"
    @attributes = {:email => "matthew@openaustralia.org", :address => @address,
      :area_size_meters => 200}
    # Unless we override this elsewhere just stub the geocoder to return coordinates of address above
    @loc = Location.new(-33.772609, 150.624263)
    @loc.stub!(:country_code).and_return("AU")
    @loc.stub!(:full_address).and_return("24 Bruce Rd, Glenbrook NSW 2773")
    @loc.stub!(:accuracy).and_return(8)
    @loc.stub!(:all).and_return([@loc])
    Location.stub!(:geocode).and_return(@loc)
  end

  it "should have no trouble creating a user with valid attributes" do
    User.create!(@attributes)
  end
  
  describe "geocoding" do
    it "should happen automatically on saving" do
      user = User.create!(@attributes)
      user.lat.should == @loc.lat
      user.lng.should == @loc.lng
    end

    it "should error if the address is empty" do
      Location.stub!(:geocode).and_return(mock(:lat => nil, :lng => nil, :full_address => ""))
      @attributes[:address] = ""
      u = User.new(@attributes)
      u.should_not be_valid
      u.errors.on(:street_address).should == "can't be empty"
    end
    
    it "should error if the street address is not in australia" do
      @loc.stub!(:country_code).and_return("US")
      @attributes[:address] = "New York"
      u = User.new(@attributes)
      u.should_not be_valid
      u.errors.on(:street_address).should == "isn't in Australia"
    end

    it "should error if there are multiple matches from the geocoder" do
      @loc.stub!(:all).and_return([@loc, nil])
      @loc.stub!(:full_address).and_return("Bruce Rd, VIC 3885, Australia")

      @attributes[:address] = "Bruce Road"
      u = User.new(@attributes)
      u.should_not be_valid
      u.errors.on(:street_address).should == "isn't complete. Please enter a full street address, including suburb and state, e.g. Bruce Rd, VIC 3885"
    end

    it "should error if the address is not a full street address but rather a suburb name or similar" do
      @loc.stub!(:accuracy).and_return(5)
      @loc.stub!(:full_address).and_return("Glenbrook NSW")

      @attributes[:address] = "Glenbrook, NSW"
      u = User.new(@attributes)
      u.should_not be_valid
      u.errors.on(:street_address).should == "isn't complete. We saw that address as \"Glenbrook NSW\" which we don't recognise as a full street address. Check your spelling and make sure to include suburb and state"
    end
    
    it "should replace the address with the full resolved address obtained by geocoding" do
      @attributes[:address] = "24 Bruce Road, Glenbrook"
      u = User.new(@attributes)
      u.save!
      u.address.should == "24 Bruce Rd, Glenbrook NSW 2773"
    end
  end

  describe "email address" do
    it "should be valid" do
      @attributes[:email] = "diddle@"
      u = User.new(@attributes)
      u.should_not be_valid
      u.errors.on(:email_address).should == "isn't valid"    
    end
  end
  
  it "should be able to store the attribute location" do
    u = User.new
    u.location = Location.new(1.0, 2.0)
    u.lat.should == 1.0
    u.lng.should == 2.0
    u.location.lat.should == 1.0
    u.location.lng.should == 2.0
  end
  
  it "should handle location being nil" do
    u = User.new
    u.location = nil
    u.lat.should be_nil
    u.lng.should be_nil
    u.location.should be_nil
  end
  
  describe "area_size_meters" do
    it "should have a number" do
      @attributes[:area_size_meters] = "a"
      u = User.new(@attributes)
      u.should_not be_valid
      u.errors.on(:area_size_meters).should == "isn't selected"
    end
  
    it "should be greater than zero" do
      @attributes[:area_size_meters] = "0"
      u = User.new(@attributes)
      u.should_not be_valid
      u.errors.on(:area_size_meters).should == "isn't selected"    
    end
  end

  describe "confirm_id" do
    it "should be a string" do
      u = User.create!(@attributes)
      u.confirm_id.should be_instance_of(String)
    end
  
    it "should not be the the same for two different users" do
      u1 = User.create!(@attributes)
      u2 = User.create!(@attributes)
      u1.confirm_id.should_not == u2.confirm_id
    end
    
    it "should only have hex characters in it and be exactly twenty characters long" do
      u = User.create!(@attributes)
      u.confirm_id.should =~ /^[0-9a-f]{20}$/
    end
  end
  
  describe "confirmed" do
    it "should be false when alert is created" do
      u = User.create!(@attributes)
      u.confirmed.should be_false
    end
    
    it "should be able to be set to false" do
      u = User.new(@attributes)
      u.confirmed = false
      u.save!
      u.confirmed.should == false
    end
    
    it "should be able to set to true" do
      u = User.new(@attributes)
      u.confirmed = true
      u.save!
      u.confirmed.should == true
    end
  end
end
