function generate(params, shapeText)
  local tw, th, half
  tw, th = getTextSize('AA') 
  th = (th+6) * 0.7
  half = tostring(th/2)
  local data = '["-w/2+'..half..'", "0", "'..tostring(th)..'", "'..tostring(th)..'", "0","'..tostring(tw)..'", "0", "w", "h", "0"'
  local icon = 'avabodh.wireframe.icon_circle-o'
  if params.checked then
    icon = 'avabodh.wireframe.icon_dot-circle-o'
  end
  local embeds = '[{ "name": "'..icon..'", "location":"0 1 2 3 4", "inheritstyle": true, "mode": "aspect"}]'
  local texts = '[{"location": "5 6 7 8 9", "text":"'..escapeJson(shapeText)..'","style":{"textalignhorizontal":2}}]'
  data = data..']'
  local json = '{"data":' .. data .. ',"embeds":'..embeds..', "texts":'..texts..'}'
  local disabled = false
  if params.state == 'disabled' then
     disabled = true
  end
  return {template=json, minw=tw+8, minh=th+8,disabled=disabled }
end
