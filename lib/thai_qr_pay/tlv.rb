# frozen_string_literal: true

module ThaiQrPay
  # TLV (Tag–Length–Value) parsing and encoding utilities
  # for EMVCo-style QR payloads (PromptPay, TrueMoney, etc.).
  module TLV
    Tag = Struct.new(:id, :length, :value, :sub_tags)

    # Decode an ASCII-numeric TLV string into an array of Tag structs
    def self.decode(payload)
      tags = []
      idx = 0
      while idx < payload.length
        id = payload[idx, 2]
        idx += 2
        len = payload[idx, 2].to_i
        idx += 2
        value = payload[idx, len]
        idx += len
        tags << Tag.new(id, len, value, nil)
      end
      tags
    end

    # Encode an array of Tag structs back into an ASCII TLV string
    def self.encode(tags)
      tags.map do |t|
        inner = t.sub_tags ? encode(t.sub_tags) : t.value
        "#{t.id}#{inner.length.to_s.rjust(2, '0')}#{inner}"
      end.join
    end

    # Helper to build a Tag struct from id + value
    def self.tag(id, value)
      Tag.new(id, value.length, value, nil)
    end
  end
end
