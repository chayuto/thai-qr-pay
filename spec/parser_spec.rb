# frozen_string_literal: true

# spec/parser_spec.rb
require 'thai_qr_pay/parser'
require 'thai_qr_pay/generate/promptpay/any_id'

RSpec.describe ThaiQrPay::Parser do
  let(:mobile) { '0812345678' }
  let(:valid_pp_anyid) do
    ThaiQrPay::Generate::Promptpay::AnyID.payload(
      type: 'MSISDN',
      target: mobile,
      amount: 10.5
    )
  end

  describe '#initialize' do
    it 'parses tags into an array' do
      parser = described_class.new(valid_pp_anyid)
      expect(parser.tags).to be_an(Array)
      expect(parser.get_tag('00').value).to eq('01')
    end

    it 'raises on bad CRC when strict: true' do
      bad = valid_pp_anyid.sub(/.{4}$/, 'DEAD')
      expect { described_class.new(bad, strict: true) }.to raise_error(ThaiQrPay::Error, /CRC mismatch/)
    end

    it 'does not raise on bad CRC when strict: false' do
      bad = valid_pp_anyid.sub(/.{4}$/, 'DEAD')
      expect { described_class.new(bad, strict: false) }.not_to raise_error
    end
  end

  describe '#get_tag and #get_tag_value' do
    subject(:parser) { described_class.new(valid_pp_anyid, strict: true) }

    it 'fetches top-level tag struct' do
      tag = parser.get_tag('54')
      expect(tag).to be_a(ThaiQrPay::TLV::Tag)
      expect(tag.id).to eq('54')
    end

    it 'fetches nested sub-tag value' do
      # Tag '29' contains sub-tags; '01' inside gives the MSISDN with 66 prefix
      expected_msisdn = mobile.sub(/^0/, '66').rjust(13, '0')
      expect(parser.get_tag_value('29', '01')).to eq(expected_msisdn)
    end

    it 'returns nil for missing tags' do
      expect(parser.get_tag('99')).to be_nil
      expect(parser.get_tag_value('29', '99')).to be_nil
    end
  end

  describe '#valid_crc?' do
    it 'returns true for correct CRC' do
      parser = described_class.new(valid_pp_anyid, strict: true)
      expect(parser.valid_crc?).to be true
    end

    it 'returns false for tampered payload' do
      tampered = valid_pp_anyid.sub('12', '11')
      parser   = described_class.new(tampered, strict: false)
      expect(parser.valid_crc?).to be false
    end
  end
end
