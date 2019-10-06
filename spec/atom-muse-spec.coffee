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
