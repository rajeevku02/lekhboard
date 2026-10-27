function generate(params, shapeText)
   local arr = split(shapeText, {by='\n', checkHeight=true, heightPad=6.0, checkDisabled=true, checkStartIcon=true})
   local data = '['
   local texts = '['
   local embeds = '['
   local sum = 0
   local maxw = 0
   local prevSum = 0
   local dataEnd = 0
   local embedCount = 0
   local gap, icw = getTextSize('AA') 
   icw = (icw + 6) * 0.7 
   for id = 1,#arr do
     if id ~= 1 then
       texts = texts..', '
       data = data..", "
     end
     if arr[id].width > maxw then maxw = arr[id].width end
     sum = sum + arr[id].height
     local dc = 0
     local icon = arr[id].startIcon
     if not icon then
       data = data..'"0", "'..'-h/2+'..tostring(prevSum+arr[id].height/2)..'", "w", "'..tostring(arr[id].height)..'", "0"'
       dc = 5
     else
       if icon == '' or icon == '()' or icon == '( )' then
         icon = 'avabodh.wireframe.icon_circle-o'
       elseif icon == 'o' or icon == 'O' then
         icon = 'avabodh.wireframe.icon_dot-circle-o'
       elseif icon == '-' then
         icon = 'avabodh.wireframe.icon_minus-circle'
       end
       if embedCount ~= 0 then
         embeds = embeds..', ' 
       end
       data = data..'"'..tostring(gap)..'", '..'"-h/2+'..tostring(prevSum+arr[id].height/2)..'", "w", "'..tostring(arr[id].height)..'", "0"'
       data = data..', "-w/2+'..tostring(icw/2)..'","-h/2+'..tostring(prevSum+arr[id].height/2)..'", "'..tostring(icw)..'", "'..tostring(icw)..'", "0"'
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
     end
     local textStyle = '{"style":{"textalignhorizontal":2}'
     if arr[id].disabled then
       textStyle = '{"style":{"textalignhorizontal":2, "disabled": true}'
     end
     texts = texts..textStyle..', "location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'","text":"'..escapeJson(arr[id].word)..'"}'
     dataEnd = dataEnd + dc
     prevSum = sum
   end
   texts = texts..']'
   data = data..']'
   embeds = embeds..']'
   local json = '{"data":' .. data .. ', "texts":'..texts..',"embeds":'..embeds..'}'
   return {template=json, minw=maxw+8, minh=sum+8 }
end
