require 'spec_helper'

describe 'CustomerOrder' do
  describe :create do
    it "should create new Order with values" do
      order = MoySklad::Model::CustomerOrder.new
      order.name = "12345 - api test"
      order.targetAgentUuid = TGT_AGENT
      order.sourceStoreUuid = SRC_STORE
      order.sourceAgentUuid = SRC_AGENT
      expect(order.save).to eq(true)
      expect(order.uuid.length).to eq(36)
      uuid = order.uuid

      order = MoySklad::Model::CustomerOrder.find(uuid)
      expect(order.name).to eq("12345 - api test")
      expect(order.targetAgentUuid).to eq(TGT_AGENT)
      expect(order.sourceStoreUuid).to eq(SRC_STORE)
      expect(order.sourceAgentUuid).to eq(SRC_AGENT)

      customer = MoySklad::Model::Company.find(order.sourceAgentUuid)
      expect(customer.name).to eq("Елена Лосенко")
      order.destroy
      expect{MoySklad::Model::CustomerOrder.find(uuid)}.to raise_error(ActiveResource::ResourceNotFound)
    end

    it "should create order with items and check cost" do
      order = MoySklad::Model::CustomerOrder.new
      order.name = "12345 - api test [items]"
      order.applicable = true
      order.targetAgentUuid = TGT_AGENT
      order.sourceStoreUuid = SRC_STORE
      order.sourceAgentUuid = SRC_AGENT
      order.stateUuid = CONFIRMED_UUID
      order.sum.sum = "100"
      order.sum.sumInCurrency = "100"

      KNOWN_ITEMS.each do |id, info|
        order.addItem(id, {quantity: info[:quantity],
            basePrice: { sum: info[:price] * 100, sumInCurrency: info[:price] * 100},
            price: { sum: info[:price] * 100, sumInCurrency: info[:price] * 100}})
      end

      ORDER_OPTIONS.each do |type, opt|
        order.set_attribute({uuid: opt[:key], value: :entityValueUuid}, opt[:value])
      end

      expect(order.save).to eq(true)
      expect(order.uuid.length).to eq(36)
      uuid = order.uuid

      order = MoySklad::Model::CustomerOrder.find(uuid)
      expect(order.name).to eq("12345 - api test [items]")
      expect(order.targetAgentUuid).to eq(TGT_AGENT)
      expect(order.sourceStoreUuid).to eq(SRC_STORE)
      expect(order.sourceAgentUuid).to eq(SRC_AGENT)
      expect(order.stateUuid).to eq(CONFIRMED_UUID)

      ORDER_OPTIONS.each do |type, opt|
        expect(order.get_attribute(opt[:key]).entityValueUuid).to eq(opt[:value])
      end

      # This is NORMAL, order sum is always zero :D
      expect(order.sum.sum).to eq("4.744008E7")
      expect(order.sum.sumInCurrency).to eq("4.744008E7")

      expect(order.customerOrderPosition.length).to eq(KNOWN_ITEMS.keys.length)
      customer = MoySklad::Model::Company.find(order.sourceAgentUuid)
      expect(customer.name).to eq("Елена Лосенко")

      order.destroy
      expect{MoySklad::Model::CustomerOrder.find(uuid)}.to raise_error(ActiveResource::ResourceNotFound)

    end
  end
end
