*Note: Slashdown is in it's early stages and is not yet feature complete, PRs welcome!*

# Slashdown

Slashdown is a superset of markdown for quickly creating web pages. It plays well with HTMX, Tailwind, AlpineJS, and the backend of your choice.

### Syntax

Slashdown introduces a few new syntax rules on top of standard Markdown:

- Any line starting with a `/` is a tag, unless it's a comment (`//`).
- You can add classes and ids to tags via the usual shorthands (e.g. `.class` `#id`), which is great for Tailwind.
- You can also add attributes the normal way, which is great for HTMX (e.g. `href="https://example.com"` `autofocus`).
  - You can also add attributes on the lines immediately following a tag
- Anything else will be rendered as markdown
- Indentation is important! It determines the parent/child relationship of elements.

Here's a sample Slashdown document:

```sd
// Slashdown is meant for fast typing:
/main .container.mx-auto

  # This is a heading.
  Everything indented becomes a child of the element above.

  // One `/` creates a div, but you can write any tag name (even custom elements).
  // Attributes can go on the following line if it's more readable.
  / .grid.grid-col-2
    data-foo="bar"

    This will render a paragraph via markdown.

    /input type="text" placeholder="Enter your name" autofocus

  /footer .flex.justify-between

    Made with ❤️ in slashdown.

    /a href="https://miniware.team" target="_blank"
      Made by Miniware
```


## Installation

To install Slashdown, add this line to your application's Gemfile:

```ruby
gem "slashdown"
```

Note that this project is in it's early stages, some basic things don't work!

### Usage

```ruby
sd = Slashdown::TemplateRenderer

# read from a file
src = File.read("path/to/src.sd")
html = sd.render src
```

```ruby
sd = Slashdown::TemplateRenderer

# render a string with context
context = {
  title: "Hello World!",
  body: "This is the body of the article"
}

src = <<~SD
  /article .container
    # {{title}}

    {{body}}
SD

html = sd.render src, context
```

## Lexer and Parser

The Slashdown lexer and parser are implemented in Ruby. The lexer tokenizes the Slashdown document into a series of tokens, which the parser then uses to construct a syntax tree. The syntax tree can then be used to generate the final HTML output.

The lexer and parser have been thoroughly tested and have 100% code coverage.

## Contributing

Contributions to Slashdown are welcome! Please include tests with your PR.
