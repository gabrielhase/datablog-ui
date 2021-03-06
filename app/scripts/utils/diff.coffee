@livingmapsDiff = do ->

  # Analogous to underscore.js _.difference method but works with arrays
  # of objects.
  differenceObjects: (arr1, arr2) ->
    _.filter arr1, (val) ->
      presentInArr2 = false
      _.any arr2, (element) ->
        if _.isEqual(val, element)
          presentInArr2 = true
      !presentInArr2 # filter for those values that are NOT in arr2 (difference)


  differenceFor: (arr1, arr2, property) ->
    _.filter arr1, (val) ->
      presentInArr2 = false
      _.any arr2, (element) ->
        if val[property] == element[property]
          presentInArr2 = true
      !presentInArr2


  intersectionFor: (arr1, arr2, property) ->
    intersectionTuples = []
    _.each arr1, (val) ->
      presentInArr2 = false
      _.any arr2, (element) ->
        if val[property] == element[property]
          presentInArr2 = element
      if presentInArr2
        intersectionTuples.push
          previous: presentInArr2
          after: val
    intersectionTuples

