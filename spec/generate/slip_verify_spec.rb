# frozen_string_literal: true

require 'thai_qr_pay/generate/slip_verify'
require 'thai_qr_pay/tlv'
require 'thai_qr_pay/crc16'

RSpec.describe ThaiQrPay::Generate::SlipVerify do
  let(:bank) { 'KBank' }
  let(:ref)  { 'ABC123' }

  subject(:payload) { described_class.payload(sending_bank: bank, trans_ref: ref) }

  it 'returns a string' do
    expect(payload).to be_a(String)
  end

  it 'contains Tag 00, Tag 51, and CRC Tag 91' do
    tags = ThaiQrPay::TLV.decode(payload)
    expect(tags.map(&:id)).to include('00', '51', '91')
    tag51 = tags.find { |t| t.id == '51' }
    expect(tag51.value).to eq('TH')
  end

  it 'embeds sending_bank and trans_ref as subtags of Tag 00' do
    tag00 = ThaiQrPay::TLV.decode(payload).find { |t| t.id == '00' }
    subtags = ThaiQrPay::TLV.decode(tag00.value)
    expect(subtags.find { |st| st.id == '01' }.value).to eq(bank)
    expect(subtags.find { |st| st.id == '02' }.value).to eq(ref)
  end

  it 'appends correct CRC using tag 91' do
    body = payload[0..-5] # everything before the CRC hex
    expected = ThaiQrPay::CRC16.checksum(body)
    expect(payload).to end_with("9104#{expected}")
  end
end
