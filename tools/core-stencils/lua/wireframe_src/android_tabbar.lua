function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local draw = '[{"path": "M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"strokewidth":0, "fillpaint":{"color":-1644826, "type":2}}}'
   local texts = '['
   local arr = split(shapeText, {by=',', checkSelection=true, checkEscapeNewLine=true, checkWidth=true, widthPad=2.0})
   local _,th = getTextSize('AA')
   local sum = 0
   local totalSum = 0
   local dataEnd = 8
   local sw = getStrokeWidth()
   local prevx = '-w/2'
   for id = 1,#arr do
     if id ~= 1 then
       texts = texts..', '
     end
     totalSum = totalSum + arr[id].width
     sum = sum + arr[id].widthRatio
     data = data..',"'..prevx..'+w*0.5*'..tostring(arr[id].widthRatio)..'", "0", "w*'..tostring(arr[id].widthRatio)..'", "h", "0"'
     texts = texts..'{"location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'", "text":"'..tostring(escapeJson(arr[id].word))..'"}'
     dataEnd = dataEnd + 5
     if arr[id].selected then
       local wd = arr[id].width + 6
       local y = 'h/2-'..tostring(sw)
       local c = prevx..'+w*0.5*'..tostring(arr[id].widthRatio)
       data = data..', "'..c..'-'..tostring(wd/2)..'", "'..y..'", "'..c..'+'..tostring(wd/2)..'", "'..y..'"'
       draw = draw..',{"path":"M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       dataEnd = dataEnd + 4
     end
     prevx = '-w/2+w*'..tostring(sum)
   end
   texts = texts..']'
   data = data..']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..'}'
   return {template=json, minw=totalSum + 8, minh=th+8 }
end
