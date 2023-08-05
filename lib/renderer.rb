require "redcarpet"
require "htmlbeautifier"

module Slashdown
  class Renderer
    # TODO: Find a better way to handle self closing tags
    SELF_CLOSING_TAGS = [
      "input",
      "img",
      "br",
      "hr",
      "meta",
      "link",
      "base",
      "area",
      "col",
      "command",
      "embed",
      "keygen",
      "param",
      "source",
      "track",
      "wbr"
    ]

    def initialize(ast)
      @ast = ast
    end

    def render
      @ast.map { |child| render_node(child) }.join
    end

    private

    def render_node(node)
      case node.type
      when :TAG
        render_tag(node)
      when :MARKDOWN
        render_markdown(node)
      when :TEXT
        node.content
      else
        throw "Unexpected base node #{node.type}"
      end
    end

    def render_tag(tag_node)
      identifier = tag_node.identifier
      self_closing = SELF_CLOSING_TAGS.include? identifier
      attributes = render_attributes_and_selectors(tag_node)
      children = tag_node.children.map { |child| render_node(child) }.join

      if self_closing
        attributes.nil? ? "<#{identifier} />" : "<#{identifier} #{attributes} />"
      else
        opening_tag = attributes.nil? ? "<#{identifier}>" : "<#{identifier} #{attributes}>"
        closing_tag = "</#{identifier}>"

        [opening_tag, children, closing_tag].join
      end
    end

    def render_attributes_and_selectors(tag_node)
      return nil if tag_node.all_attributes.empty?
      tag_node.all_attributes.join(" ")
    end

    def render_attribute(node)
      "#{node.content.key}=\"#{node.content.value}\""
    end

    def render_markdown(node)
      @md_renderer ||= Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new,
        {
          disable_indented_code_blocks: true,
          highlight: true,
          strikethrough: true,
          superscript: true,
          space_after_headers: true
        }
      )

      @md_renderer.render(node.content)
    end
  end
end
