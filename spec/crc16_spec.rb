# frozen_string_literal: true

# spec/crc16_spec.rb
require 'thai_qr_pay/crc16'

RSpec.describe ThaiQrPay::CRC16 do
  describe '.checksum' do
    it 'computes the correct CRC-16/XMODEM for a known string' do
      payload = '0002010102116304'
      # precomputed CRC for that prefix:
      expect(ThaiQrPay::CRC16.checksum(payload)).to eq('AD0A')
    end
  end

  describe '.with_crc' do
    it 'appends the CRC tag, length and checksum' do
      base = '000201010211'
      full = ThaiQrPay::CRC16.with_crc(base, '63')
      # must end with tag '63', length '04' and the 4-hex CRC
      expect(full).to match(/\A0002010102116304[0-9A-F]{4}\z/)
      # and be valid when recomputed
      prefix = full[0..-5]
      crc = full[-4..]
      expect(ThaiQrPay::CRC16.checksum(prefix)).to eq(crc)
    end
  end
end
