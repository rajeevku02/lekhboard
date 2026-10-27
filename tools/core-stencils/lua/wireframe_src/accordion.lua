function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local draw = '[{"path": "M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"fillpaint":{"color":-1,"type":2} }}'
   local texts = '['
   local arr = split(shapeText, { by='\n', checkSelection=true, checkHeight=true, checkWidth=true, heightPad=12, checkDisabled=true})
   local dataEnd = 8
   local id = 1
   local prevy = '-h/2'
   local sum = 0
   local maxw = 0
   while id <= #arr do
     if arr[id].width > maxw then maxw = arr[id].width end
     data = data..', "0", "'..prevy..'+'..tostring(arr[id].height/2)..'", "w", "'..tostring(arr[id].height)..'", "0"'
     if texts ~= '[' then texts = texts..', ' end
     texts = texts..'{'
     if arr[id].disabled then
       texts = texts..'"style": {"disabled":true},'
     end
     texts = texts..'"text": "'..escapeJson(arr[id].word)..'", "location": "'
     for i=0,4 do texts = texts..tostring(dataEnd+i)..' ' end
     texts = texts..'"}'
     dataEnd = dataEnd + 5
     if arr[id].selected then
       local nexty = prevy..'+'..tostring(arr[id].height)
       data = data..', "-w/2", "'..prevy..'", "-w/2", "'..nexty..'", "w/2", "'..nexty..'", "w/2", "'..prevy..'"'
       draw = draw..', { "style":{"fillpaint":{"color":-10504995,"type":2} }, "path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)
       for i=1,3 do draw = draw..' L '..tostring(dataEnd + 2*i)..' '..tostring(dataEnd + 2*i + 1) end
       draw = draw..' Z"}'
       dataEnd = dataEnd + 8
     end
     sum = sum + arr[id].height
     prevy = '-h/2 + '..tostring(sum)
     data = data..', "-w/2", "'..prevy..'", "w/2", "'..prevy..'"'
     draw = draw..', {"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
     dataEnd = dataEnd + 4
     id = id + 1
     if arr[id-1].selected then break end
   end
   local prevy = 'h/2'
   local totalSum = sum
   local sum = 0
   local endId = #arr
   while endId >= id do
     if arr[id].width > maxw then maxw = arr[id].width end
     data = data..', "0", "'..prevy..'-'..tostring(arr[endId].height/2)..'", "w", "'..tostring(arr[endId].height)..'", "0"'
     if texts ~= '[' then texts = texts..', ' end
     texts = texts..'{'
     if arr[endId].disabled then
       texts = texts..'"style": {"disabled":true},'
     end
     texts = texts..'"text": "'..escapeJson(arr[endId].word)..'", "location": "'
     for i=0,4 do texts = texts..tostring(dataEnd+i)..' ' end
     texts = texts..'"}'
     dataEnd = dataEnd + 5
     sum = sum + arr[endId].height
     prevy = 'h/2 - '..tostring(sum)
     data = data..', "-w/2", "'..prevy..'", "w/2", "'..prevy..'"'
     draw = draw..', {"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
     dataEnd = dataEnd + 4
     endId = endId - 1
   end
   totalSum = totalSum + sum
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts ..'}'
   return {template=json, minw=maxw+8, minh=totalSum+12 }
end
