describe 'Words helper', ->

  it 'camel cases a single string', ->
    expect(livingmapsWords.camelCase('string')).to.eql('String')


  it 'camel cases two words', ->
    expect(livingmapsWords.camelCase('two words')).to.eql('TwoWords')
