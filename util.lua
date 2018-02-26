--
-- Utilities for use by other filters.
--
-- dependencies: none
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018
-- license: GPL version 3 or later

util = {}

util.putTagsOnContent = function (textContent, startTag, endTag)
  table.insert(textContent, 1, pandoc.RawInline("opendocument", startTag))
  table.insert(textContent, pandoc.RawInline("opendocument", endTag))
  return textContent
end

util.getElementId = function (element, fallbackId)
  if element.attr then
    local id = element.attr.identifier or fallbackId
    return id
  else return fallbackId
  end
end

local imageCounter = 0

util.getImageId = function (image)
  imageCounter = imageCounter + 1
  return util.getElementId(image, 'img' .. imageCounter)
end

local tableCounter = 0

util.getTableId = function (table)
  tableCounter = tableCounter + 1
  return util.getElementId(table, 'tbl' .. tableCounter)
end

util.isTableDiv = function (div)
  local tableDiv = false
  pandoc.walk_block(div, {
    Table = function(el)
      tableDiv = true
      return el
    end
  })
  return tableDiv
end

local tags = {}
tags.emph = '<text:span text:style-name=\"Emphasis\">'
tags.strong = '<text:span text:style-name=\"Strong_20_Emphasis\">'
tags.spanEnd = '</text:span>'
tags.linkEnd = '</text:a>'
tags.lineBreak = '<text:line-break />'

local filters = {}
filters.emph = function(emph)
  local content = tags.emph .. pandoc.utils.stringify(emph) .. tags.spanEnd
  return pandoc.Str(content)
end

filters.strong = function(strong)
  local content = tags.strong .. pandoc.utils.stringify(strong) .. tags.spanEnd
  return pandoc.Str(content)
end

filters.link = function(link)
  local linkTag = '<text:a xlink:type=\"simple\" xlink:href=\"' .. link.target .. '\" office:name=\"\">'
  local content = linkTag .. pandoc.utils.stringify(link) .. tags.linkEnd
  return pandoc.Str(content)
end

filters.rawInline = function(raw)
  return pandoc.Str(raw.text)
end

filters.rawBlock = function(raw)
  return pandoc.Str(raw.text)
end

filters.lineBlock = function (lb)
  local newContent = {}
  for _,el in pairs(lb.content) do
    table.insert(newContent, el)
    table.insert(newContent, {pandoc.Str(tags.lineBreak)})
  end
  lb.content = newContent
  return lb
end

util.inlineToRaw = {
  Emph = filters.emph,
  Strong = filters.strong,
  Link = filters.link,
  RawInline = filters.rawInline
}

util.blockToRaw = {
  Emph = filters.emph,
  Strong = filters.strong,
  Link = filters.link,
  RawInline = filters.rawInline,
  RawBlock = filters.rawBlock,
  LineBlock = filters.lineBlock
}
