function generate(params, shapeText)
   local data = '["-w/2", "-h/2", "-w/2", "h/2", "w/2", "h/2", "w/2", "-h/2"'
   local border = params['border']
   local sw = '"strokewidth":0,'
   if border then sw = '' end
   local rectDraw = '{"path": "M 0 1 L 2 3 L 4 5 L 6 7 Z", "style":{'..sw..'"fillpaint":{"color":-1,"type":2} }}'
   local draw = '['..rectDraw
   local texts = '['
   local dataEnd = 8
   local charWidth,charHeight = getTextSize('AA')
   local items = { }
   local cols = { }
   local rows = { }
   local nrows = 0
   local ncols = 0
   local lines = { }
   local lns = splitLines(shapeText)
   while #lns > 7 do
     lns[#lns] = nil
   end
   local idx = 4
   local idx2 = #lns // 2 + 1
   for i = 0,3 do
     if lns[idx2 - i] then
       lines[idx - i] = lns[idx2 - i] 
     else
       lines[idx - i] = ' '
     end
   end
   idx  = idx + 1
   idx2 = idx2 + 1
   for i = 0,2 do
     if lns[idx2 + i] then
       lines[idx + i] = lns[idx2 + i] 
     else
       lines[idx + i] = ' '
     end
   end
   for id = 1, #lines do
     nrows = nrows + 1
     items[id] = { }
     local cells = split(lines[id], { by=',', checkHeight=true, checkWidth=true, heightPad=8.0, widthPad=12.0})
     if #cells > ncols then
       ncols = #cells
     end
     for cid = 1, #cells do
       items[id][cid] = cells[cid].word
       if cells[cid].selected then
         selectedRow = id
       end
       local height = cells[cid].height
       local width = cells[cid].width
       if not cols[cid] or cols[cid] < width then
         cols[cid] = width
       end
       if not rows[id] or rows[id] < height then
         rows[id] = height
       end
     end
     if not rows[id] then rows[id] = charHeight end
   end

   function generateItem(rid, cid, cx, cy, wd, ht)
     if rid > #items or cid > #items[rid] then
       return
     end
     if texts ~= '[' then
       texts = texts..', '
     end
     data = data..', "'..cx..'", "'..cy..'", "'..wd..'", "'..ht..'", "0"'
     local style = '{"style": {"strokewidth":0'
     if rid ~= 4 then
       style = style..', "disabled":true'
     end
     texts = texts..style..'}, "location": "'
     for i=0,4 do
       texts = texts..tostring(dataEnd+i)..' '
     end
     texts = texts..'", "text": "'..escapeJson(items[rid][cid])..'"}' 
     dataEnd = dataEnd + 5
   end
  
   local colsSum = 0
   local rowsSum = 0
   for id=1, ncols do
     colsSum = colsSum + cols[id]
   end
   for id=1, nrows do
     rowsSum = rowsSum + rows[id]
   end
   local vsum = 0
   local topx = tostring(-colsSum/2)
   local topy = tostring(-rowsSum/2)
   for rid = 1, nrows do
     local ht = tostring(rows[rid])
     local cy = topy..'+'..tostring(vsum + rows[rid]/2)
     local hsum = 0
     for cid = 1, ncols do
       local wd = tostring(cols[cid])
       local cx = topx..'+'..tostring(hsum + cols[cid]/2)
       generateItem(rid, cid, cx, cy, wd, ht)
       hsum = hsum + cols[cid]
     end
     if rid == 4 then
       data = data..', "-w/2", "'..topy..'+'..tostring(vsum)..'", "w/2", "'..topy..'+'..tostring(vsum)..'"'
       data = data..', "-w/2", "'..topy..'+'..tostring(vsum+rows[rid])..'", "w/2", "'..topy..'+'..tostring(vsum+rows[rid])..'"'
       draw = draw..', {"path": "M '..tostring(dataEnd)..' '..tostring(dataEnd+1)..' L '..tostring(dataEnd+2)..' '..tostring(dataEnd+3)..'"}'
       draw = draw..', {"path": "M '..tostring(dataEnd+4)..' '..tostring(dataEnd+5)..' L '..tostring(dataEnd+6)..' '..tostring(dataEnd+7)..'"}'
       dataEnd = dataEnd + 8
     end
     vsum = vsum + rows[rid]
   end
   data  = data .. ']'
   draw = draw..']'
   texts  = texts .. ']'
   local json = '{"data":' .. data .. ',"draw":' .. draw .. ', "texts":' ..texts..'}'
   return {template=json, minw=colsSum, minh=rowsSum}
end
