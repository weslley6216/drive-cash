require 'rails_helper'

RSpec.describe 'Helper discipline' do
  let(:method_definition) { /^\s*(?:def\s|define_method\b)/ }
  let(:assertion) { /\bexpect\s*[({]/ }

  it 'declares no method in a spec file' do
    specs = Dir[Rails.root.join('spec/**/*_spec.rb')]

    offenders = specs.select { |path| File.read(path).match?(method_definition) }

    expect(offenders.map { |path| Pathname.new(path).relative_path_from(Rails.root).to_s }).to be_empty
  end

  it 'keeps assertions out of spec/support' do
    supports = Dir[Rails.root.join('spec/support/**/*.rb')]

    offenders = supports.select { |path| File.read(path).match?(assertion) }

    expect(offenders.map { |path| Pathname.new(path).relative_path_from(Rails.root).to_s }).to be_empty
  end

  it 'recognizes a method definition at any indentation, one-line or not' do
    expect(['def sign_in', '  def field(name) = name', '    def  body', '  define_method(:body) { }'].grep(method_definition).size).to eq(4)
  end

  it 'leaves a word merely containing def out of the count' do
    expect(['  defaults = {}', %(  it "is undefined"), '  default_hours'].grep(method_definition)).to be_empty
  end

  it 'recognizes an assertion in either argument or block form' do
    expect(['expect(page).to have_css', 'expect { post path }.to change'].grep(assertion).size).to eq(2)
  end

  it 'leaves a word merely containing expect out of the count' do
    expect([%(page.has_no_button?("Entrar")), 'expected_hex = branding.tokens'].grep(assertion)).to be_empty
  end
end
