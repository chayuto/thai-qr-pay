# frozen_string_literal: true

module ThaiQrPay
  # CRC-16/XMODEM checksum routines for EMVCo QR (poly=0x1021, init=0xFFFF).
  module CRC16
    # Compute CRC-16/XMODEM (poly=0x1021, init=0xFFFF) bitwise
    def self.xmodem(data)
      crc = 0xFFFF
      data.bytes.each do |b|
        crc ^= (b << 8)
        8.times do
          crc = if (crc & 0x8000) != 0
                  ((crc << 1) ^ 0x1021) & 0xFFFF
                else
                  (crc << 1) & 0xFFFF
                end
        end
      end
      crc
    end

    # Return 4-digit uppercase hex CRC
    def self.checksum(payload)
      xmodem(payload).to_s(16).upcase.rjust(4, '0')
    end

    # Append "<crc_tag>04<CRC>" to a TLV string
    def self.with_crc(tlv_string, crc_tag = '63')
      buffer = tlv_string + "#{crc_tag}04"
      buffer + checksum(buffer)
    end
  end
end
