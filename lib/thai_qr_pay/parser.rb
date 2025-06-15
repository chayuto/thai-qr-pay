# frozen_string_literal: true

require 'thai_qr_pay/tlv'
require 'thai_qr_pay/crc16'

module ThaiQrPay
  # Parses EMVCo QR payloads into TLV tags, with optional CRC checking.
  class Parser
    attr_reader :payload, :tags

    # strict: verify CRC before parsing; sub_tags: decode nested TLV
    def initialize(payload, strict: false, sub_tags: true)
      @payload = payload.dup

      if strict
        exp = payload[-4..]
        calc = CRC16.checksum(payload[0..-5])
        raise Error, 'CRC mismatch' unless exp == calc
      end

      @tags = TLV.decode(payload)

      return unless sub_tags

      @tags.each do |t|
        next unless t.value.match?(/^\d{4}/)

        subt = TLV.decode(t.value)
        t.sub_tags = subt if subt.map(&:length) == subt.map { |s| s.value.length }
      end
    end

    # Fetch a Tag struct by id (and optional sub_id)
    def get_tag(id, sub_id = nil)
      t = @tags.find { |x| x.id == id }
      return unless t
      return t unless sub_id && t.sub_tags

      t.sub_tags.find { |st| st.id == sub_id }
    end

    # Fetch just the value
    def get_tag_value(id, sub_id = nil)
      get_tag(id, sub_id)&.value
    end

    # Recompute & compare CRC (default tag '63')
    def valid_crc?(crc_tag = '63')
      filtered = @tags.reject { |t| t.id == crc_tag }
      rebuilt  = TLV.encode(filtered)
      payload == CRC16.with_crc(rebuilt, crc_tag)
    end
  end
end
