function generate(params, shapeText)
   local data = '["0", "-h/2", "0", "h/2"'
   local draw = '[ {"path": "M 0 1 L 2 3"}'
   local pos = params['position']
   local indicator = params['position indicator']
   if pos == nil then pos = 0 end
   if pos < 0 then pos = 0 end
   if pos > 1 then pos = 1 end

   local yp = '-h/2 + w/2 + '..tostring(pos)..'*(h-w)' 
   data = data..', "0", "'..yp..'"'
   draw = draw..', {"path": "M 4 5 L 2 3", "style": {"disabled": true}}'
   if indicator == 'circular' then
     data = data..', "0", "'..yp..'", "w", "w", "0"'
     draw = draw..', {"path": "E 6 7 8 9 10"}'
   elseif indicator == 'rectangular' then
     data = data..', "0", "'..yp..'", "w", "w/2", "3", "3", "0"'
     draw = draw..', {"path": "R 6 7 8 9 10 11 12"}'
   else
     data = data..', "-w/2", "'..yp..'-w/2", "0", "d(7)", "w/2", "d(7)+w/2", "0", "d(7)+w", "-w/2", "d(7)+w"'
     draw = draw..', {"path": "M 6 7 L 8 9 L 10 11 L 12 13 L 14 15 Z"}'
   end

   data  = data .. ']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw ..'}'
   return {template=json, minw=-1, minh=-1 }
end
