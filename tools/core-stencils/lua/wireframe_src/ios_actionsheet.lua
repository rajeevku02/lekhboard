function generate(params, shapeText)
   local data = '['
   local draw = '['
   local texts = '['
   local arr = splitLines(shapeText)
   local gap = 8
   local ht = ''
   local dataEnd = 0
   if #arr == 0 then
     data = '["0", "0", "w", "h", "1", "1", "0"'
     draw = '[{"path": "R 0 1 2 3 4 5 6"}'
     goto last
   end
   if #arr == 1 then
     data = '["0", "0", "w", "h", "1", "1", "0"'
     draw = '[{"path": "R 0 1 2 3 4 5 6", "style": {"fillpaint":{"color":-1, "type": 2}}}'
     texts = '[{"location": "0 1 2 3 6", "text": "'..escapeJson(shapeText)..'"}'
     goto last
   end
   
   ht = '(h-'..tostring(gap)..')/'..tostring(#arr)
   data = data..'"0", "-h/2+'..tostring(#arr-1)..'*0.5*'..ht..'", "w", "'..tostring(#arr-1)..'*'..ht..'", "6", "6", "0"'
   draw = draw..'{"path": "R 0 1 2 3 4 5 6", "style": {"strokewidth": 0.4}}'
   data = data..', "0", "h/2-0.5*'..ht..'", "w", "'..ht..'", "6", "6", "0"'
   draw = draw..',{"path": "R 7 8 9 10 11 12 13", "style": {"strokewidth": 0.4}}'
   texts = texts..'{"location": "7 8 9 10 13", "text": "'..escapeJson(arr[#arr])..'"}'
   dataEnd = 14
   for id = 1,#arr-1 do 
    data = data..', "0", "-h/2+'..tostring(id-1+0.5)..'*'..ht..'", "w", "'..ht..'", "0"'
    texts = texts..', {"location": "'
    for i = 0,4 do texts = texts..tostring(dataEnd+i)..' ' end
    texts = texts..'", "text": "'..escapeJson(arr[id])..'"}'
    dataEnd = dataEnd + 5
    if id < #arr -1 then
      data = data..', "-w/2", "-h/2+'..tostring(id)..'*'..ht..'", "w/2", "-h/2+'..tostring(id)..'*'..ht..'"'
      draw = draw..', {"style":{"disabled": true}, "path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
      dataEnd = dataEnd + 4
    end
   end

   ::last::
   texts = texts..']'
   data = data..']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..'}'
   return {template=json, minw=-1, minh=-1 }
end
