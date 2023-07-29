class Renderer
  def render(ast)
    raise NotImplementedError
  end
end

class HTMLRenderer < Renderer
  def render(ast)
    ast.map { |node| render_node(node) }.join("\n")
  end

  def render_node(node)
    case node[:type]
    when :TAG
      render_tag(node)
    when :MARKDOWN
      render_markdown(node)
    end
  end

  def render_tag(node)
    tag = node[:value]
    "<#{tag}>"
  end

  def render_markdown(node)
    text = node[:value]
    "<p>#{text}</p>"
  end

end