function generate(params, shapeText)
   local data = '['
   local draw = '['
   local texts = '['
   local arr = split(shapeText, {by=',', checkSelection=true, checkEscapeNewLine=true, checkWidth=true, widthPad=20.0})
   local tw,th = getTextSize('AA')
   local sum = 0
   local ps = 12
   for id = 1,#arr do
     sum = sum + arr[id].width
   end
   data = data..'"-w/2 + '..tostring(sum/2)..'", "-'..tostring(ps/2)..'", "'..tostring(sum)..'", "h-'..tostring(ps)..'", "4", "4", "0"'
   draw = draw..'{"path": "R 0 1 2 3 4 5 6", "style": {"strokewidth": 0, "fillpaint":{"color":-11447725,"type":2}}}'
   local dataEnd = 7
   local xc = 0
   for id = 1,#arr do
     local w = arr[id].width
     data = data..', "-w/2 + '..tostring(xc + w/2)..'", "d(1)", "'..tostring(w)..'", "d(3)", "0"'
     if texts ~= '[' then texts = texts..', ' end
     texts = texts..'{"style":{"textfill":{"color":-1,"type":2}}, "location": "'
     for c = 0,4 do texts = texts..tostring(dataEnd+c)..' ' end
     texts = texts..'", "text": "'..escapeJson(arr[id].word)..'"}'
     dataEnd = dataEnd + 5
     xc = xc + w
     if id ~= #arr then
       data = data..', "-w/2 +'..tostring(xc)..'", "-h/2", "-w/2+'..tostring(xc)..'", "h/2"'
       draw = draw..', {"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' ", "style": {"strokewidth": 2.0, "strokepaint":{"color":-1,"type":2}}}'
       dataEnd = dataEnd + 4
     end
     if arr[id].selected then
       data = data..', "-w/2 + '..tostring(xc-w/2)..'-'..tostring(ps)..'", "h/2-'..tostring(ps)..'", "d('..tostring(dataEnd)..')+'..tostring(ps/2)..'", "h/2", "d('..tostring(dataEnd)..')+'..tostring(ps)..'", "h/2-'..tostring(ps)..'"'
       draw = draw..',{"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' L '..tostring(dataEnd+4)..' '..tostring(dataEnd+5)..' Z", "style":{"strokewidth":0, "fillpaint":{"color":-11447725,"type":2}}}'
       dataEnd = dataEnd + 6
     end
   end
   texts = texts..']'
   data = data..']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..'}'
   return {template=json, minw=sum, minh=th }
end
