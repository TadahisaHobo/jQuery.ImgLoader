ns = $.ImgLoaderNs
wait = (time) ->
  $.Deferred (defer) ->
    setTimeout ->
      defer.resolve()
    , time or 300

asyncTest 'Event bind/trigger', ->
  expect 1
  eventer = new ns.Event
  eventer.bind 'foo', ->
    ok(true, 'foo event triggered')
    start()
  eventer.trigger 'foo'

asyncTest 'Event bind with args', ->
  expect 4
  eventer = new ns.Event
  eventer.bind 'foo', (arg1, arg2, arg3) ->
    ok(true, 'foo event triggered')
    equal(arg1, 1, 'arg was passed')
    equal(arg2, 2, 'arg was passed')
    equal(arg3, 3, 'arg was passed')
    start()
  eventer.trigger 'foo', 1, 2, 3

asyncTest 'Event unbind', ->
  expect 1
  eventer = new ns.Event
  eventer.bind 'foo', ->
    ok(false, 'event was fired')
  eventer.unbind 'foo'
  eventer.trigger 'foo'
  wait(0).done ->
    ok(true, 'event was not fired')
    start()

asyncTest 'Event one', ->
  expect 1
  eventer = new ns.Event
  eventer.one 'foo', ->
    ok(true, 'event was fired')
  eventer.trigger 'foo'
  eventer.trigger 'foo'
  eventer.trigger 'foo'
  wait(0).done ->
    start()

asyncTest 'fetchImg basic', ->
  expect 4
  $.when(
    (ns.fetchImg 'imgs/1.jpg').done ($img) ->
      equal($img.size(), 1, '1.jpg loaded')
    ,
    (ns.fetchImg 'imgs/2.jpg').done ($img) ->
      equal($img.size(), 1, '2.jpg loaded')
    ,
    (ns.fetchImg 'imgs/3.jpg').done ($img) ->
      equal($img.size(), 1, '3.jpg loaded')
    ,
    (ns.fetchImg 'imgs/4.jpg').done ($img) ->
      equal($img.size(), 1, '4.jpg loaded')
  ).always ->
    wait().done(start) #qunit fails sometimes w/o wait

asyncTest 'fetchImg error', ->
  expect 1
  $.when(
    (ns.fetchImg 'nothinghere').then ($img) ->
      ok(false, 'img was not loaded but it saied ok')
    , (error) ->
      ok(true, "error msg: #{error.msg}")
  ).always ->
    start()
    
asyncTest 'fetchImg ensure same img', ->
  expect 2
  $.when(
    (ns.fetchImg 'imgs/1.jpg').then ($img) -> $img
    (ns.fetchImg 'imgs/1.jpg').then ($img) -> $img
  ).always ($img1, $img2) ->
    equal ($img1.attr 'src'), ($img2.attr 'src'), 'same img'
    equal ($img1[0]), ($img2[0]), 'same dom'
    start()
    
asyncTest 'loadImg basic', ->
  expect 2
  $.when(
    (ns.loadImg 'imgs/1.jpg').then ($img) -> $img
    (ns.loadImg 'imgs/1.jpg').then ($img) -> $img
  ).always ($img1, $img2) ->
    equal ($img1.attr 'src'), ($img2.attr 'src'), 'same img'
    notEqual ($img1[0]), ($img2[0]), 'but another dom'
    start()

asyncTest 'LoaderItem load', ->
  expect 2
  $.when(
    $.Deferred (defer) ->
      item = new ns.LoaderItem 'imgs/1.jpg'
      item.load().done ($img) ->
        equal ($img.attr 'src'), 'imgs/1.jpg', '1.jpg was loaded'
        defer.resolve $img
    $.Deferred (defer) ->
      item = new ns.LoaderItem 'imgs/2.jpg'
      item.load().done ($img) ->
        equal ($img.attr 'src'), 'imgs/2.jpg', '2.jpg was loaded'
        defer.resolve $img
  ).always ->
    start()

asyncTest 'LoaderItem event load', ->
  expect 2
  item = new ns.LoaderItem 'imgs/1.jpg'
  item.bind 'load', ($img) ->
    ok true, 'load event fired'
    equal ($img.attr 'src'), 'imgs/1.jpg', '1.jpg was thrown to handler'
  item.load().always ->
    start()

asyncTest 'BasicLoader', ->

  expect 22
  loader = new ns.BasicLoader
  count = -1

  loader.bind 'itemload', ($img, i) ->
    equal ($img.size()), 1, ($img.attr 'src') + ' was loaded'
    equal i, (count+1), "counter #{i} was thrown"
    count++

  loader.bind 'allload', ($imgs) ->
    equal $imgs.size(), 10, 'all imgs loaded'

  for i in [1..10]
    loader.add (new ns.LoaderItem "imgs/#{i}.jpg")

  loader.load().always ($imgs) ->
    equal $imgs.size(), 10, 'done deferred worked'
    start()

asyncTest 'BasicLoader add as string', ->

  expect 22
  loader = new ns.BasicLoader
  count = -1

  loader.bind 'itemload', ($img, i) ->
    equal ($img.size()), 1, ($img.attr 'src') + ' was loaded'
    equal i, (count+1), "counter #{i} was thrown"
    count++

  loader.bind 'allload', ($imgs) ->
    equal $imgs.size(), 10, 'all imgs loaded'

  for i in [1..10]
    loader.add "imgs/#{i}.jpg"

  loader.load().always ($imgs) ->
    equal $imgs.size(), 10, 'done deferred worked'
    start()

asyncTest 'ChainLoader', ->

  expect 22
  loader = new ns.ChainLoader 3
  count = -1

  loader.bind 'itemload', ($img, i) ->
    equal ($img.size()), 1, ($img.attr 'src') + ' was loaded'
    equal i, (count+1), "counter #{i} was thrown"
    count++

  loader.bind 'allload', ($imgs) ->
    equal $imgs.size(), 10, 'all imgs loaded'

  for i in [1..10]
    loader.add (new ns.LoaderItem "imgs/#{i}.jpg")

  loader.load().always ($imgs) ->
    equal $imgs.size(), 10, 'done deferred worked'
    start()

asyncTest 'ChainLoader add as string', ->

  expect 22
  loader = new ns.ChainLoader 3
  count = -1

  loader.bind 'itemload', ($img, i) ->
    equal ($img.size()), 1, ($img.attr 'src') + ' was loaded'
    equal i, (count+1), "counter #{i} was thrown"
    count++

  loader.bind 'allload', ($imgs) ->
    equal $imgs.size(), 10, 'all imgs loaded'

  for i in [1..10]
    loader.add "imgs/#{i}.jpg"

  loader.load().always ($imgs) ->
    equal $imgs.size(), 10, 'done deferred worked'
    start()

test 'Facade without new handling', ->
  srcs = [1,2,3,4]
  do ->
    loader = new $.ImgLoader srcs
    ok loader instanceof $.ImgLoader, 'with new'
  do ->
    loader = $.ImgLoader srcs
    ok loader instanceof $.ImgLoader, 'without new'

asyncTest 'Facade (to BasicLoader)', ->

  expect 22

  srcs = []
  srcs.push "imgs/#{i}.jpg" for i in [1..10]

  loader = new $.ImgLoader srcs
  count = -1

  loader.bind 'itemload', ($img, i) ->
    equal ($img.size()), 1, ($img.attr 'src') + ' was loaded'
    equal i, (count+1), "counter #{i} was thrown"
    count++

  loader.bind 'allload', ($imgs) ->
    equal $imgs.size(), 10, 'all imgs loaded'

  loader.load().always ($imgs) ->
    equal $imgs.size(), 10, 'done deferred worked'
    start()

asyncTest 'Facade (to ChainLoader)', ->

  expect 22

  srcs = []
  srcs.push "imgs/#{i}.jpg" for i in [1..10]

  loader = new $.ImgLoader srcs, { chainsize: 5 }
  count = -1

  loader.bind 'itemload', ($img, i) ->
    equal ($img.size()), 1, ($img.attr 'src') + ' was loaded'
    equal i, (count+1), "counter #{i} was thrown"
    count++

  loader.bind 'allload', ($imgs) ->
    equal $imgs.size(), 10, 'all imgs loaded'

  loader.load().always ($imgs) ->
    equal $imgs.size(), 10, 'done deferred worked'
    start()

