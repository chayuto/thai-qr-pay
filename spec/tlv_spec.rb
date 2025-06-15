# frozen_string_literal: true

# spec/tlv_spec.rb
require 'thai_qr_pay/tlv'

RSpec.describe ThaiQrPay::TLV do
  let(:raw) { '000201010211' }
  let(:tags) { ThaiQrPay::TLV.decode(raw) }

  describe '.decode' do
    it 'parses a simple TLV string into an array of Tag structs' do
      expect(tags.size).to eq(2)
      expect(tags[0].id).to eq('00')
      expect(tags[0].length).to eq(2)
      expect(tags[0].value).to eq('01')

      expect(tags[1].id).to eq('01')
      expect(tags[1].length).to eq(2)
      expect(tags[1].value).to eq('11')
    end

    it 'round-trips correctly with .encode' do
      round = ThaiQrPay::TLV.encode(tags)
      expect(round).to eq(raw)
    end
  end

  describe '.encode' do
    it 'builds a TLV string from Tag structs' do
      t0 = ThaiQrPay::TLV.tag('00', 'A1')
      t1 = ThaiQrPay::TLV.tag('01', 'BCD')
      expect(ThaiQrPay::TLV.encode([t0, t1])).to eq('0002A10103BCD')
    end
  end
end
