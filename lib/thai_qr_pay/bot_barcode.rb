# frozen_string_literal: true

module ThaiQrPay
  # Parses BOT barcode strings and converts them into EMVCo QR Tag-30 payloads.
  class BOTBarcode
    attr_reader :biller_id, :ref1, :ref2, :amount, :_raw_amount

    # str: raw BOT barcode like "|<biller>\r<ref1>\r<ref2>\r<amt>"
    def self.from_string(str)
      return unless str.start_with?('|')

      parts = str[1..].split("\r", 4)
      return unless parts.size == 4

      bid, r1, r2, amt_str = parts
      amount = amt_str != '0' ? (amt_str.to_i / 100.0) : nil
      new(bid, r1, (r2.empty? ? nil : r2), amount, amt_str)
    end

    def initialize(biller_id, ref1, ref2 = nil, amount = nil, amt_str = nil)
      @biller_id    = biller_id
      @ref1         = ref1
      @ref2         = ref2
      @amount       = amount
      @_raw_amount  = amt_str || (amount ? format('%d', (amount * 100).to_i) : '0')
    end

    # Reproduce exactly the original barcode string, including any leading zeros
    def to_s
      "|#{biller_id}\r#{ref1}\r#{ref2 || ''}\r#{_raw_amount}"
    end

    def to_qr_tag30
      ThaiQrPay::Generate::Promptpay::BillPayment.payload(
        biller_id: biller_id,
        amount: amount,
        ref1: ref1,
        ref2: ref2
      )
    end
  end
end
