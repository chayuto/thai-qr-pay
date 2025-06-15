# frozen_string_literal: true

require 'thai_qr_pay/tlv'
require 'thai_qr_pay/crc16'

module ThaiQrPay
  module Generate
    # Generates an EMVCo “slip verify” (mini-QR) payload
    # Tag 00 = sub-TLV [000001, sendingBank, transRef], Tag 51 = 'TH', CRC tag = '91'
    class SlipVerify
      def self.payload(sending_bank:, trans_ref:)
        inner = [
          TLV.tag('00', '000001'),
          TLV.tag('01', sending_bank),
          TLV.tag('02', trans_ref)
        ]
        payload = [
          TLV.tag('00', TLV.encode(inner)),
          TLV.tag('51', 'TH')
        ]
        CRC16.with_crc(TLV.encode(payload), '91')
      end
    end
  end
end
