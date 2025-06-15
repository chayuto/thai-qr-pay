# frozen_string_literal: true

require 'thai_qr_pay/generate/true_money_slip_verify'
require 'thai_qr_pay/tlv'
require 'thai_qr_pay/crc16'

RSpec.describe ThaiQrPay::Generate::TrueMoneySlipVerify do
  let(:event) { 'PAYMENT' }
  let(:txid)  { 'TX123456' }
  let(:date)  { '20250615' }

  subject(:payload) { described_class.payload(event_type: event, transaction_id: txid, date: date) }

  it 'produces exactly two tags: 00 and 91' do
    tags = ThaiQrPay::TLV.decode(payload)
    expect(tags.map(&:id)).to eq(%w[00 91])
  end

  it 'nests subtags 00..04 correctly under Tag 00' do
    inner = ThaiQrPay::TLV.decode(payload).find { |t| t.id == '00' }
    subtags = ThaiQrPay::TLV.decode(inner.value)
    expect(subtags.map(&:id)).to eq(%w[00 01 02 03 04])
    expect(subtags.find { |st| st.id == '02' }.value).to eq(event)
    expect(subtags.find { |st| st.id == '03' }.value).to eq(txid)
    expect(subtags.find { |st| st.id == '04' }.value).to eq(date)
  end

  it 'appends correct CRC using Tag 91' do
    body     = payload[0..-5]
    expected = ThaiQrPay::CRC16.checksum(body)
    expect(payload).to end_with("9104#{expected}")
  end
end
