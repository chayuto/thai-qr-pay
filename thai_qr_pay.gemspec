# frozen_string_literal: true

# thai_qr_pay.gemspec

require_relative 'lib/thai_qr_pay/version'

Gem::Specification.new do |s|
  s.name        = 'thai_qr_pay'
  s.version     = ThaiQrPay::VERSION
  s.summary     = 'A Ruby toolkit for Thailand’s EMVCo QR payments (PromptPay, TrueMoney, slip-verify, BOT barcode conversion)'
  s.description = <<~DESC
    thai_qr_pay is a Ruby gem providing:
    - ASCII-numeric TLV parsing and encoding
    - EMVCo CRC-16/IBM-SDLC checksum computation and validation
    - Generators for PromptPay AnyID, PromptPay Bill Payment, TrueMoney, etc.
    - Validators for slip-verify and TrueMoney slip verify payloads
    - BOT barcode → EMVCo QR Tag-30 conversion
  DESC
  s.authors     = ['Chayut Orapinpatipat']
  s.email       = ['chayut_o@hotmail.com']
  s.files       = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }
  s.homepage    = 'https://github.com/chayuto/thai-qr-pay'
  s.metadata ||= {}
  s.metadata['documentation_uri'] = 'https://github.com/chayuto/thai-qr-pay#readme'
  s.license = 'MIT'

  s.required_ruby_version = '>= 2.7'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
