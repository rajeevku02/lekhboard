function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function getTextSize(text)
   return 2, 3
end

function escapeJson(text)
   return text
end

function splitLines(text)
   local function insertInto(tb, val)
      val,_ = val:gsub("\r", "")
      table.insert(tb, val)
   end
   local lines = { }
   local i = 0
   while text:len() > i do
      local j = text:find('\n',i)
      if j == nil then
         local str = text:sub(i)
         insertInto(lines, str)
         break
      else
         local str = text:sub(i, j-1)
         insertInto(lines, str)
      i = j + 1
      end
   end
   return lines
end

