function seq(from, count)
  local val = ''
  local c = 0
  while c < count do
    val = val..' '..tostring(from + c)
    c = c + 1
  end
  return val
end
function generate(params, shapeText)
   local rad = tostring(params['corner radius'])
   local K = 0.4477152502
   local radk = '3.5817220016' -- rad * K
   local data = '['
   local draw = '['
   local texts = '['
   local arr = split(shapeText, {by=',', checkSelection=true, checkEscapeNewLine=true, checkWidth=true, widthPad=2.0})
   local _,th = getTextSize('AA')
   local sum = 0
   local totalSum = 0
   local dataEnd = 0
   local prevx = '-w/2'
   if #arr == 0 then
     data = '["0", "0", "w", "h", "0.001", "0.001", "0"'
     draw = '[{"path": "R 0 1 2 3 4 5 6"}'
     goto last
   end
   for id = 1,#arr do
     if data ~= '[' then data = data..', ' end
     if texts ~= '[' then texts = texts..', ' end
     if draw ~= '[' then draw = draw..', ' end
     sum = sum + arr[id].widthRatio
     totalSum = totalSum + arr[id].width
     local fill = "-1"
     if arr[id].selected then
       fill = "-1710619"
     end
     local curx = '-w/2+w*'..tostring(sum)
     data = data..'"'..prevx..'+'..rad..'", "-h/2", "'..prevx..'+'..radk..'", "-h/2", "'..prevx..'", "-h/2+'..radk..'", "'..prevx..'", "-h/2+'..rad..'", "'..prevx..'", "h/2","'..curx..'", "h/2", "'..curx..'", "-h/2+'..rad..'", "'..curx..'", "-h/2+'..radk..'", "'..curx..'-'..radk..'", "-h/2", "'..curx..'-'..rad..'", "-h/2"'
     draw = draw..' {"path":"M '..seq(dataEnd,2)..' C '..seq(dataEnd+2,6)..' L'..seq(dataEnd+8,2)..' L '..seq(dataEnd+10,2)..' L '..seq(dataEnd+12, 2)..' C'..seq(dataEnd+14,6)..' Z", "style":{"fillpaint":{"color":'..fill..',"type":2}}}'
     dataEnd = dataEnd + 20
     data = data..',"'..prevx..'+w*0.5*'..tostring(arr[id].widthRatio)..'", "0", "w*'..tostring(arr[id].widthRatio)..'", "h", "0"'
     texts = texts..'{"location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'", "text":"'..tostring(escapeJson(arr[id].word))..'"}'
     dataEnd = dataEnd + 5
     prevx = curx
   end
   ::last::
   texts = texts..']'
   data = data..']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..'}'
   return {template=json, minw=totalSum+8, minh=th+8 }
end
