class window.Dictionary
  constructor: -> console.log "Create dictionary instance"

  find: (word, limit) ->
    return [] unless @index and @dict

    @indexCache = {}
    longest = null
    results = []
    for w in (word.substring 0, l for l in [word.length..1])
      result = @searchWord w
      longest or= w if result.length > 0
      results.push result
    results: (result for result, idx in flatten results when idx < limit), match: longest

  searchWord: (word) ->
    results = (@searchItemsByIndexes @index[variant] for variant in Deinflector.deinflect word)
    flatten results

  searchItemsByIndexes: (indexes = []) ->
    @searchItemByIndex i for i in indexes when not @indexCache[i]

  searchItemByIndex: (i) ->
    @indexCache[i] = true
    start = 0
    stop  = @dict.length - 1
    pivot = Math.floor (start + stop) / 2

    while @dict[pivot][0] isnt i and start < stop
      stop  = pivot - 1 if i < @dict[pivot][0]
      start = pivot + 1 if i > @dict[pivot][0]
      pivot = Math.floor (stop + start) / 2

    item = @dict[pivot]
    kana: item[1], kanji: item[2], translation: item[3], romaji: Romaji.toRomaji item[1]

  load: ->
    readDataFile "index.js", (data) =>
      eval data # var loadedIndex = {...}
      @index = loadedIndex
    readDataFile "dict.js", (data) =>
      eval data # var loadedDict = []
      @dict = loadedDict

  unload: ->
    @index = null
    @dict  = null

flatten = (array) ->
  flattened = []
  for element in array
    if element instanceof Array
      flattened = flattened.concat flatten element
    else
      flattened.push element
  flattened

readDataFile = (file, success) ->
  req = new XMLHttpRequest()
  req.open "GET", safari.extension.baseURI + "data/" + file, true
  req.onload = (e) -> success req.responseText if req.readyState is 4
  req.send null
