require 'spec_helper'

describe Category do
  before :each do
    @category = FactoryGirl.create :category, :name => "Category 1", :url_match => "category_1"
  end

  it "is valid with valid attributes" do
    @category.should be_valid
  end

  it "is not valid without name" do
    @category.name = nil
    @category.should_not be_valid
  end

  it "is not valid without url_match" do
    @category.url_match = nil
    @category.should_not be_valid
  end

  describe "format of url_match" do
    it "is valid when have no slashes" do
      @category.url_match = "some/path"
      @category.should_not be_valid
      @category.url_match = "some\\path"
      @category.should_not be_valid
    end

    it "is valid when #path returns valid url" do
      @category.stub(:path).and_return "wrong path!"
      @category.should_not be_valid
    end

    it "is valid when #path have no host and qs parts" do
      @category.stub(:path).and_return "http://www.domain.ru/some/path"
      @category.should_not be_valid
      @category.stub(:path).and_return "some/path?query=true"
      @category.should_not be_valid
    end
  end

  describe "scope :enabled" do
    before :each do
      @disabled_category = FactoryGirl.create  :category, :name => "Category 2",
                                    :url_match => "category_2", :enabled => false
    end

    it "returns enabled categories" do
      Category.enabled.should include(@category)
    end

    it "doesn't return disabled categories"do
      Category.enabled.should_not include(@disabled_category)
    end
  end

  describe "scope :ordered" do
    it "returns categories ordered by show_order" do
      @second_category = FactoryGirl.create  :category, :name => "Category 2",
                                  :url_match => "cat_2", :show_order => -1
      Category.ordered.should == [@second_category, @category]
    end

    it "returns categories with equal show_order ordered by creation time" do
      @second_category = FactoryGirl.create  :category, :name => "Category 2", :url_match => "cat_2"
      Category.ordered.should == [@category,@second_category]
    end
  end

  describe "self.matching" do
    it "returns matching category when it present and enabled" do
      Category.matching("category_1").should == @category
    end

    it "returns nil when category present but disabled" do
      @disabled_category = FactoryGirl.create  :category, :name => "Category 2",
                                    :url_match => "category_2", :enabled => false
      Category.matching("category_2").should == nil
    end

    it "returns nil when category not present" do
      Category.matching("no-category").should == nil
    end
  end

  describe "#path" do
    it "returns path to category, based on url_match" do
      @category.path.should == "/category_1"
    end
  end
end
