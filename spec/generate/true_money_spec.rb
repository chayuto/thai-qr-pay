# frozen_string_literal: true

require 'thai_qr_pay/generate/true_money'
require 'thai_qr_pay/tlv'
require 'thai_qr_pay/crc16'

RSpec.describe ThaiQrPay::Generate::TrueMoney do
  let(:mobile)  { '0812345678' }
  let(:amount)  { 123.45 }
  let(:message) { 'Hello' }

  context 'without amount or message' do
    subject(:payload) { described_class.payload(mobile_no: mobile) }

    it 'uses point-of-initiation 11' do
      tag01 = ThaiQrPay::TLV.decode(payload).find { |t| t.id == '01' }
      expect(tag01.value).to eq('11')
    end

    it 'includes correct sub-tags in Tag 29' do
      sub = ThaiQrPay::TLV.decode(payload).find { |t| t.id == '29' }
      subtags = ThaiQrPay::TLV.decode(sub.value)
      expect(subtags.find { |st| st.id == '00' }.value).to eq('A000000677010111')
      expect(subtags.find { |st| st.id == '03' }.value).to eq("14000#{mobile}")
    end

    it 'does not include Tag 54 nor Tag 81' do
      tags = ThaiQrPay::TLV.decode(payload)
      ids  = tags.map(&:id)
      expect(ids).not_to include('54')
      expect(ids).not_to include('81')
    end

    it 'ends with CRC Tag 63' do
      expect(payload).to match(/63..[0-9A-F]{4}\z/)
    end
  end

  context 'with amount only' do
    subject(:payload) { described_class.payload(mobile_no: mobile, amount: amount) }

    it 'uses point-of-initiation 12' do
      tag01 = ThaiQrPay::TLV.decode(payload).find { |t| t.id == '01' }
      expect(tag01.value).to eq('12')
    end

    it 'includes Tag 54 formatted to two decimals' do
      tag54 = ThaiQrPay::TLV.decode(payload).find { |t| t.id == '54' }
      expect(tag54.value).to eq('123.45')
    end

    it 'does not include Tag 81' do
      ids = ThaiQrPay::TLV.decode(payload).map(&:id)
      expect(ids).not_to include('81')
    end
  end

  context 'with message only' do
    subject(:payload) { described_class.payload(mobile_no: mobile, message: message) }

    it 'includes Tag 81 with UCS-2 BE hex value' do
      tag81 = ThaiQrPay::TLV.decode(payload).find { |t| t.id == '81' }
      # "Hello" in UCS-2 BE hex:
      expect(tag81.value).to eq('00480065006C006C006F')
    end

    it 'does not include Tag 54' do
      expect(payload).not_to include('54')
    end
  end

  context 'with both amount and message' do
    subject(:payload) { described_class.payload(mobile_no: mobile, amount: amount, message: message) }

    it 'includes both Tag 54 and Tag 81' do
      expect(payload).to include('54', '81')
    end
  end
end
