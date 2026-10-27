function generate(params, shapeText)
   local rad = 8
   local K = 0.5522847498
   local ps = 14
   local draw = '['
   local data = '['
   local pos = params['position']
   local pointer = params['pointer']
   if pos == nil then pos = 0 end
   if pos < 0 then pos = 0 end
   if pos > 1 then pos = 1 end
   local textw = 'w'
   local texth = 'h'
   local textx = '0'
   local texty = '0'
   if pointer == 'left' or pointer == 'right' then
     local topx = '-w/2'
     local boxx = '-w/2 + '..tostring(ps)
     local starty = '-h/2 +'..tostring(rad)..'+'..tostring(pos)..'*(h '..tostring(-2*rad - ps)..')'
     local midy = starty..'+'..tostring(ps/2)
     local endy = starty..'+'..tostring(ps)
     textw = 'w-'..tostring(ps)
     if pointer == 'right' then
       topx = 'w/2'
       boxx = 'w/2 - '..tostring(ps)
       textx = '-'..tostring(ps/2)
     else
       textx = tostring(ps/2)
     end
     data = data..'"'..boxx..'", "-h/2+'..tostring(rad)..'", "'..boxx..'", "'..starty..'", "'..topx..'", "'..midy..'", "'..boxx..'", "'..endy..'","'..boxx..'", "h/2 - '..tostring(rad)..'"'
     if pointer == 'right' then
       data = data..', "'..boxx..'", "h/2 - '..tostring(rad*(1-K))..'", "'..boxx..'-'..tostring(rad*(1-K))..'", "h/2", "'..boxx..'-'..tostring(rad)..'", "h/2", "-w/2+'..tostring(rad)..'", "h/2", "-w/2+'..tostring(rad*(1-K))..'", "h/2", "-w/2", "h/2-'..tostring(rad*(1-K))..'", "-w/2", "h/2-'..tostring(rad)..'", "-w/2", "-h/2 +'..tostring(rad)..'", "-w/2", "-h/2 + '..tostring(rad*(1-K))..'", "-w/2+'..tostring(rad*(1-K))..'", "-h/2", "-w/2+'..tostring(rad)..'", "-h/2", "'..boxx..'-'..tostring(rad)..'", "-h/2", "'..boxx..'-'..tostring(rad*(1-K))..'", "-h/2", "'..boxx..'", "-h/2+'..tostring(rad*(1-K))..'", "'..boxx..'", "-h/2+'..tostring(rad)..'"'
     else
       data = data..', "'..boxx..'", "h/2 - '..tostring(rad*(1-K))..'", "'..boxx..'+'..tostring(rad*(1-K))..'", "h/2", "'..boxx..'+'..tostring(rad)..'", "h/2", "w/2-'..tostring(rad)..'", "h/2", "w/2-'..tostring(rad*(1-K))..'", "h/2", "w/2", "h/2-'..tostring(rad*(1-K))..'", "w/2", "h/2-'..tostring(rad)..'", "w/2", "-h/2 +'..tostring(rad)..'", "w/2", "-h/2 + '..tostring(rad*(1-K))..'", "w/2-'..tostring(rad*(1-K))..'", "-h/2", "w/2-'..tostring(rad)..'", "-h/2", "'..boxx..'+'..tostring(rad)..'", "-h/2", "'..boxx..'+'..tostring(rad*(1-K))..'", "-h/2", "'..boxx..'", "-h/2+'..tostring(rad*(1-K))..'", "'..boxx..'", "-h/2+'..tostring(rad)..'"'
     end
   else
     local topy = '-h/2'
     local boxy = '-h/2 + '..tostring(ps)
     local startx = '-w/2 +'..tostring(rad)..'+'..tostring(pos)..'*(w '..tostring(-2*rad - ps)..')'
     local midx = startx..'+'..tostring(ps/2)
     local endx = startx..'+'..tostring(ps)
     texth = 'h-'..tostring(ps)
     if pointer == 'bottom' then
       topy = 'h/2'
       boxy = 'h/2 - '..tostring(ps)
       texty = '-'..tostring(ps/2)
     else
       texty = tostring(ps/2)
     end
     data = data..'"-w/2+'..tostring(rad)..'", "'..boxy..'", "'..startx..'", "'..boxy..'", "'..midx..'", "'..topy..'", "'..endx..'", "'..boxy..'", "w/2-'..tostring(rad)..'", "'..boxy..'"'
     if pointer == 'bottom' then
       data = data..', "w/2 -'..tostring(rad*(1-K))..'", "'..boxy..'", "w/2", "'..boxy..'-'..tostring(rad*(1-K))..'", "w/2", "'..boxy..'-'..tostring(rad)..'", "w/2", "-h/2 +'..tostring(rad)..'", "w/2", "-h/2+'..tostring(rad*(1-K))..'", "w/2-'..tostring(rad*(1-K))..'", "-h/2", "w/2-'..tostring(rad)..'", "-h/2", "-w/2+'..tostring(rad)..'", "-h/2", "-w/2+'..tostring(rad*(1-K))..'", "-h/2", "-w/2", "-h/2+'..tostring(rad*(1-K))..'", "-w/2", "-h/2+'..tostring(rad)..'", "-w/2", "'..boxy..'-'..tostring(rad)..'", "-w/2", "'..boxy..'-'..tostring(rad*(1-K))..'", "-w/2+'..tostring(rad*(1-K))..'", "'..boxy..'", "-w/2+'..tostring(rad)..'", "'..boxy..'"'
     else
       data = data..', "w/2 -'..tostring(rad*(1-K))..'", "'..boxy..'", "w/2", "'..boxy..'+'..tostring(rad*(1-K))..'", "w/2", "'..boxy..'+'..tostring(rad)..'", "w/2", "h/2 -'..tostring(rad)..'", "w/2", "h/2-'..tostring(rad*(1-K))..'", "w/2-'..tostring(rad*(1-K))..'", "h/2", "w/2-'..tostring(rad)..'", "h/2", "-w/2+'..tostring(rad)..'", "h/2", "-w/2+'..tostring(rad*(1-K))..'", "h/2", "-w/2", "h/2-'..tostring(rad*(1-K))..'", "-w/2", "h/2-'..tostring(rad)..'", "-w/2", "'..boxy..'+'..tostring(rad)..'", "-w/2", "'..boxy..'+'..tostring(rad*(1-K))..'", "-w/2+'..tostring(rad*(1-K))..'", "'..boxy..'", "-w/2+'..tostring(rad)..'", "'..boxy..'"'
     end
   end
   draw = draw..'{"style":{"fillpaint":{"color":-1,"type":2}}, "path": "M 0 1 L 2 3 L 4 5 L 6 7 L 8 9 C 10 11 12 13 14 15 L 16 17 C 18 19 20 21 22 23 L 24 25 C 26 27 28 29 30 31 L 32 33 C 34 35 36 37 38 39 Z"}'
   data = data..', "'..textx..'", "'..texty..'", "'..textw..'", "'..texth..'", "0"'
   local texts = '[{"location":" 40 41 42 43 44", "text":"'..escapeJson(shapeText)..'"}]'
   data  = data .. ']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw ..', "texts":'..texts..'}'
   return {template=json, minw=ps+2*rad, minh=ps+2*rad }
end
