require 'spec_helper'
require 'securerandom'

describe 'Good' do
  describe "create and update" do
    describe "should create item with salePrice and able to update only default" do
      before(:all) do
        item = MoySklad::Model::Good.new
        item.name = "Test item with custom prices"

        item.set_sale_price(PRICE_CUR, 100)

        item.save
        @uuid = item.uuid
      end

      after(:all) do
        MoySklad::Model::Good.find(@uuid).destroy
      end

      it "and get price" do
        item = MoySklad::Model::Good.find(@uuid)
        expect(item.get_sale_price(PRICE_CUR).value.to_f / 100).to eq(100)
      end

      it "and update CUR price (only default price can be updated)" do
        item = MoySklad::Model::Good.find(@uuid)

        item.set_sale_price(PRICE_CUR, 1000)
        expect(item.save).to eq(true)

        expect(item.get_sale_price(PRICE_CUR).value.to_f / 100).to eq(1000)
      end
    end

    describe "item with custom attributes" do
      let(:partno)  { SecureRandom.hex }
      let(:country) { SecureRandom.hex }
      let(:link)    { SecureRandom.hex }

      before(:all) do
        item = MoySklad::Model::Good.new
        item.name = "Test item with custom attributes"
        item.save
        @uuid = item.uuid
      end

      after(:all) do
        MoySklad::Model::Good.find(@uuid).destroy
      end

      it "should test empty attrs" do
        item = MoySklad::Model::Good.find(@uuid)

        expect(item.get_attribute(META_LINK[:uuid])).to be_nil
        expect(item.get_attribute(META_ARTNO)).to be_nil
        expect(item.get_attribute(META_COUNTRY)).to be_nil
        expect{item.get_attribute("foo")}.to raise_error(ArgumentError)
      end

      it "set and read attrs" do
        item = MoySklad::Model::Good.find(@uuid)

        item.set_attribute(META_COUNTRY, country)
        item.set_attribute(META_LINK, link)
        item.set_attribute(META_ARTNO, partno)

        expect(item.save).to eq(true)

        item = MoySklad::Model::Good.find(@uuid)
        expect(item.get_attribute(META_LINK)).to eq(link)
        expect(item.get_attribute(META_ARTNO)).to eq(partno)
        expect(item.get_attribute(META_COUNTRY[:uuid]).valueString).to eq(country)
      end
    end
  end
end
