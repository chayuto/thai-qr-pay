# frozen_string_literal: true

require 'thai_qr_pay/tlv'
require 'thai_qr_pay/crc16'

module ThaiQrPay
  module Generate
    module Promptpay
      # Generates PromptPay “AnyID” (mobile/NationalID/etc.) EMVCo QR payloads.
      class AnyID
        PROXY = {
          'MSISDN' => '01',
          'NATID' => '02',
          'EWALLETID' => '03',
          'BANKACC' => '04'
        }.freeze

        # type: one of 'MSISDN','NATID','EWALLETID','BANKACC'
        # target: the ID string; amount: optional numeric
        def self.payload(type:, target:, amount: nil)
          raise Error, 'Unknown type' unless PROXY.key?(type)

          if type == 'MSISDN'
            t = target.sub(/^0/, '66')
            target = t.rjust(13, '0')
          end

          sub = [
            TLV.tag('00', 'A000000677010111'),
            TLV.tag(PROXY[type], target)
          ]
          tag29 = TLV.encode(sub)

          main = [
            TLV.tag('00', '01'),
            TLV.tag('01', amount ? '12' : '11'),
            TLV.tag('29', tag29),
            TLV.tag('53', '764'),
            TLV.tag('58', 'TH')
          ]
          main << TLV.tag('54', format('%.2f', amount)) if amount

          CRC16.with_crc(TLV.encode(main), '63')
        end
      end
    end
  end
end
