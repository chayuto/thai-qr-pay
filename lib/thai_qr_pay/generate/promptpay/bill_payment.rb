# frozen_string_literal: true

require 'thai_qr_pay/tlv'
require 'thai_qr_pay/crc16'

module ThaiQrPay
  module Generate
    module Promptpay
      # Generates PromptPay “Bill Payment” EMVCo QR payloads,
      # including optional references and amount.
      class BillPayment
        # biller_id: string, amount: optional, ref1: string, ref2/3: optional
        def self.payload(biller_id:, ref1:, amount: nil, ref2: nil, ref3: nil)
          sub = [
            TLV.tag('00', 'A000000677010112'),
            TLV.tag('01', biller_id),
            TLV.tag('02', ref1)
          ]
          sub << TLV.tag('03', ref2) if ref2
          tag30 = TLV.encode(sub)

          main = [
            TLV.tag('00', '01'),
            TLV.tag('01', amount ? '12' : '11'),
            TLV.tag('30', tag30),
            TLV.tag('53', '764'),
            TLV.tag('58', 'TH')
          ]
          main << TLV.tag('54', format('%.2f', amount)) if amount
          main << TLV.tag('62', TLV.encode([TLV.tag('07', ref3)])) if ref3

          CRC16.with_crc(TLV.encode(main), '63')
        end
      end
    end
  end
end
