# frozen_string_literal: true

require 'thai_qr_pay/tlv'
require 'thai_qr_pay/crc16'

module ThaiQrPay
  module Generate
    # Generates a TrueMoney-specific slip-verify QR
    # Tag 00 = sub-TLV [01,01,eventType,transactionId,date], CRC tag = '91'
    class TrueMoneySlipVerify
      def self.payload(event_type:, transaction_id:, date:)
        inner = [
          TLV.tag('00', '01'),
          TLV.tag('01', '01'),
          TLV.tag('02', event_type),
          TLV.tag('03', transaction_id),
          TLV.tag('04', date)
        ]
        payload = [TLV.tag('00', TLV.encode(inner))]
        # per TS, CRC-tag '91', case-sensitive (we output uppercase)
        CRC16.with_crc(TLV.encode(payload), '91')
      end
    end
  end
end
