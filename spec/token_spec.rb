require "token"

describe "Token" do
  it "can be compared to another token instance" do
    prime_token = Token.new(:TAG, "/div", 0)
    similar_token = Token.new(:TAG, "/div", 0)
    different_token = Token.new(:TAG, "/div", 1)

    expect(prime_token).to eq similar_token
    expect(prime_token).to_not eq different_token
  end
end
