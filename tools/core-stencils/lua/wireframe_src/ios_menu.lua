function generate(params, shapeText)
   local lines = splitLines(shapeText)
   local maxw = 0
   local rad = params['corner radius']
   local border = params['border']
   if border==nil then border = true end
   if not rad then rad = 0.1 end
   local strokePaint = ''
   if not border then strokePaint = ',"strokepaint":{"strokewidth": 0}' end
   local data = '["0", "0", "w", "h", "'..tostring(rad)..'", "d(4)", "0"'
   local draw = '[{"path": "R 0 1 2 3 4 5 6", "style":{"fillpaint":{"color":-1,"type":2}'..strokePaint..'}}'
   local texts = '['
   local embeds = '['
   local arr = split(shapeText, {by='\n', checkHeight=true, heightPad=8.0, checkDisabled=true, checkStartIcon=true, checkEndIcon=true, checkSelection=true, checkEndText=true, checkEscapeNewLine=true})
   local _,lineHeight = getTextSize('AA')
   local icw = lineHeight*0.9
   local sum = 0
   local prevSum = 0
   local dataEnd = 7
   local embedCount = 0
   local leftPad = 5
   local minHeight = params['min row height']
   if not minHeight then minHeight = 24 end
   for id = 1,#arr do
     if id > 1 then
       data = data..',"-w/2","-h/2+'..tostring(sum)..'","w/2", "-h/2+'..tostring(sum)..'"'
       draw = draw..',{"style": {"disabled":true}, "path":"M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       dataEnd = dataEnd + 4
     end
     if texts ~= '[' then
       texts = texts..', '
     end
     if arr[id].height < minHeight then arr[id].height = minHeight end
     sum = sum + arr[id].height
     local dc = 0
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
       local actualIcw = icw
       if icon == 'o' or icon == 'O' then
         icon = 'avabodh.wireframe.icon_circle'
         actualIcw = lineHeight*0.4
       elseif icon == 'x' or icon == 'X' then
         icon = 'avabodh.wireframe.icon_check'
       elseif icon == '+' then
         icon = 'avabodh.wireframe.icon_plus-circle'
       elseif icon == '-' then
         icon = 'avabodh.wireframe.icon_minus-circle'
       end

       if embedCount ~= 0 then
         embeds = embeds..', ' 
       end
       data = data..',"'..tostring(icw+leftPad)..'", '..'"-h/2+'..tostring(prevSum+arr[id].height/2)..'", "w-'..tostring(leftPad+1)..'", "'..tostring(arr[id].height)..'", "0"'
       data = data..', "-w/2+'..tostring(leftPad+icw/2)..'","-h/2+'..tostring(prevSum+arr[id].height/2)..'", "'..tostring(actualIcw)..'", "'..tostring(actualIcw)..'", "0"'
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
       data = data..',"'..tostring(icw+leftPad)..'", '..'"-h/2+'..tostring(prevSum+arr[id].height/2)..'", "w-'..tostring(leftPad+1)..'", "'..tostring(arr[id].height)..'", "0"'
       dc = 5
     end
     local textStyle = '{"style":{"textalignhorizontal":2}'
     if arr[id].disabled then
       textStyle = '{"style":{"textalignhorizontal":2, "disabled": true}'
     end
     texts = texts..textStyle..', "location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'","text":"'..escapeJson(arr[id].word)..'"}'
     dataEnd = dataEnd + dc
     local linew = arr[id].width
     if arr[id].endIcon then
       local icon = arr[id].endIcon
       local icw = lineHeight*0.7
       local ich = icw
       if icon == '>' then
         icon = 'avabodh.wireframe.icon_chevron-right'
       elseif string.lower(icon) == 'off' then
         icw = lineHeight*1.5
         ich = icw*2
         icon = 'avabodh.wireframe.icon_toggle-off'
       elseif string.lower(icon) == 'on' then
         icw = lineHeight*1.5
         ich = icw*2
         icon = 'avabodh.wireframe.icon_toggle-on'
       elseif icon == '=' then
         icon = 'avabodh.wireframe.icon_bars'
       end
       if embedCount ~= 0 then
         embeds = embeds..', ' 
       end
       linew = icw
       data = data..',"w/2-'..tostring(icw/2+leftPad)..'", '..'"-h/2+'..tostring(prevSum+arr[id].height/2)..'", "'..tostring(icw)..'", "'..tostring(ich)..'", "0"'
       if arr[id].disabled then
         embeds =  embeds..'{"style": {"disabled": true},'
       else
         embeds =  embeds..'{'
       end
       embeds =  embeds..' "name": "'..icon..'", "location":"'
       for i = 0,4 do
         embeds = embeds..tostring(dataEnd+i)..' '
       end
       embeds = embeds..'", "inheritstyle": true, "mode": "aspect"}'
       embedCount = embedCount + 1
       dataEnd = dataEnd + 5
     elseif arr[id].endText then
       local textStyle = ',{"style":{"textalignhorizontal":3}'
       if arr[id].disabled then
         textStyle = ',{"style":{"textalignhorizontal":3, "disabled": true}'
       end
       local tw,th = getTextSize(arr[id].endText)
       linew = linew + tw
       data = data..',"w/2-'..tostring(tw/2)..'-'..tostring(leftPad+2)..'", '..'"-h/2+'..tostring(prevSum+arr[id].height/2)..'", "'..tostring(tw+2)..'", "'..tostring(th+2)..'", "0"'
       texts = texts..textStyle..', "location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'","text":"'..escapeJson(arr[id].endText)..'"}'
       dataEnd = dataEnd + 5
     end
     prevSum = sum
     if maxw < linew then maxw = linew end
   end
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   embeds = embeds..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts ..',"embeds":'..embeds.. '}'
   return {template=json, minw=leftPad+icw+maxw+leftPad, minh=sum+8 }
end
