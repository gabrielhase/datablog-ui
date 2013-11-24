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
