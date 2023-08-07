require "spec_helper"

RSpec.describe Slashdown do
  let(:src) { File.read("spec/fixtures/example.sd") }
  let(:expected_html) { File.read("spec/fixtures/expected.html") }

  let(:sd) { sd = Slashdown::TemplateRenderer }

  it "has a simple interface" do
    html = sd.render src

    # Parse the HTML fragments using Nokogiri
    parsed_html = Nokogiri::HTML::DocumentFragment.parse(html).canonicalize
    parsed_expected_html = Nokogiri::HTML::DocumentFragment.parse(expected_html).canonicalize

    expect(parsed_html.to_s).to eq(parsed_expected_html.to_s)
  end

  it "can interpolate variables" do
    src = <<~SD
      /article .container
        # {{title}}

        {{body}}
    SD

    context = {
      title: "Hello World!",
      body: <<~MD
        This is the body

        It has two paragraphs
      MD
    }

    html = sd.render src, context

    expected_html = <<~HTML
      <article class="container">
        <h1>Hello World!</h1>

        <p>This is the body</p>
        <p>It has two paragraphs</p>
      </article>
    HTML

    # Parse the HTML fragments using Nokogiri
    parsed_html = Nokogiri::HTML::DocumentFragment.parse(html).canonicalize
    parsed_expected_html = Nokogiri::HTML::DocumentFragment.parse(expected_html).canonicalize

    expect(parsed_html.to_s).to eq(parsed_expected_html.to_s)
  end
end
