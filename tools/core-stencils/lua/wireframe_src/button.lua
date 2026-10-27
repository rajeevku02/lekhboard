function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local embeds = '[]'
   local dataEnd = 8
   local draw = '[{"path":"M 0 1 L 2 3 L 4 5 L 6 7 Z"'
   local texts = '['
   if params.state=='in focus' then
     style = '"style":{"fillpaint":{"color":-10504995,"type":2}}'
   elseif params.state=='selected' then
     style = '"style":{"fillpaint":{"color":-1,"type":2}, "strokepaint":{"color":-10504995,"type":2}}'
   else
     style = '"style":{"fillpaint":{"color":-1,"type":2}}'
   end
   draw = draw .. ',' .. style .. '}'
   if params.menu then
      data = data .. ',"w/2 - 12", "-4", "w/2 - 4", "-4", "w/2-8", "3"'
      dataEnd = dataEnd + 6
      draw  = draw .. ', {"path":"M 8 9 L 10 11 L 12 13 Z", "style":{"fillpaint":{"color":-436207616,"type":2},"joinstyle":1, "capstyle":3}}'
   end
   draw = draw .. ']'
   local tw, th
   tw, th = getTextSize(shapeText) 
   if params.icon and params.icon ~= "" then
      if params['icon size'] == 'propotional to shape' then
        halfIconSize = 'h/3'
      else
        tw, th = getTextSize('AA') 
        halfIconSize = tostring(th*0.5)
        tw, th = getTextSize(shapeText) 
      end
      tw = tw + 4
      data = data .. ', "'..halfIconSize..'", "0", "'..tostring(tw)..'", "h", "0"'
      texts = '[{"location":"'
      for i = 0,4 do
        texts = texts..tostring(dataEnd+i)..' '
      end
      dataEnd = dataEnd + 5
      halfTw = tostring(tw/2)
      data = data..', "-'..halfTw..'-2", "0", "2*'..halfIconSize..'", "2*'..halfIconSize..'", "0"'
      texts = texts..'","style":{"textalignhorizontal":2},"text":' .. '"' .. escapeJson(shapeText) .. '"' .. '}]'
      embeds =  '[{ "name": "'..params.icon..'", "location":"'
      for i = 0,4 do
        embeds = embeds..tostring(dataEnd+i)..' '
      end
      embeds = embeds..'", "inheritstyle": true, "mode": "aspect"}]'
   else
     texts = '[{"location":"default","text":' .. '"' .. escapeJson(shapeText) .. '"' .. '}]'
   end
   data = data ..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts .. ',"embeds":'..embeds..'}'

   local disabled = false
   if params.state == 'disabled' then
     disabled = true
   end
   return {template=json, minw=tw+16 , minh=th+4 ,disabled=disabled }
end
