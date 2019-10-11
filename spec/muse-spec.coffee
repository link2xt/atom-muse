describe "Muse grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-muse")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.muse")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.muse"

  it "tokenizes line comments", ->
    {tokens} = grammar.tokenizeLine(";")
    expect(tokens[0]).toEqual value: ";", scopes: ["source.muse", "comment.line.muse"]

    {tokens} = grammar.tokenizeLine("; Foo bar")
    expect(tokens[0]).toEqual value: "; Foo bar", scopes: ["source.muse", "comment.line.muse"]

    # Require a space after ";"
    {tokens} = grammar.tokenizeLine(";Foo bar")
    expect(tokens[0]).toEqual value: ";Foo bar", scopes: ["source.muse"]

  it "tokenizes horizontal rules", ->
    # 4 hyphens are enough
    {tokens} = grammar.tokenizeLine("----")
    expect(tokens[0]).toEqual value: "----", scopes: ["source.muse", "comment.hr.muse"]

    # 3 hyphens are not enough
    {tokens} = grammar.tokenizeLine("---")
    expect(tokens[0]).toEqual value: "---", scopes: ["source.muse"]

    # More than 4 hyphens are allowed after the horizontal rule
    {tokens} = grammar.tokenizeLine("-------")
    expect(tokens[0]).toEqual value: "-------", scopes: ["source.muse", "comment.hr.muse"]

    # Whitespace is allowed after the horizontal rule
    {tokens} = grammar.tokenizeLine("----  ")
    expect(tokens[0]).toEqual value: "----  ", scopes: ["source.muse", "comment.hr.muse"]

  it "tokenizes single asterisks", ->
    {tokens} = grammar.tokenizeLine("Foo * bar * baz")
    expect(tokens[0]).toEqual value: "Foo * bar * baz", scopes: ["source.muse"]

  it "tokenizes emphasis", ->
    {tokens} = grammar.tokenizeLine("*Foo bar*")
    expect(tokens[0]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[1]).toEqual value: "Foo bar", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[2]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]

    {tokens} = grammar.tokenizeLine("Not*emphasized foo*bar")
    expect(tokens[0]).toEqual value: "Not*emphasized foo*bar", scopes: ["source.muse"]

    # Comma after closing *
    {tokens} = grammar.tokenizeLine("Foo *bar*, baz")
    expect(tokens[0]).toEqual value: "Foo ", scopes: ["source.muse"]
    expect(tokens[1]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[2]).toEqual value: "bar", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[3]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[4]).toEqual value: ", baz", scopes: ["source.muse"]

    # Letter after closing *
    {tokens} = grammar.tokenizeLine("Foo *bar*x bat* baz")
    expect(tokens[0]).toEqual value: "Foo ", scopes: ["source.muse"]
    expect(tokens[1]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[2]).toEqual value: "bar*x bat", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[3]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[4]).toEqual value: " baz", scopes: ["source.muse"]

    # Newline after opening *
    {tokens} = grammar.tokenizeLine("*\nFoo bar*")
    expect(tokens[0]).toEqual value: "*\nFoo bar*", scopes: ["source.muse"]

    # Newline before closing *
    {tokens} = grammar.tokenizeLine("*Foo bar\n* baz*")
    expect(tokens[0]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[1]).toEqual value: "Foo bar\n* baz", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[2]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]

  it "tokenizes strong emphasis", ->
    {tokens} = grammar.tokenizeLine("**Foo bar**")
    expect(tokens[0]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[1]).toEqual value: "Foo bar", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[2]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]

    {tokens} = grammar.tokenizeLine("Not**emphasized foo**bar")
    expect(tokens[0]).toEqual value: "Not**emphasized foo**bar", scopes: ["source.muse"]

    # Comma after closing **
    {tokens} = grammar.tokenizeLine("Foo **bar**, baz")
    expect(tokens[0]).toEqual value: "Foo ", scopes: ["source.muse"]
    expect(tokens[1]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[2]).toEqual value: "bar", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[3]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[4]).toEqual value: ", baz", scopes: ["source.muse"]

    # Letter after closing **
    {tokens} = grammar.tokenizeLine("Foo **bar**x bat** baz")
    expect(tokens[0]).toEqual value: "Foo ", scopes: ["source.muse"]
    expect(tokens[1]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[2]).toEqual value: "bar**x bat", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[3]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[4]).toEqual value: " baz", scopes: ["source.muse"]

    # Newline after opening *
    {tokens} = grammar.tokenizeLine("**\nFoo bar**")
    expect(tokens[0]).toEqual value: "**\nFoo bar**", scopes: ["source.muse"]

    # Newline before closing *
    {tokens} = grammar.tokenizeLine("**Foo bar\n** baz**")
    expect(tokens[0]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[1]).toEqual value: "Foo bar\n** baz", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[2]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]

  it "tokenizes code", ->
    {tokens} = grammar.tokenizeLine("=code=")
    expect(tokens[0]).toEqual value: "=", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[1]).toEqual value: "code", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[2]).toEqual value: "=", scopes: ["source.muse", "markup.raw.muse"]

    # One character
    {tokens} = grammar.tokenizeLine("=c=")
    expect(tokens[0]).toEqual value: "=", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[1]).toEqual value: "c", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[2]).toEqual value: "=", scopes: ["source.muse", "markup.raw.muse"]

    # Just three "="
    {tokens} = grammar.tokenizeLine("===")
    expect(tokens[0]).toEqual value: "===", scopes: ["source.muse"]

    {tokens} = grammar.tokenizeLine("not=code foo=bar")
    expect(tokens[0]).toEqual value: "not=code foo=bar", scopes: ["source.muse"]

  it "tokenizes code tag", ->
    {tokens} = grammar.tokenizeLine("<code>code</code>")
    expect(tokens[0]).toEqual value: "<code>", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[1]).toEqual value: "code", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[2]).toEqual value: "</code>", scopes: ["source.muse", "markup.raw.muse"]

  it "tokenizes verbatim tag", ->
    {tokens} = grammar.tokenizeLine("<verbatim>foo *bar* baz</verbatim>")
    expect(tokens[0]).toEqual value: "<verbatim>", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[1]).toEqual value: "foo *bar* baz", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[2]).toEqual value: "</verbatim>", scopes: ["source.muse", "markup.raw.muse"]

    {tokens} = grammar.tokenizeLine("<verbatim>foo\n* not a header\n</verbatim>")
    expect(tokens[0]).toEqual value: "<verbatim>", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[1]).toEqual value: "foo\n* not a header\n", scopes: ["source.muse", "markup.raw.muse"]
    expect(tokens[2]).toEqual value: "</verbatim>", scopes: ["source.muse", "markup.raw.muse"]

  it "tokenizes examples", ->
    [firstLineTokens, secondLineTokens, thirdLineTokens] = grammar.tokenizeLines("{{{\nexample\n}}}")
    expect(firstLineTokens[0]).toEqual value: "{{{", scopes: ["source.muse", "markup.raw.muse"]
    expect(secondLineTokens[0]).toEqual value: "example", scopes: ["source.muse", "markup.raw.muse"]
    expect(thirdLineTokens[0]).toEqual value: "}}}", scopes: ["source.muse", "markup.raw.muse"]

  it "tokenizes em tag", ->
    {tokens} = grammar.tokenizeLine("<em>foo bar</em>")
    expect(tokens[0]).toEqual value: "<em>", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[1]).toEqual value: "foo bar", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[2]).toEqual value: "</em>", scopes: ["source.muse", "markup.italic.muse"]

  it "tokenizes strong tag", ->
    {tokens} = grammar.tokenizeLine("<strong>foo bar</strong>")
    expect(tokens[0]).toEqual value: "<strong>", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[1]).toEqual value: "foo bar", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[2]).toEqual value: "</strong>", scopes: ["source.muse", "markup.bold.muse"]

  it "tokenizes del tag", ->
    {tokens} = grammar.tokenizeLine("<del>foo bar</del>")
    expect(tokens[0]).toEqual value: "<del>", scopes: ["source.muse", "markup.deleted.muse"]
    expect(tokens[1]).toEqual value: "foo bar", scopes: ["source.muse", "markup.deleted.muse"]
    expect(tokens[2]).toEqual value: "</del>", scopes: ["source.muse", "markup.deleted.muse"]

  it "tokenizes > quotes", ->
    # Empty quote
    {tokens} = grammar.tokenizeLine(">")
    expect(tokens[0]).toEqual value: ">", scopes: ["source.muse", "markup.quote.muse"]

    {tokens} = grammar.tokenizeLine("> foo bar")
    expect(tokens[0]).toEqual value: "> foo bar", scopes: ["source.muse", "markup.quote.muse"]

    # Space is required
    {tokens} = grammar.tokenizeLine(">foo bar")
    expect(tokens[0]).toEqual value: ">foo bar", scopes: ["source.muse"]

  it "tokenizes quote tag", ->
    {tokens} = grammar.tokenizeLine("<quote>\nSimple quote\n</quote>")
    expect(tokens[0]).toEqual value: "<quote>", scopes: ["source.muse", "markup.quote.muse"]
    expect(tokens[1]).toEqual value: "\nSimple quote\n", scopes: ["source.muse", "markup.quote.muse"]
    expect(tokens[2]).toEqual value: "</quote>", scopes: ["source.muse", "markup.quote.muse"]

    {tokens} = grammar.tokenizeLine("<quote>\n - List item inside quote\n</quote>")
    expect(tokens[0]).toEqual value: "<quote>", scopes: ["source.muse", "markup.quote.muse"]
    expect(tokens[1]).toEqual value: "\n", scopes: ["source.muse", "markup.quote.muse"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.muse", "markup.quote.muse"]
    expect(tokens[3]).toEqual value: "-", scopes: ["source.muse", "markup.quote.muse", "variable.unordered.list.muse"]
    expect(tokens[4]).toEqual value: " ", scopes: ["source.muse", "markup.quote.muse"]
    expect(tokens[5]).toEqual value: "List item inside quote\n", scopes: ["source.muse", "markup.quote.muse"]
    expect(tokens[6]).toEqual value: "</quote>", scopes: ["source.muse", "markup.quote.muse"]

  it "tokenizes links", ->
    {tokens} = grammar.tokenizeLine("[[https://example.com]]")
    expect(tokens[0]).toEqual value: "[[", scopes: ["source.muse", "markup.underline.link.muse"]
    expect(tokens[1]).toEqual value: "https://example.com", scopes: ["source.muse", "markup.underline.link.muse"]
    expect(tokens[2]).toEqual value: "]]", scopes: ["source.muse", "markup.underline.link.muse"]

  it "illegal closing tag", ->
    {tokens} = grammar.tokenizeLine("</em>")
    expect(tokens[0]).toEqual value: "</em>", scopes: ["source.muse", "invalid.illegal.muse"]

  it "tokenizes unordered list markers", ->
    {tokens} = grammar.tokenizeLine(" - List item")
    expect(tokens[0]).toEqual value: " ", scopes: ["source.muse"]
    expect(tokens[1]).toEqual value: "-", scopes: ["source.muse", "variable.unordered.list.muse"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.muse"]
    expect(tokens[3]).toEqual value: "List item", scopes: ["source.muse"]

  it "tokenizes ordered list markers", ->
    {tokens} = grammar.tokenizeLine(" 1. List item")
    expect(tokens[0]).toEqual value: " ", scopes: ["source.muse"]
    expect(tokens[1]).toEqual value: "1.", scopes: ["source.muse", "variable.ordered.list.muse"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.muse"]
    expect(tokens[3]).toEqual value: "List item", scopes: ["source.muse"]

    # Can't be with 0
    {tokens} = grammar.tokenizeLine(" 0. Not a list item")
    expect(tokens[0]).toEqual value: " 0. Not a list item", scopes: ["source.muse"]

    # Can't start with 0
    {tokens} = grammar.tokenizeLine(" 01. Not a list item")
    expect(tokens[0]).toEqual value: " 01. Not a list item", scopes: ["source.muse"]

    # Can contain 0
    {tokens} = grammar.tokenizeLine(" 10. List item")
    expect(tokens[0]).toEqual value: " ", scopes: ["source.muse"]
    expect(tokens[1]).toEqual value: "10.", scopes: ["source.muse", "variable.ordered.list.muse"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.muse"]
    expect(tokens[3]).toEqual value: "List item", scopes: ["source.muse"]
