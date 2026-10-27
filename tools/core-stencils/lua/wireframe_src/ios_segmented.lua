function generate(params, shapeText)
   local rad = 6
   local K = 0.4477152502
   local rads = tostring(rad)
   local radk = tostring(rad * K)
   local data = '["-w/2+'..radk..'", "-h/2", "-w/2", "-h/2+'..radk..'", "-w/2", "-h/2+'..rads..'", "-w/2", "h/2-'..rads..'", "-w/2", "h/2-'..radk..'", "-w/2+'..radk..'", "h/2", "-w/2+'..rads..'", "-h/2", "-w/2+'..rads..'", "h/2"'
   local draw = '['
   local texts = '['
   local arr = split(shapeText, {by=',', checkSelection=true, checkEscapeNewLine=true, checkWidth=true, widthPad=2.0})
   local _,ch = getTextSize('AA')
   local sum = 0
   local totalSum = 0
   local dataEnd = 16
   local last = 12
   local prevx = '-w/2'
   if #arr == 0 then
     data = '["0", "0", "w", "h", "'..rads..'", "'..rads..'", "0"'
     draw = '[{"path": "R 0 1 2 3 4 5 6"}'
     goto last
   end
   if #arr == 1 then
     data = '["0", "0", "w", "h", "'..rads..'", "'..rads..'", "0"'
     draw = '[{"path": "R 0 1 2 3 4 5 6"}'
     texts = '[{"location": "0 1 2 3 6", "text":"'..escapeJson(arr[1].word)..'"}'
     goto last
   end
   for id = 1,#arr do
     if draw ~= '[' then draw = draw..', ' end
     if texts ~= '[' then texts = texts..', ' end
     sum = sum + arr[id].widthRatio
     totalSum = totalSum + arr[id].width
     local fill = "-1"
     if arr[id].selected then
       fill = "-16745729"
     end
     if id == 1 then
       data = data..',"-w/2+w*'..tostring(sum)..'", "-h/2", "-w/2+w*'..tostring(sum)..'", "h/2"'
       draw = draw..' {"path":"M 12 13 C 0 1 2 3 4 5 L 6 7 C 8 9 10 11 14 15 L 18 19 L 16 17 Z", "style":{"fillpaint":{"color":'..fill..',"type":2}}}'
       dataEnd = dataEnd + 4
     elseif id == #arr then
       data = data..', "w/2-'..rads..'", "h/2", "w/2-'..radk..'", "h/2", "w/2", "h/2-'..radk..'", "w/2", "h/2-'..rads..'", "w/2", "-h/2 +'..rads..'", "w/2", "-h/2+'..radk..'", "w/2-'..radk..'", "-h/2", "w/2-'..rads..'", "-h/2"'
       draw = draw..' {"path":"M '..tostring(last)..' '..tostring(last+1)..' L '..tostring(last+2)..' '..tostring(last+3)..' L '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' C '..tostring(dataEnd +2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..' '..tostring(dataEnd+5)..' '..tostring(dataEnd+6)..' '..tostring(dataEnd+7)..' L '..tostring(dataEnd+8)..' '..tostring(dataEnd+9)..' C '..tostring(dataEnd +10)..' '..tostring(dataEnd+11)..' '..tostring(dataEnd+12)..' '..tostring(dataEnd+13)..' '..tostring(dataEnd+14)..' '..tostring(dataEnd+15)..' Z", "style":{"fillpaint":{"color":'..fill..',"type":2}}}'
       dataEnd = dataEnd + 16
     else
       data = data..',"-w/2+w*'..tostring(sum)..'", "-h/2", "-w/2+w*'..tostring(sum)..'", "h/2"'
       draw = draw..' {"path":"M '..tostring(last)..' '..tostring(last+1)..' L '..tostring(last+2)..' '..tostring(last+3)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' L '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' Z", "style":{"fillpaint":{"color":'..fill..',"type":2}}}'
       dataEnd = dataEnd + 4
     end
     last = dataEnd - 4
     data = data..',"'..prevx..'+w*0.5*'..tostring(arr[id].widthRatio)..'", "0", "w*'..tostring(arr[id].widthRatio)..'", "h", "0"'
     prevx = '-w/2+w*'..tostring(sum)
     texts = texts..'{"location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'", "text":"'..tostring(escapeJson(arr[id].word))..'"'
     if arr[id].selected then
       texts = texts..', "style": {"textfill": {"color": -1, "type":2}}'
     end
     texts = texts..'}'
     dataEnd = dataEnd + 5
   end
   ::last::
   texts = texts..']'
   data = data..']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..'}'
   return {template=json, minw=totalSum+8, minh=ch+8 }
end
