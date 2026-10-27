function generate(params, shapeText)
   local rad = 15
   local K = 0.5522847498
   local ps = 20
   local draw = '['
   local data = '['
   local pos = params['position']
   local pointer = params['pointer']
   if pos == nil then pos = 0 end
   if pos < 0 then pos = 0 end
   if pos > 1 then pos = 1 end
   if pointer == 'left' or pointer == 'right' then
     local topx = '-w/2'
     local boxx = '-w/2 + '..tostring(ps)
     local starty = '-h/2 +'..tostring(rad)..'+'..tostring(pos)..'*(h '..tostring(-2*rad - ps)..')'
     local midy = starty..'+'..tostring(ps/2)
     local endy = starty..'+'..tostring(ps)
     if pointer == 'right' then
       topx = 'w/2'
       boxx = 'w/2 - '..tostring(ps)
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
     if pointer == 'bottom' then
       topy = 'h/2'
       boxy = 'h/2 - '..tostring(ps)
     end
     data = data..'"-w/2+'..tostring(rad)..'", "'..boxy..'", "'..startx..'", "'..boxy..'", "'..midx..'", "'..topy..'", "'..endx..'", "'..boxy..'", "w/2-'..tostring(rad)..'", "'..boxy..'"'
     if pointer == 'bottom' then
       data = data..', "w/2 -'..tostring(rad*(1-K))..'", "'..boxy..'", "w/2", "'..boxy..'-'..tostring(rad*(1-K))..'", "w/2", "'..boxy..'-'..tostring(rad)..'", "w/2", "-h/2 +'..tostring(rad)..'", "w/2", "-h/2+'..tostring(rad*(1-K))..'", "w/2-'..tostring(rad*(1-K))..'", "-h/2", "w/2-'..tostring(rad)..'", "-h/2", "-w/2+'..tostring(rad)..'", "-h/2", "-w/2+'..tostring(rad*(1-K))..'", "-h/2", "-w/2", "-h/2+'..tostring(rad*(1-K))..'", "-w/2", "-h/2+'..tostring(rad)..'", "-w/2", "'..boxy..'-'..tostring(rad)..'", "-w/2", "'..boxy..'-'..tostring(rad*(1-K))..'", "-w/2+'..tostring(rad*(1-K))..'", "'..boxy..'", "-w/2+'..tostring(rad)..'", "'..boxy..'"'
     else
       data = data..', "w/2 -'..tostring(rad*(1-K))..'", "'..boxy..'", "w/2", "'..boxy..'+'..tostring(rad*(1-K))..'", "w/2", "'..boxy..'+'..tostring(rad)..'", "w/2", "h/2 -'..tostring(rad)..'", "w/2", "h/2-'..tostring(rad*(1-K))..'", "w/2-'..tostring(rad*(1-K))..'", "h/2", "w/2-'..tostring(rad)..'", "h/2", "-w/2+'..tostring(rad)..'", "h/2", "-w/2+'..tostring(rad*(1-K))..'", "h/2", "-w/2", "h/2-'..tostring(rad*(1-K))..'", "-w/2", "h/2-'..tostring(rad)..'", "-w/2", "'..boxy..'+'..tostring(rad)..'", "-w/2", "'..boxy..'+'..tostring(rad*(1-K))..'", "-w/2+'..tostring(rad*(1-K))..'", "'..boxy..'", "-w/2+'..tostring(rad)..'", "'..boxy..'"'
     end
   end
   draw = draw..'{"style":{"fillpaint":{"color":-637534209,"type":2}}, "path": "M 0 1 L 2 3 L 4 5 L 6 7 L 8 9 C 10 11 12 13 14 15 L 16 17 C 18 19 20 21 22 23 L 24 25 C 26 27 28 29 30 31 L 32 33 C 34 35 36 37 38 39 Z"}'
   data  = data .. ']'
   draw = draw..']'
   local containers = '["M 0 1 L 8 9 L 14 15 L 16 17 L 22 23 L 24 25 L 30 31 L 32 33 L 38 39 Z"]'
   local json = '{"data":' .. data .. ',"draw":' .. draw ..',"containers":'..containers..'}'
   return {template=json, minw=ps+2*rad, minh=ps+2*rad }
end
