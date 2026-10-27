function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2"'
   local draw = '['
   local texts = '['
   local arr = split(shapeText, {by=',', checkWidth=true, checkDisabled=true, widthPad=18.0})
   local _,ch = getTextSize('AA')
   local sum = 0
   local dataEnd = 4
   local last = 0
   local prevx = '-w/2'
   for id = 1, #arr do
     if texts ~= '[' then
       texts = texts..', '
     end
     data = data..', "-w/2+'..tostring(sum)..'+'..tostring(arr[id].width/2)..'", "0", "'..tostring(arr[id].width)..'", "h", "0"'
     texts = texts..'{"location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'", "text":"'..tostring(escapeJson(arr[id].word))..'"}'
     dataEnd = dataEnd + 5
     sum = sum + arr[id].width
     if id < #arr and params['separator line'] then
       data = data..', "-w/2+'..tostring(sum)..'", "-'..tostring(ch/2)..'", "-w/2+'..tostring(sum)..'", "'..tostring(ch/2)..'"'
       if draw ~= '[' then
         draw = draw..', '
       end
       draw = draw..'{"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       dataEnd = dataEnd + 4
     end
   end
   texts = texts..']'
   data = data..']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..'}'
   return {template=json, minw=sum, minh=ch }
end
