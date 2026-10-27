function generate(params, shapeText)
   local data = '['
   local draw = '['
   local texts = '['
   local arr = split(shapeText, {by=',', checkDisabled=true, checkSelection=true, checkWidth=true, widthPad=20})
   local _,lineHeight = getTextSize('AA')
   local tabHeight = 30 + lineHeight*0.2
   local sum = 0
   for id = 1, #arr do
     sum = sum + arr[id].width
   end
   local startx = '-w/2'
   local endx = '-w/2+'..tostring(sum)
   if params['align'] == 'center' then
     startx = tostring(-sum/2)
     endx = tostring(sum/2)
   elseif params['align'] == 'right' then
     startx = 'w/2 - '..tostring(sum)
     endx = 'w/2'
   end
   local boxy = '-h/2 + '..tostring(tabHeight)
   local topy = '-h/2'
   local hth = '+'..tostring(tabHeight/2)
   if params['position'] == 'bottom' then
     boxy = 'h/2 - '..tostring(tabHeight)
     topy = 'h/2'
     hth = '-'..tostring(tabHeight/2)
   end
   if params['position'] == 'bottom' then
     data = data..'"-w/2", "'..boxy..'", "'..startx..'", "'..boxy..'", "'..startx..'", "h/2", "'..endx..'","h/2", "'..endx..'", "'..boxy..'", "w/2", "'..boxy..'", "w/2", "-h/2", "-w/2", "-h/2"'
     draw = draw..'{"path":"M 0 1 L 2 3 L 4 5 L 6 7 L 8 9 L 10 11 L 12 13 L 14 15 Z","style":{"fillpaint":{"color":-637534209,"type":2} } }'
   else
     data = data..'"-w/2", "'..boxy..'", "'..startx..'", "'..boxy..'", "'..startx..'", "-h/2", "'..endx..'","-h/2", "'..endx..'", "'..boxy..'", "w/2", "'..boxy..'", "w/2", "h/2", "-w/2", "h/2"'
     draw = draw..'{"path":"M 0 1 L 2 3 L 4 5 L 6 7 L 8 9 L 10 11 L 12 13 L 14 15 Z","style":{"fillpaint":{"color":-637534209,"type":2} } }'
   end
   local prevx = startx
   local dataEnd = 16
   for id = 1, #arr do
     local curx = prevx..'+'..arr[id].width
     if id < #arr then
       data = data..', "'..curx..'", "'..topy..'", "'..curx..'", "'..boxy..'"'
       draw = draw..', {"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       dataEnd = dataEnd + 4
     end
     if not arr[id].selected then
       data = data..', "'..prevx..'", "'..boxy..'", "'..curx..'", "'..boxy..'"'
       draw = draw..', {"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       dataEnd = dataEnd + 4
       data = data..', "'..prevx..'", "'..boxy..'", "'..curx..'", "'..boxy..'", "'..curx..'", "'..topy..'", "'..prevx..'", "'..topy..'"'
       draw = draw..', {"style": {"fillpaint":{"color":-1184275,"type":2}}, "path": " M '..tostring(dataEnd)..' '..tostring(dataEnd+1)
       for i = 1, 3 do draw = draw..' L '..tostring(dataEnd+2*i)..' '..tostring(dataEnd+2*i+1) end
       draw = draw..' Z"}'
       dataEnd = dataEnd + 8
     end
     data = data..', "'..prevx..'+'..tostring(arr[id].width/2)..'", "'..topy..tostring(hth)..'", "'..tostring(arr[id].width)..'", "'..tostring(tabHeight)..'", "0"'
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
     prevx = curx
   end
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   local containers = '["M 0 1 L 10 11 L 12 13 L 14 15 Z"]'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "containers":'..containers..', "texts":' ..texts ..', "alignpoints": "0 1"}'
   return {template=json, minw=sum, minh=tabHeight }
end
