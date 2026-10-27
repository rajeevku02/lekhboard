function generate(params, shapeText)
   local data = '['
   local draw = '['
   local texts = '['
   local arr = split(shapeText, {by='\n', checkDisabled=true, checkSelection=true, checkWidth=true, widthPad=20, heightPad=18})
   local _,lineHeight = getTextSize('AA')
   local maxw = 0
   local sum = 0
   for id = 1, #arr do
     sum = sum + arr[id].height
     if arr[id].width > maxw then maxw = arr[id].width end
   end
   local starty = '-h/2'
   local endy = '-h/2+'..tostring(sum)
   if params['align'] == 'center' then
     starty = tostring(-sum/2)
     endy = tostring(sum/2)
   elseif params['align'] == 'bottom' then
     starty = 'h/2 - '..tostring(sum)
     endy = 'h/2'
   end
   local boxx = '-w/2 + '..tostring(maxw)
   local lastx = '-w/2'
   local htw = '+'..tostring(maxw/2)
   if params['position'] == 'right' then
     boxx = 'w/2 - '..tostring(maxw)
     lastx = 'w/2'
     htw = '-'..tostring(maxw/2)
     data = data..'"'..boxx..'", "-h/2", "'..boxx..'", "'..starty..'", "'..lastx..'", "'..starty..'", "'..lastx..'", "'..endy..'", "'..boxx..'", "'..endy..'", "'..boxx..'", "h/2", "-w/2", "h/2", "-w/2", "-h/2"'
   else
     data = data..'"'..boxx..'", "-h/2", "'..boxx..'", "'..starty..'", "'..lastx..'", "'..starty..'", "'..lastx..'", "'..endy..'", "'..boxx..'", "'..endy..'", "'..boxx..'", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   end
   draw = draw..'{"path":"M 0 1 L 2 3 L 4 5 L 6 7 L 8 9 L 10 11 L 12 13 L 14 15 Z","style":{"fillpaint":{"color":-637534209,"type":2} } }'
   local dataEnd = 16
   local prevy = starty
   for id = 1, #arr do
     local cury = prevy..'+'..arr[id].height
     if id < #arr then
       data = data..', "'..lastx..'", "'..cury..'", "'..boxx..'", "'..cury..'"'
       draw = draw..', {"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       dataEnd = dataEnd + 4
     end
     if not arr[id].selected then
       data = data..', "'..boxx..'", "'..prevy..'", "'..boxx..'", "'..cury..'"'
       draw = draw..', {"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       dataEnd = dataEnd + 4
       data = data..', "'..lastx..'", "'..prevy..'", "'..lastx..'", "'..cury..'", "'..boxx..'", "'..cury..'", "'..boxx..'", "'..prevy..'"'
       draw = draw..', {"style": {"fillpaint":{"color":-1184275,"type":2}}, "path": " M '..tostring(dataEnd)..' '..tostring(dataEnd+1)
       for i = 1, 3 do draw = draw..' L '..tostring(dataEnd+2*i)..' '..tostring(dataEnd+2*i+1) end
       draw = draw..' Z"}'
       dataEnd = dataEnd + 8
     end
     data = data..', "'..lastx..htw..'", "'..prevy..'+'..tostring(arr[id].height/2)..'", "'..tostring(maxw)..'", "'..tostring(arr[id].height)..'", "0"'
     if texts ~= '[' then texts = texts..', ' end
     texts = texts..'{'
     if arr[id].disabled then
       texts = texts..'"style": {"disabled": true },'
     end
     texts = texts..'"location": "'
     for i = 0, 4 do
       texts = texts..tostring(dataEnd+i)..' '
     end
     texts = texts..'", "text": "'..escapeJson(arr[id].word)..'"}'
     dataEnd = dataEnd + 5
     prevy = cury
   end
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   local containers = '["M 0 1 L 10 11 L 12 13 L 14 15 Z"]'
   local json = '{"data":' .. data .. ',"draw":' .. draw ..', "containers":'..containers..', "texts":' ..texts ..', "alignpoints": "0 1"}'
   return {template=json, minw=maxw, minh=sum }
end
