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

local emphStartTag = '<text:span text:style-name=\"Emphasis\">'
local strongStartTag = '<text:span text:style-name=\"Strong_20_Emphasis\">'
local spanEndTag = '</text:span>'

local emphFilter = function(emph)
  local content = emphStartTag .. pandoc.utils.stringify(emph) .. spanEndTag
  return pandoc.Str(content)
end

local strongFilter = function(strong)
  local content = strongStartTag .. pandoc.utils.stringify(strong) .. spanEndTag
  return pandoc.Str(content)
end

local rawInlineFilter = function(raw)
  return pandoc.Str(raw.text)
end

local lineBlockSeparator = '<text:line-break />'
local lineBlockFilter = function (lb)
  local newContent = {}
  for _,el in pairs(lb.content) do
    table.insert(newContent, el)
    table.insert(newContent, {pandoc.Str(lineBlockSeparator)})
  end
  lb.content = newContent
  return lb
end

util.inlineToRaw = {
  Emph = emphFilter,
  Strong = strongFilter,
  RawInline = rawInlineFilter
}

util.blockToRaw = {
  Emph = emphFilter,
  Strong = strongFilter,
  RawInline = rawInlineFilter,
  LineBlock = lineBlockFilter
}
