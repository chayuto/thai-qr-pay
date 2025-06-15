# Thai QR Pay / ไทยคิวอาร์เพย์

A Ruby toolkit for Thailand’s EMVCo‐QR payments—PromptPay (AnyID & Bill Payment), TrueMoney, slip-verify, and BOT-barcode-to-QR conversion.  
It provides:

- ASCII-numeric TLV parsing & encoding  
- EMVCo CRC-16/XMODEM checksum computation & validation  
- PromptPay payload generators (AnyID, Bill Payment)  
- BOT barcode ↔ EMVCo QR Tag-30 conversion  
- Slip-verify & TrueMoney slip-verify validators  


Ruby Gem สำหรับการชำระเงินผ่าน QR ตามมาตรฐาน EMVCo ของประเทศไทย รองรับ PromptPay (AnyID & Bill Payment), TrueMoney, slip-verify และการแปลง BOT barcode เป็น EMVCo QR  
ฟีเจอร์:

- การแยกวิเคราะห์ (parse) และสร้าง (encode) TLV แบบตัวเลข ASCII  
- คำนวณและตรวจสอบค่า CRC-16/XMODEM ตามสเปค EMVCo  
- สร้าง Payload สำหรับ PromptPay AnyID และ Bill Payment  
- แปลง BOT barcode ↔ EMVCo QR Tag-30  
- ตรวจสอบความถูกต้องของ Slip-verify และ TrueMoney slip-verify  

---

## Installation / การติดตั้ง

```bash
gem install thai_qr_pay
````

---

## Usage / การใช้งาน

```ruby
require 'thai_qr_pay'
```

### 1. Parsing a QR payload / วิเคราะห์ QR payload

```ruby
qr_string = '000201010212...6304ABCD'
parser    = ThaiQrPay::Parser.new(qr_string, strict: true)

puts parser.get_tag_value('00')        # => '01'
puts parser.get_tag_value('29', '01')  # nested sub-tag
```

---

### 2. Generating PromptPay AnyID / สร้าง PromptPay AnyID

```ruby
payload = ThaiQrPay::Generate::Promptpay::AnyID.payload(
  type:   'MSISDN',
  target: '0812345678',
  amount: 100.0
)
# => "00020101021229...6304XXXX"
```

---

### 3. Generating PromptPay Bill Payment / สร้าง PromptPay Bill Payment

```ruby
payload = ThaiQrPay::Generate::Promptpay::BillPayment.payload(
  biller_id: '1234567890123',
  ref1:      'INV001',
  amount:    250.50
)
```

---

### 4. Converting BOT Barcode → QR Tag 30 / แปลง BOT Barcode เป็น QR Tag 30

```ruby
raw    = "|1234567890123\rINV001\r\r012345"
bot    = ThaiQrPay::BOTBarcode.from_string(raw)
qr_tag = bot.to_qr_tag30
```

---

### 5. Validating Slip Verify / ตรวจสอบ Slip-verify

```ruby
result = ThaiQrPay::Validate::SlipVerify.call(qr_string)
if result
  puts result[:sending_bank]
  puts result[:trans_ref]
else
  puts 'Invalid Slip-verify QR'
end
```

---

### 6. Validating TrueMoney Slip Verify / ตรวจสอบ TrueMoney Slip-verify

```ruby
tm_res = ThaiQrPay::Validate::TrueMoneySlipVerify.call(qr_string)
if tm_res
  puts tm_res[:event_type]
  puts tm_res[:transaction_id]
  puts tm_res[:date]
else
  puts 'Invalid TrueMoney Slip-verify QR'
end
```

---

### 7. Generating Slip-Verify QR / สร้าง QR สำหรับ Slip-verify

```ruby
payload = ThaiQrPay::Generate::SlipVerify.payload(
  sending_bank: 'KBank',
  trans_ref:    'REF12345'
)
# => "0004...5102TH...9104XXXX"
```

---

### 8. Generating TrueMoney Payment QR / สร้าง QR สำหรับ TrueMoney

```ruby
payload = ThaiQrPay::Generate::TrueMoney.payload(
  mobile_no: '0812345678',
  amount:    150.0,
  message:   'สวัสดี'
)
# => "00020101...2920A000000677010111031514000081234567853037645802TH5406150.008112...6304XXXX"
```

---

### 9. Generating TrueMoney Slip-Verify QR / สร้าง QR สำหรับ TrueMoney Slip-verify

```ruby
payload = ThaiQrPay::Generate::TrueMoneySlipVerify.payload(
  event_type:     'PAYMENT',
  transaction_id: 'TX123456',
  date:           '20250615'
)
# => "0005...000101010402PAYMENT0308TX1234560408202506159104XXXX"
```

---

## License

© 2025 Chayut Orapinpatipat
Released under the MIT License. See [LICENSE.txt](LICENSE.txt) for details.
