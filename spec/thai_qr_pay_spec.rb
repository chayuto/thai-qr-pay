# frozen_string_literal: true

# spec/thai_qr_pay_spec.rb
require 'thai_qr_pay'

RSpec.describe ThaiQrPay do
  it 'has a version number' do
    expect(ThaiQrPay::VERSION).not_to be_nil
  end

  context 'integration examples' do
    let(:mobile) { '0812345678' }
    let(:biller) { '1234567890123' }

    it 'generates and parses a PromptPay AnyID QR payload' do
      payload = ThaiQrPay::Generate::Promptpay::AnyID.payload(
        type: 'MSISDN',
        target: mobile,
        amount: 50.0
      )
      parser = ThaiQrPay::Parser.new(payload, strict: true)

      # Standard EMVCo tags
      expect(parser.get_tag_value('00')).to eq('01')    # Payload Format Indicator
      expect(parser.get_tag_value('01')).to eq('12')    # Point-of-Initiation Method

      # Sub-tag 29.01 contains the converted mobile number (no padding)
      expected_msisdn = mobile.sub(/^0/, '66').rjust(13, '0')
      expect(parser.get_tag_value('29', '01')).to eq(expected_msisdn)

      expect(parser.valid_crc?).to be true
    end

    it 'generates and parses a PromptPay Bill Payment QR payload' do
      payload = ThaiQrPay::Generate::Promptpay::BillPayment.payload(
        biller_id: biller,
        ref1: 'INV001',
        amount: 250.25
      )
      parser = ThaiQrPay::Parser.new(payload, strict: true)

      # Sub-tag 30.01 is the biller ID
      expect(parser.get_tag_value('30', '01')).to eq(biller)
      # Tag 54 is the amount
      expect(parser.get_tag_value('54')).to eq('250.25')
      expect(parser.valid_crc?).to be true
    end

    it 'round-trips BOT barcode to QR Tag 30 payload' do
      raw = "|#{biller}\rINV001\r\r012345"
      bot = ThaiQrPay::BOTBarcode.from_string(raw)
      expect(bot).not_to be_nil
      expect(bot.biller_id).to eq(biller)
      expect(bot.to_s).to eq(raw)

      qr = bot.to_qr_tag30
      parser = ThaiQrPay::Parser.new(qr, strict: true)
      expect(parser.get_tag_value('30', '01')).to eq(biller)
    end
  end
end
