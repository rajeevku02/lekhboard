function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "w/2", "-h/2", "w/2", "h/2", "-w/2", "h/2"'
   local draw = '[{"path":"M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"fillpaint":{"color":-2434342, "type":2}, "strokewidth": 0}}'
   local texts = '['
   local embeds = '['
   local dataEnd = 8
   local icon = params['icon']
   if icon then
     data = data..', "-w/2 + 5 + h/4", "0", "h/2", "h/2", "0"'
     if icon == 'back' then
       embeds = embeds..'{"name":"avabodh.wireframe.icon_chevron-left", "location": "8 9 10 11 12", "mode": "aspect"}'
     else
       embeds = embeds..'{"name":"avabodh.wireframe.icon_bars", "location": "8 9 10 11 12", "mode": "aspect"}'
     end
     dataEnd = dataEnd + 5
   end
   if params['overflow'] then
     data = data..', "w/2 - 5 - h/4", "0", "h/2", "h/2", "0"'
     if embeds ~= '[' then embeds = embeds..', ' end
     embeds = embeds..'{"name":"avabodh.wireframe.icon_ellipsis-v", "mode": "aspect", "location": "'
     for i = 0,4 do embeds = embeds..tostring(dataEnd+i)..' ' end
     embeds = embeds..'"}'
     dataEnd = dataEnd + 5
   end

   local tw,th = getTextSize(shapeText)
   tw = tw + 2
   data = data..', "-w/2 + 5 + h/2 + 10 + '..tostring(tw/2)..'", "0", "'..tostring(tw)..'", "h", "0"'
   texts = texts..'{"style":{"textalignhorizontal": 2}, "text": "'..escapeJson(shapeText)..'", "location": "'
   for i = 0,4 do texts = texts..tostring(dataEnd+i)..' ' end
   texts = texts..'"}'

   texts = texts..']'
   data = data..']'
   draw = draw..']'
   embeds = embeds..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":'..texts..', "embeds":'..embeds..'}'
   return {template=json, minw=tw+32, minh=th+8 }
end
