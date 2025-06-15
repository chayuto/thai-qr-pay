# frozen_string_literal: true

require 'thai_qr_pay/tlv'
require 'thai_qr_pay/crc16'

module ThaiQrPay
  module Generate
    # Generates a TrueMoney “wallet” PromptPay-compatible QR
    # Tag 29 = sub-TLV [A000000677010111, '03'+mobileNo], optional Tag 54 & Tag 81, CRC tag = '63'
    class TrueMoney
      def self.payload(mobile_no:, amount: nil, message: nil)
        tag29 = TLV.encode([
                             TLV.tag('00', 'A000000677010111'),
                             TLV.tag('03', "14000#{mobile_no}")
                           ])

        main = [
          TLV.tag('00', '01'),
          TLV.tag('01', amount ? '12' : '11'),
          TLV.tag('29', tag29),
          TLV.tag('53', '764'),
          TLV.tag('58', 'TH')
        ]
        main << TLV.tag('54', format('%.2f', amount)) if amount

        if message
          # Tag 81 is UCS-2 BE hex of the message
          encoded = encode_tag81(message)
          main << TLV.tag('81', encoded)
        end

        CRC16.with_crc(TLV.encode(main), '63')
      end

      # @api private
      def self.encode_tag81(message)
        # TS: Buffer.from(msg,'utf16le').swap16().toString('hex').toUpperCase()
        utf16le = message.encode('utf-16le')
        # swap each pair of bytes
        be_bytes = utf16le.bytes.each_slice(2).flat_map { |lo, hi| [hi, lo] }
        be_bytes.pack('C*').unpack1('H*').upcase
      end
    end
  end
end
