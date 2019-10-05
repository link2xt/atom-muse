describe "Muse grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-muse")

    runs ->
      grammar = atom.syntax.grammarForScopeName("source.muse")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.muse"
