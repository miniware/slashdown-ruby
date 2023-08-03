require "token"

RSpec.describe Token do
  let(:token1) { Token.new(:TAG, "div", 2) }
  let(:token2) { Token.new(:TAG, "p", 3) }
  let(:token3) { Token.new(:SELECTOR, ".my-class", 2) }
  let(:token4) { Token.new(:SELECTOR, "#my-id", 1) }

  describe "comparing tokens" do
    it "compares tokens based on their indentation" do
      expect(token1 <=> token2).to eq(-1)
      expect(token1 <=> token3).to eq 0
      expect(token2 <=> token4).to eq 1
    end

    it "compares tokens for equivalence" do
      expect(token1 == token1).to be true
      expect(token1 == token3).to be false
    end
  end
end
