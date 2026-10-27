function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local broder = params['border']
   local strokePaint = ''
   if not broder then strokePaint = ',"strokepaint":{"strokewidth":0}' end
   local draw = '[{"path": "M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"fillpaint":{"color":-1,"type":2}'..strokePaint..'}}'
   local texts = '['
   local embeds = '['
   local arr = split(shapeText, {by='\n', checkHeight=true, heightPad=8.0, checkDisabled=true, checkStartIcon=true, checkSelection=true})
   local iconGap = false
   for id = 1,#arr do
     if arr[id].startIcon then
       iconGap = true
       break
     end
   end
   local sum = 0
   local prevSum = 0
   local dataEnd = 8
   local embedCount = 0
   local leftPad = 4
   local maxw = 0
   local minHeight = params['min item height']
   if not minHeight then minHeight = 24 end
   for id = 1,#arr do
     if id ~= 1 then
       texts = texts..', '
     end
     if arr[id].height < minHeight then arr[id].height = minHeight end
     sum = sum + arr[id].height
     if arr[id].width > maxw then maxw = arr[id].width end
     local dc = 0
     local icw = arr[id].height*0.7
     local icon = arr[id].startIcon
     if arr[id].selected then
       data = data..',"-w/2", "-h/2+'..tostring(prevSum)..'","-w/2", "-h/2+'..tostring(prevSum+arr[id].height)..'","w/2", "-h/2+'..tostring(prevSum+arr[id].height)..'", "w/2", "-h/2+'..tostring(prevSum)..'"'
       draw = draw..', {"path":"M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '
       for c = 1,3 do
         draw = draw.."L "..tostring(dataEnd+2*c)..' '..tostring(dataEnd+2*c + 1)..' '
       end
       draw = draw..' Z", "style": {"strokepaint": {"color":0, "type":2 }, "fillpaint":{"color":-10504995,"type":2}}}'
       dataEnd = dataEnd + 8
     end
     if icon then
       if embedCount ~= 0 then
         embeds = embeds..', ' 
       end
       data = data..',"'..tostring(icw+leftPad)..'", '..'"-h/2+'..tostring(prevSum+arr[id].height/2)..'", "w-'..tostring(icw+leftPad)..'", "'..tostring(arr[id].height)..'", "0"'
       data = data..', "-w/2+'..tostring(leftPad+icw/2)..'","-h/2+'..tostring(prevSum+arr[id].height/2)..'", "'..tostring(icw)..'", "'..tostring(icw)..'", "0"'
       dc = 10
       if arr[id].disabled then
         embeds =  embeds..'{"style": {"disabled": true},'
       else
         embeds =  embeds..'{'
       end
       embeds =  embeds..' "name": "'..icon..'", "location":"'
       for i = 5,9 do
         embeds = embeds..tostring(dataEnd+i)..' '
       end
       embeds = embeds..'", "inheritstyle": true, "mode": "aspect"}'
       embedCount = embedCount + 1
     else
       if iconGap then
         data = data..',"'..tostring(icw+leftPad)..'", '..'"-h/2+'..tostring(prevSum+arr[id].height/2)..'", "w-'..tostring(icw+leftPad)..'", "'..tostring(arr[id].height)..'", "0"'
       else
         data = data..', "'..tostring(leftPad)..'", "'..'-h/2+'..tostring(prevSum+arr[id].height/2)..'", "w-'..tostring(leftPad)..'", "'..tostring(arr[id].height)..'", "0"'
       end
       dc = 5
     end
     local textStyle = '{"style":{"textalignhorizontal":2}'
     if arr[id].disabled then
       textStyle = '{"style":{"textalignhorizontal":2, "disabled": true}'
     end
     texts = texts..textStyle..', "location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'","text":"'..escapeJson(arr[id].word)..'"}'
     dataEnd = dataEnd + dc
     prevSum = sum
   end
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   embeds = embeds..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts ..',"embeds":'..embeds.. '}'
   return {template=json, minw=maxw+2*leftPad, minh=sum+2*leftPad }
end
