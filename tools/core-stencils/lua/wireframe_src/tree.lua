function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local broder = params['border']
   local strokePaint = ''
   if not broder then strokePaint = ',"strokepaint":{"strokewidth":0}' end
   local draw = '[{"path": "M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"fillpaint":{"color":-1,"type":2}'..strokePaint..'}}'
   local texts = '['
   local embeds = '['
   local arr = split(shapeText, {by='\n', checkHeight=true, heightPad=8.0, checkDisabled=true, checkStartIcon=true, checkSelection=true, checkIndent=true})
   local gap,icw = getTextSize('A')
   gap = gap * 0.5
   icw = icw * 0.9
   local sum = 0
   local maxw = 0
   local dataEnd = 8
   local embedCount = 0
   local leftPad = 12
   local upPad = 6
   local prevSum = upPad
   for id = 1,#arr do
     if id ~= 1 then
       texts = texts..', '
     end
     sum = sum + arr[id].height
     local dc = 0
     local icon = arr[id].startIcon
     local indent = arr[id].indent
     local indentGap = indent * (icw + leftPad)
     local linew = leftPad + indentGap + icw + gap + arr[id].width + leftPad
     if linew > maxw then maxw = linew end
     if arr[id].selected then
       data = data..',"-w/2", "-h/2+'..tostring(prevSum)..'","-w/2", "-h/2+'..tostring(prevSum+arr[id].height)..'","w/2", "-h/2+'..tostring(prevSum+arr[id].height)..'", "w/2", "-h/2+'..tostring(prevSum)..'"'
       draw = draw..', {"path":"M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '
       for c = 1,3 do
         draw = draw.."L "..tostring(dataEnd+2*c)..' '..tostring(dataEnd+2*c + 1)..' '
       end
       draw = draw..' Z", "style": {"strokepaint": {"color":0, "type":2 }, "fillpaint":{"color":-10504995,"type":2}}}'
       dataEnd = dataEnd + 8
     end
     data = data..',"'..tostring(indentGap+leftPad+icw+gap)..'", '..'"-h/2+'..tostring(prevSum+arr[id].height/2)..'", "w", "'..tostring(arr[id].height)..'", "0"'
     dc = 5
     if icon then
       if icon == '+' then
         icon = 'avabodh.wireframe.icon_plus-square-o'
       elseif icon == '-' then
         icon = 'avabodh.wireframe.icon_minus-square-o'
       elseif icon == '>' then
         icon = 'avabodh.wireframe.icon_caret-right'
       elseif icon == 'v' or icon == 'V' then
         icon = 'avabodh.wireframe.icon_caret-down'
       elseif icon == 'folder' then
         icon = 'avabodh.wireframe.icon_folder'
       elseif icon == 'folder-open' then
         icon = 'avabodh.wireframe.icon_folder-open'
       elseif icon == 'file' then
         icon = 'avabodh.wireframe.icon_file'
       end
       if embedCount ~= 0 then
         embeds = embeds..', ' 
       end
       data = data..', "-w/2+'..tostring(leftPad + indentGap + icw/2)..'","-h/2+'..tostring(prevSum+arr[id].height/2)..'", "'..tostring(icw)..'", "'..tostring(icw)..'", "0"'
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
     prevSum = sum + upPad
   end
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   embeds = embeds..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts ..',"embeds":'..embeds.. '}'
   return {template=json, minw=maxw, minh=sum+2*upPad }
end
