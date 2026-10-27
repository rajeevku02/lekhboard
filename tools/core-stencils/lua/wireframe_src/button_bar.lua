function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2"'
   local draw = '['
   local texts = '['
   local arr = split(shapeText, {by=',', checkSelection=true, checkEscapeNewLine=true, checkWidth=true, widthPad=2.0})
   local sum = 0
   local tw, th = getTextSize('A')
   local totalWidth = 0
   local dataEnd = 4
   local last = 0
   local prevx = '-w/2'
   if #arr == 0 then
     data = '["0", "0", "w", "h", "0.001", "0.001", "0"'
     draw = '[{"path": "R 0 1 2 3 4 5 6"}'
     goto last
   end
   for id = 1,#arr do
     if id ~= 1 then
       texts = texts..', '
       draw = draw..","
     end
     totalWidth = totalWidth + arr[id].width + 8
     sum = sum + arr[id].widthRatio
     local fill = "-1"
     if arr[id].selected then
       fill = "-10504995"
     end
     data = data..',"-w/2+w*'..tostring(sum)..'", "-h/2", "-w/2+w*'..tostring(sum)..'", "h/2"'
     draw = draw..' {"path":"M '..tostring(last)..' '..tostring(last+1)..' L '..tostring(last+2)..' '..tostring(last+3)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' L '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' Z", "style":{"fillpaint":{"color":'..fill..',"type":2}}}'
     last = dataEnd
     dataEnd = dataEnd + 4
     data = data..',"'..prevx..'+w*0.5*'..tostring(arr[id].widthRatio)..'", "0", "w*'..tostring(arr[id].widthRatio)..'", "h", "0"'
     prevx = '-w/2+w*'..tostring(sum)
     texts = texts..'{"location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'", "text":"'..tostring(escapeJson(arr[id].word))..'"}'
     dataEnd = dataEnd + 5
   end
   ::last::
   texts = texts..']'
   data = data..']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..'}'
   return {template=json, minw=totalWidth+8, minh=th+4 }
end
