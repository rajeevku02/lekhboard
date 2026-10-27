function generate(params, shapeText)
   local data = '['
   local draw = '['
   local n = params['number of pages']
   local cur = params['current page']
   local diam = tostring(params['radius']*2)
   if not cur or cur < 0 then cur = 1 end
   if cur >= n then cur = n end
   local dataEnd = 0
   for i = 0,n-1 do
     local style = '"style": {"strokewidth":0, "fillpaint":{"color":-3026479,"type":2}}'
     if cur - 1 == i then
       style = '"style": {"strokewidth":0, "fillpaint":{"color":-436207616,"type":2}}'
     end
     if data ~= '[' then data = data..', ' end
     if draw ~= '[' then draw = draw..', ' end
     data = data..'"-w/2+'..tostring(2*i)..'*'..diam..'+'..diam..'/2'..'", "0", "'..diam..'", "'..diam..'", "0"'
     draw = draw..'{"path": "E '
     for k = 0,4 do draw = draw..tostring(dataEnd+k)..' ' end
     draw = draw..'", '..style..'}'
     dataEnd = dataEnd + 5
   end
   data  = data .. ']'
   draw = draw..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw ..'}'
   return {template=json, minw=diam*2*n, minh=diam }
end
