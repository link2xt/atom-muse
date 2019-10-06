describe "Muse grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("atom-muse")

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

  it "tokenizes emphasis", ->
    {tokens} = grammar.tokenizeLine("*Foo bar*")
    expect(tokens[0]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[1]).toEqual value: "Foo bar", scopes: ["source.muse", "markup.italic.muse"]
    expect(tokens[2]).toEqual value: "*", scopes: ["source.muse", "markup.italic.muse"]

  it "tokenizes strong emphasis", ->
    {tokens} = grammar.tokenizeLine("**Foo bar**")
    expect(tokens[0]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[1]).toEqual value: "Foo bar", scopes: ["source.muse", "markup.bold.muse"]
    expect(tokens[2]).toEqual value: "**", scopes: ["source.muse", "markup.bold.muse"]
