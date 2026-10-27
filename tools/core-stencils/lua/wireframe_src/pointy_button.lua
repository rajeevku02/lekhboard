function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local embeds = '['
   local draw = '[{"path":"M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"fillpaint":{"color":-1,"type":2}, "strokewidth": 0}}'
   local texts = '['
   local name = ''
   local tw,th = getTextSize(shapeText)
   if params['pointer'] == 'right' then
     data = data..', "w/2-h*0.3", "0", "h*0.6", "h*0.6", "0", "-h*0.3", "0", "w-h*0.6", "h", "0"'
     name = 'avabodh.wireframe.icon_angle-right'
   else
     data = data..', "-w/2+h*0.3", "0", "h*0.6", "h*0.6", "0", "h*0.3", "0", "w-h*0.6", "h", "0"'
     name = 'avabodh.wireframe.icon_angle-left'
   end
   embeds = embeds..'{"location": "8 9 10 11 12", "name": "'..name..'", "inheritstyle": true, "mode": "aspect"}'
   texts = texts..'{"location": "13 14 15 16 17", "text":"'..escapeJson(shapeText)..'"}'
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   embeds = embeds..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts ..',"embeds":'..embeds..'}'
   return {template=json, minw=tw+8, minh=th+8 }
end
