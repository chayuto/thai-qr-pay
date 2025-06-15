# frozen_string_literal: true

require 'thai_qr_pay/parser'

module ThaiQrPay
  module Validate
    # Validates TrueMoney “slip verify” QR payloads:
    # checks CRC, then extracts event_type, transaction_id, and date.
    class TrueMoneySlipVerify
      # payload: TrueMoney slip verify format
      # returns { event_type:, transaction_id:, date: } or nil
      def self.call(payload)
        parser = ThaiQrPay::Parser.new(payload, strict: true)
        api  = parser.get_tag_value('00', '00')
        evt  = parser.get_tag_value('00', '02')
        txid = parser.get_tag_value('00', '03')
        dt   = parser.get_tag_value('00', '04')
        return unless api == '01' && evt && txid && dt

        { event_type: evt,
          transaction_id: txid,
          date: dt }
      end
    end
  end
end
