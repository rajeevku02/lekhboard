function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local dataEnd = 8
   local draw = '[{"path":"M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"fillpaint":{"color":-1,"type":2}}}'
   local texts = '['
   local arr = splitLines(shapeText)
   if #arr == 0 then arr = {'', ''} end
   if #arr == 1 then arr[2] = '' end
   local tw, th = getTextSize(arr[1])
   local tw2,th2 = getTextSize(arr[2])
   local wd = tw
   if tw2*0.75 > wd then wd = tw2*0.75 end
   local ht = th + th2
   data = data..', "0", "-th(0,w)/2", "w", "th(0,w)", "0"'
   data = data..', "0", "th(1,w)", "w", "th(1,w)", "0"'
   texts = texts..'{"text":"'..escapeJson(arr[1])..'", "location": "8 9 10 11 12" }'
   texts = texts..',{"text":"'..escapeJson(arr[2])..'", "location": "13 14 15 16 17", "style": {"fontmultiplier": 0.75}}'
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts ..'}'
   return {template=json, minw=wd + 8, minh=ht + 8 }
end
