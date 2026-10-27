function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local draw = '[{"path": "M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"fillpaint":{"color":-1,"type":2} }}'
   local texts = '['
   local embeds = '['
   local arr = split(shapeText, {by='\n', checkHeight=true, heightPad=8.0, checkDisabled=true, checkStartIcon=true, checkSelection=true, checkEndText=true})
   local _,lineHeight = getTextSize('AA')
   local icw = lineHeight*0.7
   local sum = 0
   local prevSum = 0
   local dataEnd = 8
   local embedCount = 0
   local leftPad = 5
   local maxw = 0
   for id = 1,#arr do
     if arr[id].word == '-' or arr[id].word=='--' or arr[id].word=='---' or arr[id].word=='----' or arr[id].word=='=' then
       data = data..',"-w/2","-h/2+'..tostring(sum)..'","w/2", "-h/2+'..tostring(sum)..'"'
       draw = draw..',{"style": {"disabled":true}, "path":"M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       dataEnd = dataEnd + 4
       goto continue
     end
     if texts ~= '[' then
       texts = texts..', '
     end
     sum = sum + arr[id].height
     local width,ht = getTextSize(arr[id].word)
     if arr[id].endText then
       local wd,ht = getTextSize(arr[id].endText)
       width = width + wd
     end
     if width > maxw then maxw = width end
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
     if arr[id].endText then
       local textStyle = ',{"style":{"textalignhorizontal":3}'
       if arr[id].disabled then
         textStyle = ',{"style":{"textalignhorizontal":3, "disabled": true}'
       end
       local tw,th = getTextSize(arr[id].endText)
       data = data..',"w/2-'..tostring(tw/2)..'-'..tostring(leftPad+2)..'", '..'"-h/2+'..tostring(prevSum+arr[id].height/2)..'", "'..tostring(tw+2)..'", "'..tostring(th+2)..'", "0"'
       texts = texts..textStyle..', "location":"'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'","text":"'..escapeJson(arr[id].endText)..'"}'
       dataEnd = dataEnd + 5
     end
     prevSum = sum
     ::continue::
   end
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   embeds = embeds..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts ..',"embeds":'..embeds.. '}'
   return {template=json, minw=maxw+icw+2*leftPad+8, minh=sum+8 }
end
