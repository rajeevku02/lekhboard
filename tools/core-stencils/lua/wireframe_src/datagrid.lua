function generate(params, shapeText)
   local lines = splitLines(shapeText)
   local maxw = 0
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local broder = params['border']
   local strokePaint = ''
   if not broder then strokePaint = ',"strokepaint":{"strokewidth":0}' end
   local rectDraw = '{"path": "M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{"fillpaint":{"color":-1,"type":2}'..strokePaint..'}}'
   local draw = '['..rectDraw
   local texts = '['
   local embeds = '['
   local dataEnd = 8
   local pad = 4.0
   local pad2 = 2.0
   local _,charHeight = getTextSize('AA')
   local icw = charHeight*0.9
   local sw = getStrokeWidth()
   local items = { }
   local cols = { }
   local rows = { }
   local nrows = 0
   local ncols = 0
   local selectedRow = nil
   local prevHLine = '-h/2'
   local szSpec = { } 
   local minHeight = params['min row height']
   if not minHeight then minHeight = 26 end
   for id = 1, #lines do
     local sp = parseSizeSpec(lines[id])
     if sp.parsed then
       szSpec = sp
       szSpec['parsed'] = nil
       break
     end
     nrows = nrows + 1
     items[id] = { }
     local cells = split(lines[id], { by=',', checkEscapeNewLine=true, checkHeight=true, checkWidth=true, heightPad=1.0, widthPad=2.0, checkDisabled=true, checkSelection=true, checkStartIcon=true, checkEndIcon=true})
     if #cells > ncols then
       ncols = #cells
     end
     for cid = 1, #cells do
       items[id][cid] = {startIcon=cells[cid].startIcon, endIcon=cells[cid].endIcon, selected=cells[cid].selected, disabled=cells[cid].disabled, word=cells[cid].word }
       if cells[cid].selected then
         selectedRow = id
       end
       local height = cells[cid].height
       if height < minHeight then height = minHeight end
       local width = cells[cid].width
       if cells[cid].startIcon then
         width = width + icw
         if cells[cid].word then
           width = width + pad2
         end
       end
       if cells[cid].endIcon then
         width = width + icw
         if cells[cid].word then
           width = width + pad2
         end
       end
       if not cols[cid] or cols[cid] < width then
         cols[cid] = width
       end
       if not rows[id] or rows[id] < height then
         rows[id] = height
       end
     end
     if not rows[id] then rows[id] = charHeight end
   end
   while #szSpec < ncols do
     szSpec[#szSpec + 1] = {size=0, align='left' }
   end
   -- delete extra item in szSpec
   while #szSpec > ncols do
     szSpec[#szSpec] = nil
   end
   -- check all cols are set to zero
   local allZero = true
   for id = 1, #szSpec do
     if szSpec[id].size ~= 0 then
       allZero = false
       break
     end
   end
   -- get relative and const col heights
   if allZero then
     for id = 1, #szSpec do
       szSpec[id].size = cols[id]
       szSpec[id].relative = true
     end
   else
     for id = 1, #szSpec do
       if szSpec[id].size == 0 then
         szSpec[id].size = cols[id]
         szSpec[id].relative = false
       else
         szSpec[id].relative = true
       end
     end
   end
   -- get rsum and csum
   local csum = 0 -- sum of consts cols
   local rsum = 0 -- sum of reltive cols
   local wa = 0
   local vprev = nil
   for id = 1, #szSpec do
     if szSpec[id].relative then
       rsum = rsum + szSpec[id].size
     else
       csum = csum + szSpec[id].size
     end
   end
   -- compute ratio
   for id = 1, #szSpec do
     if szSpec[id].relative then
       if rsum == 0 then
         goto done
       end
       szSpec[id].ratio = szSpec[id].size / rsum
     else
       szSpec[id].ratio = 1
     end
   end
   wa = 'w-'..tostring(ncols*sw + 2*ncols*pad + csum)

   function getStartIcon(rid, cid)
     local icon = items[rid][cid].startIcon
     if icon then
       if icon == '' then
         icon = 'avabodh.wireframe.icon_square-o'
       elseif icon == 'x' or icon == 'X' then
         icon = 'avabodh.wireframe.icon_check-square-o'
       elseif icon == '-' then
         icon = 'avabodh.wireframe.icon_minus-square-o'
       elseif icon == 'o' or icon == 'O' then
         icon =  'avabodh.wireframe.icon_dot-circle-o'
       elseif icon == '()' or icon == '( )' then 
         icon = 'avabodh.wireframe.icon_circle-o'
       end
     end
     return icon
   end

   function getEndIcon(rid, cid)
     local icon = items[rid][cid].endIcon
     if icon then
       if icon == 'v' or icon == 'V' then
         icon = 'avabodh.wireframe.icon_chevron-down'
       elseif icon == '^' then
         icon = 'avabodh.wireframe.icon_chevron-up'
       else
         icon = nil
       end
     end
     return icon
   end

   function generateItem(rid, cid, cx, cy, wd, ht)
     if rid > #items or cid > #items[rid] then
       return
     end
     local icon = getEndIcon(rid, cid)
     if icon then
       data = data..', "'..cx..'+('..wd..')/2-'..tostring(icw/2)..'", "'..cy..'", "'..tostring(icw)..'", "'..tostring(icw)..'", "0"'
       if embeds ~= '[' then
         embeds = embeds..', '
       end
       if items[rid][cid].disabled then
         embeds =  embeds..'{"style": {"disabled": true},'
       else
         embeds =  embeds..'{'
       end
       embeds =  embeds..' "name": "'..icon..'", "location":"'
       for i = 0,4 do
         embeds = embeds..tostring(dataEnd+i)..' '
       end
       embeds = embeds..'", "inheritstyle": true, "mode": "aspect"}'
       dataEnd = dataEnd + 5
       cx = cx..'-'..tostring((icw+pad2)/2)
       wd = wd..'-'..tostring(icw+pad2)
     end
     icon = getStartIcon(rid, cid)
     if icon then
       if szSpec[cid].align=='right' then
         data = data..', "'..cx..'+('..wd..')/2-'..tostring(icw/2)..'", "'..cy..'", "'..tostring(icw)..'", "'..tostring(icw)..'", "0"'
       elseif szSpec[cid].align=='left' then
         data = data..', "'..cx..'-('..wd..')/2+'..tostring(icw/2)..'", "'..cy..'", "'..tostring(icw)..'", "'..tostring(icw)..'", "0"'
       else
         data = data..', "'..cx..'", "'..cy..'", "'..tostring(icw)..'", "'..tostring(icw)..'", "0"'
       end
       if embeds ~= '[' then
         embeds = embeds..', '
       end
       if items[rid][cid].disabled then
         embeds =  embeds..'{"style": {"disabled": true},'
       else
         embeds =  embeds..'{'
       end
       embeds =  embeds..' "name": "'..icon..'", "location":"'
       for i = 0,4 do
         embeds = embeds..tostring(dataEnd+i)..' '
       end
       embeds = embeds..'", "inheritstyle": true, "mode": "aspect"}'
       dataEnd = dataEnd + 5
       return
     end
     if texts ~= '[' then
       texts = texts..', '
     end
     data = data..', "'..cx..'", "'..cy..'", "'..wd..'", "'..ht..'", "0"'
     local style = '{"style": {"strokewidth":0'
     if items[rid][cid].disabled then
       style = style..', "disabled":true'
     end
     if szSpec[cid].align=='left' then
       style = style..', "textalignhorizontal": 2'
     elseif szSpec[cid].align=='right' then
       style = style..', "textalignhorizontal": 3'
     end
     texts = texts..style..'}, "location": "'
     for i=0,4 do
       texts = texts..tostring(dataEnd+i)..' '
     end
     texts = texts..'", "text": "'..escapeJson(items[rid][cid].word)..'"}' 
     dataEnd = dataEnd + 5
   end

   function drawHLine(at, rid)
     if params['horizontal grid lines'] then
       data = data..',"-w/2", "'..at..'", "w/2", "'..at..'"'
       draw = draw..', {"path":"M'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       dataEnd = dataEnd + 4
     end
     if selectedRow and selectedRow == rid then
       data = data..', "-w/2", "'..prevHLine..'", "-w/2", "'..at..'", "w/2", "'..at..'", "w/2", "'..prevHLine..'" '
       selDraw = '{"style": {"strokewidth": 0, "fillpaint":{"color":-10504995,"type":2}},"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)
       for ct=1,3 do
         selDraw = selDraw..' L '..tostring(dataEnd + 2*ct)..' '..tostring(dataEnd + 2*ct+1)
       end
       selDraw = selDraw..' Z" }'
       draw = string.sub(draw, 1, #rectDraw + 1)..','..selDraw..string.sub(draw,#rectDraw + 2)
       dataEnd = dataEnd + 8
     end
     prevHLine = at
   end

   function drawVLine(at)
     if not params['vertical grid lines'] then return end
     data = data..', "'..at..'", "-h/2", "'..at..'", "h/2"'
     draw = draw..', {"path":"M'..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
     dataEnd = dataEnd + 4
   end
   
   for rid = 1, nrows do
     local ht = tostring(rows[rid])
     local cy = '-h/2 + '..tostring(sw/2+pad)
     if vprev then
       cy = '-h/2 + '..tostring(sw/2+pad+vprev)
     end
     if rid < nrows then
       drawHLine(cy..'+'..ht..'+'..tostring(pad+sw/2), rid)
     end
     cy = cy..'+'..ht..'/2'
     hprev = nil
     for cid = 1, ncols do
       local wd = ''
       local cx = '-w/2 + '..tostring((cid-0.5)*sw + (2*(cid-1)+1)*pad)
       if hprev then
         cx = cx..'+'..hprev
       end
       if szSpec[cid].relative then
         wd = tostring(szSpec[cid].ratio)..'*('..wa..')'
       else
         wd = tostring(szSpec[cid].size)
       end
       if rid == 1 and cid < ncols then
         drawVLine(cx..'+'..wd..'+'..tostring(pad+sw/2))
       end
       cx = cx..'+'..wd..'/2'
       if hprev then
         hprev = hprev..'+'..wd
       else
         hprev = wd
       end
       generateItem(rid, cid, cx, cy, wd, ht)
     end
     if vprev then
       vprev = vprev + sw + 2*pad + rows[rid]
     else
       vprev = sw + 2*pad + rows[rid]
     end
   end
   ::done::
   local colsSum = 0
   local rowsSum = 0

   for id=1, ncols do
     colsSum = colsSum + cols[id]
   end
   for id=1, nrows do
     rowsSum = rowsSum + rows[id]
   end
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   embeds = embeds..']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts ..',"embeds":'..embeds.. '}'
   return {template=json, minw=colsSum + ncols*sw + 2*ncols*pad, minh=rowsSum + nrows*sw + 2*nrows*pad }
end
