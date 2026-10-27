function generate(params, shapeText)
   local data = '["w/2", "h/2", "w/2", "-h/2", "-w/2", "-h/2", "-w/2", "h/2"'
   local draw = '[{"path":"M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"fillpaint":{"color":-1,"type":2}}}'
   local texts = '['
   local arr = split(shapeText, {by=',', checkSelection=true, checkDisabled=true, checkEscapeNewLine=true, checkWidth=true, widthPad=18.0})
   local sum = 0
   local dataEnd = 8
   local last = 4
   local prevx = '-w/2'
   local height = 0
   for id = 1,#arr do
     if id ~= 1 then
       texts = texts..', '
     end
     if arr[id].height > height then height = arr[id].height end
     sum = sum + arr[id].width
     local fill = ''
     if arr[id].selected then
       fill = "-10504995"
       fill = ',"fillpaint":{"color":-10504995,"type":2}'
     end
     local disabled = ''
     if arr[id].disabled then
       disabled = '"disabled": true,'
     end
     data = data..',"-w/2+'..tostring(sum)..'", "-h/2", "-w/2+'..tostring(sum)..'", "h/2"'
     draw = draw..', {"path":"M '..tostring(last)..' '..tostring(last+1)..' L '..tostring(last+2)..' '..tostring(last+3)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' L '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' Z", "style":{'..disabled..'"strokewidth":0'..fill..'}}'
     last = dataEnd
     dataEnd = dataEnd + 4
     data = data..',"'..prevx..'+0.5*'..tostring(arr[id].width)..'", "0", "'..tostring(arr[id].width)..'", "h", "0"'
     prevx = '-w/2+'..tostring(sum)
     texts = texts..'{"style":{'..disabled..'},"location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'", "text":"'..tostring(escapeJson(arr[id].word))..'"}'
     dataEnd = dataEnd + 5
   end
   texts = texts..']'
   data = data..']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..'}'
   return {template=json, minw=sum+8, minh=height+8 }
end
