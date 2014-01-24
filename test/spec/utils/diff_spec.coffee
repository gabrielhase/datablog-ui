describe 'Diff Helper', ->

  describe 'Del/Add Diff', ->

    beforeEach ->
      @arr1 = [
        id: 1
        value: "4.2"
      ,
        id: 2
        value: "42"
      ]

      @arr2 = [
        id: 2
        value: "42"
      ]

    it 'recognizes the diff between two arrays of objects', ->
      diff = livingmapsDiff.differenceObjects(@arr1, @arr2)
      expect(diff).to.eql([
        id: 1
        value: "4.2"
      ])


    it 'does not recognize a diff to an array with more objects', ->
      diff = livingmapsDiff.differenceObjects(@arr2, @arr1)
      expect(diff).to.be.empty


  describe 'Change Diff', ->

    beforeEach ->
      @arr1 = [
        id: 2
        value: "4.2"
      ]

      @arr2 = [
        id: 2
        value: "42"
      ]

    it 'recognizes the diff between two arrays of objects', ->
      diff = livingmapsDiff.differenceObjects(@arr1, @arr2)
      expect(diff).to.eql([
        id: 2
        value: "4.2"
      ])


    it 'recognizes a change diff in both directions', ->
      diff = livingmapsDiff.differenceObjects(@arr2, @arr1)
      expect(diff).to.eql([
        id: 2
        value: "42"
      ])


  describe 'Intersection', ->
    beforeEach ->
      @arr1 = [
        id: 1
        val: 2
      ,
        id: 2
        val: 42
      ,
        id: 3
        val: 35
      ]
      @arr2 = [
        id: 3
        val: 35
      ,
        id: 5
        val: 55
      ,
        id: 1
        val: 22
      ]

    it 'recognizes the intersection between two array by property', ->
      intersection = livingmapsDiff.intersectionFor(@arr1, @arr2, 'id')
      expect(intersection.length).to.equal(2)
      expect(intersection[0]).to.eql
        previous:
          id: 1
          val: 22
        after:
          id: 1
          val: 2
      expect(intersection[1]).to.eql
        previous:
          id: 3
          val: 35
        after:
          id: 3
          val: 35

