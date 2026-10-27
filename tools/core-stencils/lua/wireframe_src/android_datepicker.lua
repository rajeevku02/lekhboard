function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "w/2", "-h/2", "w/2", "h/2", "-w/2", "h/2"'
   local draw = '[ {"path": "M 0 1 L 2 3 L 4 5 L 6 7 Z", "style": {"fillpaint":{"color": -1, "type": 2}}}'
   local texts = '['
   local embeds = '['

   local y = 2022
   local m = 3
   local d = 4
   local arr = split(shapeText, {by='/'})
   if #arr >= 3 then
     y = tonumber(arr[1].word)
     ys = tostring(y)
     m = tonumber(arr[2].word)
     if m < 1 or m > 12 then m = 1 end
     ms = tostring(m)
     d = tonumber(arr[3].word)
     ds = tostring(d)
   end
   local day,days = getMonthInfo(m,y)
   if day < 1 or day > 7 then day = 1 end
   if d < 1 or d > days then d = 2; ds = '2' end

   local smonth = ({'Jan', 'Feb', 'March', 'April', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec' })[m]
   local sday = ({'Sun', 'Mon', 'Tue', 'Web', 'Thu', 'Fri', 'Sat' })[day]

   local gap = 14
   local yh = gap
   local cw,ch = getTextSize('55')
   cw = cw + 2
   local tw, th = getTextSize(tostring(y))
   tw = tw + 2
   data = data..', "-w/2+'..tostring(gap+tw/2)..'", "-h/2+'..tostring(yh+th/2)..'", "'..tostring(tw)..'", "'..tostring(th)..'", "0"'
   texts = texts..'{"text": "'..escapeJson(y)..'", "location": "8 9 10 11 12", "style": {"textalignhorizontal": 2}}'
   yh = yh + th

   local head = sday..', '..smonth..' '..ys 
   tw, th = getTextSize(tostring(head))
   tw = tw + 2
   tw = tw * 2
   th = th * 2
   data = data..', "-w/2+'..tostring(gap+tw/2)..'", "-h/2+'..tostring(yh+th/2)..'", "'..tostring(tw)..'", "'..tostring(th)..'", "0"'
   texts = texts..',{"text": "'..escapeJson(head)..'", "location": "13 14 15 16 17", "style":{"fontmultiplier": 2, "textalignhorizontal": 2}}'
   yh = yh + th

   data = data..', "-w/2", "-h/2+'..tostring(yh+gap+gap)..'", "w/2", "d(19)"'
   draw = draw..', {"path": "M 18 19 L 20 21"}'
   yh = yh + 2*gap

   head = ({"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"})[m]
   head = head..' '..ys
   yh = yh + gap

   data = data..', "0", "-h/2 + '..tostring(yh + ch/2)..'", "w", "'..tostring(ch)..'", "0"'
   texts = texts..', {"text": "'..escapeJson(head)..'", "location": "22 23 24 25 26"}'

   local cellw = '(w-'..tostring(2*gap + cw)..')/6'
   local xc = '-w/2+'..tostring(gap)..'+ '..tostring(cw/2)
   data = data..', "'..xc..'", "-h/2+'..tostring(yh+ch/2)..'", "'..tostring(ch)..'", "'..tostring(ch)..'", "0"'
   embeds = embeds..'{"name": "avabodh.wireframe.icon_chevron-left", "location": "27 28 29 30 31", "mode": "aspect"}'

   local xc = 'w/2-'..tostring(gap)..'-'..tostring(cw/2)
   data = data..', "'..xc..'", "-h/2+'..tostring(yh+ch/2)..'", "'..tostring(ch)..'", "'..tostring(ch)..'", "0"'
   embeds = embeds..',{"name": "avabodh.wireframe.icon_chevron-right", "location": "32 33 34 35 36", "mode": "aspect"}'
   yh = yh + ch + gap

   local numLines = 1 + (days + day - 1 + 6)
   numLines = numLines // 7
   local lh = '(h-'..tostring(yh + gap + ch)..')/'..tostring(numLines)
   local dataEnd =  37

   for i = 0, numLines-1 do
     local yc = '-h/2+'..tostring(yh)..'+ (2 * '..tostring(i)..'+1)*0.5*'..lh
     local larr = { }
     if i == 0 then
       larr = {'S', 'M', 'T', 'W', 'T', 'F', 'S'}
     elseif i == 1 then
       local s = 1
       while s < day do larr[s] = ' '; s = s + 1 end
       while s < 8 do larr[s] = tostring(s-day+1); s = s + 1 end
     else
       local s = (i-1)*7 + 1 - day
       for k = 1,7 do if s+k <= days then larr[k] = tostring(s + k) else larr[k] = '' end end
     end
     for j=0,#larr-1 do
       local xc = '-w/2+'..tostring(gap+cw/2)..'+'..tostring(j)..'*'..cellw
       if j == 0 then xc = '-w/2+'..tostring(gap+cw/2) end
       if j == 6 then xc = 'w/2-'..tostring(gap+cw/2) end
       local tw,th = getTextSize(larr[j+1]); tw = tw + 2
       data = data..', "'..xc..'", "'..yc..'", "'..tostring(tw)..'", "'..tostring(th)..'", "0"'
       if texts ~= '[' then texts = texts..', 'end
       texts = texts..'{"text": "'..escapeJson(larr[j+1])..'", "location": "'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..' '..tostring(dataEnd+4)..'"}'
       dataEnd = dataEnd + 5
       if d == tonumber(larr[j+1]) then
         data = data..', "'..xc..'", "'..yc..'", "'..tostring(cw+8)..'", "'..tostring(cw+8)..'", "0"'
         draw = draw..',{"path": "E '
         for c = 0,4 do draw = draw..tostring(dataEnd+c)..' ' end
         draw = draw..'", "style": {"strokewidth": 0, "fillpaint":{"color":-10504995, "type":2}}}'
         dataEnd = dataEnd + 5
       end
     end
   end

   local tw,th = getTextSize("OK"); tw = tw + 2
   data = data..', "w/2-'..tostring(gap+tw/2)..'", "h/2-'..tostring(gap+th/2)..'", "'..tostring(tw)..'", "'..tostring(th)..'", "0"'
   texts = texts..',{"location": "'
   for c = 0,4 do texts = texts..tostring(dataEnd+c)..' ' end
   texts = texts..'", "text": "OK", "style":{"textfill":{"color":-16776961,"type":2}}}'
   dataEnd = dataEnd + 5

   local twc,thc = getTextSize("CANCEL"); twc = twc + 2
   data = data..', "w/2-'..tostring(gap+tw + gap + twc/2)..'", "h/2-'..tostring(gap+th/2)..'", "'..tostring(twc)..'", "'..tostring(thc)..'", "0"'
   texts = texts..',{"location": "'
   for c = 0,4 do texts = texts..tostring(dataEnd+c)..' ' end
   texts = texts..'", "text": "CANCEL", "style":{"textfill":{"color":-16776961,"type":2}}}'

   data  = data .. ']'
   draw = draw..']'
   texts = texts..']'
   embeds = embeds..']'

   local json = '{"data":' .. data .. ',"draw":' .. draw ..',"texts":'..texts..', "embeds":'..embeds..'}'
   return {template=json, minw=-1, minh=-1 }
end
