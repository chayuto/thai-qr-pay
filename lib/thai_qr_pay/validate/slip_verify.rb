# frozen_string_literal: true

require 'thai_qr_pay/parser'

module ThaiQrPay
  module Validate
    # Validates EMVCo “slip verify” QR payloads:
    # checks CRC and extracts sending_bank and trans_ref.
    class SlipVerify
      # payload: EMVCo mini-QR slip verify
      # returns { sending_bank:, trans_ref: } or nil
      def self.call(payload)
        parser = ThaiQrPay::Parser.new(payload, strict: true)
        api  = parser.get_tag_value('00', '00')
        bank = parser.get_tag_value('00', '01')
        tr   = parser.get_tag_value('00', '02')
        return unless api == '000001' && bank && tr

        { sending_bank: bank, trans_ref: tr }
      end
    end
  end
end
