function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2"'
   local draw = '['
   local texts = '['
   local embeds = '['
   local arr = split(shapeText, {by=',', checkWidth=true, checkDisabled=true, widthPad=12.0})
   local _,ch = getTextSize('AA')
   local icw = ch*0.7
   local sum = 0
   local dataEnd = 4
   local last = 0
   local prevx = '-w/2'
   for id = 1, #arr do
     if texts ~= '[' then
       texts = texts..', '
     end
     data = data..', "-w/2+'..tostring(sum)..'+'..tostring(arr[id].width/2)..'", "0", "'..tostring(arr[id].width)..'", "h", "0"'
     texts = texts..'{'
     if id == #arr then
       texts = texts..'"style": {"textfill":{"color":-16777216, "type":2}},'
     end
     texts = texts..'"location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'", "text":"'..tostring(escapeJson(arr[id].word))..'"}'
     dataEnd = dataEnd + 5
     sum = sum + arr[id].width
     if id < #arr then
       data = data..', "-w/2+'..tostring(sum+icw/2)..'", "0", "'..tostring(icw)..'", "'..tostring(icw)..'", "0"'
       if embeds ~= '[' then
         embeds = embeds..', '
       end
       embeds =  embeds..'{ "name": "avabodh.wireframe.icon_chevron-right", "location":"'
       for i = 0,4 do
         embeds = embeds..tostring(dataEnd+i)..' '
       end
       embeds = embeds..'", "inheritstyle": true, "mode": "aspect"}'
       dataEnd = dataEnd + 5
     end
     sum = sum + icw
   end
   texts = texts..']'
   data = data..']'
   draw = draw..']'
   embeds = embeds..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..', "embeds":'..embeds..'}'
   return {template=json, minw=sum, minh=ch }
end
