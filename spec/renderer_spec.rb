require "spec_helper"
require "renderer"

RSpec.describe Slashdown::Renderer do
  let(:ast) do
    p = Slashdown::TagNode.new "p"
    p.add_selector ".font-bold"
    p.add_attribute 'foo="bar"'
    p.add_child Slashdown::Node.new :TEXT, "Hello world!"

    [p]
  end
  let(:renderer) { Slashdown::Renderer.new(ast) }

  describe "#render" do
    it "renders the AST to HTML" do
      expect(renderer.render).to eq(
        '<p class="font-bold" foo="bar">Hello world!</p>'
      )
    end
  end
end
