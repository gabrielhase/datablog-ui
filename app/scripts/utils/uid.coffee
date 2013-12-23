@livingmapsUid = do ->


  guid: ->
    livingmapsUid.s4() + livingmapsUid.s4() + '-' + livingmapsUid.s4() +
    '-' + livingmapsUid.s4() + '-' + livingmapsUid.s4() + '-' + livingmapsUid.s4() +
    livingmapsUid.s4() + livingmapsUid.s4()


  s4: ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
