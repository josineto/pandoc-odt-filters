--
-- Workaround to use custom styles when converting to ODT. This filter turns
-- divs and spans with custom style into ODT raw blocks/inlines, with the ODT code
-- using the custom style. Also, headers with custom style (like the {-}, aka
-- "unnumbered" class) are turned into ODT raw heading blocks with the
-- custom style. If variable useClassAsCustomStyle is true, and element
-- (div/span/header) doesn't have a custom-style attribute, then first class is
-- used as style.
--
-- This filter will become useless when pandoc finally implement custom styles
-- in ODT writer (see https://github.com/jgm/pandoc/issues/2106 on this).
--
-- Currently, the following elements are **ignored** by this filter:
-- blockquotes, lists (see odt-lists.lua), tables and code blocks (for div
-- styles), and citations, smallcaps (see odt-smallcaps.lua), images, quotes,
-- strikeouts, super and subscript, math and code inlines (for span styles).
--
-- dependencies: util.lua, need to be in the same directory of this filter
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018
-- license: GPL version 3 or later

local useClassAsCustomStyle = true
local unnumberedStyle = 'Título_20_textual'

local utilPath = string.match(PANDOC_SCRIPT_FILE, '.*[/\\]')
require ((utilPath or '') .. 'util')

function getParaTags(style)
  local startTag = '<text:p text:style-name=\"' .. style .. '\">'
  local endTag = '</text:p>'
  return startTag, endTag
end

function getParaStyled(para, style)
  local startTag, endTag = getParaTags(style)
  local content = startTag .. pandoc.utils.stringify(para) .. endTag
  content = string.gsub(content, "\t", "<text:tab/>")
  return pandoc.RawBlock('opendocument', content)
end

function getLineBlockStyled(lineBlock, style)
  local startTag, endTag = getParaTags(style)
  local contentWithBreaks = {}
  for _,el in pairs(lineBlock.content) do
    table.insert(contentWithBreaks, el)
    table.insert(contentWithBreaks, {pandoc.Str(util.tags.lineBreak)})
  end
  lineBlock.content = contentWithBreaks
  local rawContent = startTag .. pandoc.utils.stringify(lineBlock) .. endTag
  return pandoc.RawBlock('opendocument', rawContent)
end

function getFilter(style)
  local paraFilter = function(para)
    return getParaStyled(para, style)
  end
  local lineBlockFilter = function(lb)
    return getLineBlockStyled(lb, style)
  end
  util.blockToRaw.LineBlock = lineBlockFilter
  util.blockToRaw.Para = paraFilter
  util.blockToRaw.HorizontalRule = paraFilter
  util.blockToRaw.Plain = paraFilter
  return util.blockToRaw
end

function Div (div)
  if FORMAT == 'odt' and div.attr and
      (div.attr.attributes['custom-style'] or div.attr.classes[1]) then
    local customStyle = div.attr.attributes['custom-style']
    if not customStyle and useClassAsCustomStyle and div.attr.classes then
      customStyle = div.attr.classes[1]
    end
    if customStyle then
      div = pandoc.walk_block(div, getFilter(customStyle))
      return div
    end
  end
end

function Span (sp)
  if FORMAT == 'odt' and sp.attr and sp.attr.attributes then
    local customStyle = sp.attr.attributes['custom-style']
    if customStyle then
      sp = pandoc.walk_inline(sp, util.inlineToRaw)
      local startTag = '<text:span text:style-name=\"' .. customStyle .. '\">'
      local endTag = '</text:span>'
      local content = startTag .. pandoc.utils.stringify(sp) .. endTag
      content = string.gsub(content, "\t", "<text:tab/>")
      return pandoc.RawInline('opendocument', content)
    end
  end
end

function Header (hx)
  if FORMAT == 'odt' and hx.attr and hx.attr.classes[1] then
    local class = hx.attr.classes[1]
    if class == 'unnumbered' then
      class = unnumberedStyle
    end
    hx = pandoc.walk_block(hx, util.blockToRaw)
    local startTag = '<text:h text:style-name=\"' .. class .. '\" text:outline-level=\"' .. hx.level .. '\">'
    local endTag = '</text:h>'
    local content = startTag .. pandoc.utils.stringify(hx) .. endTag
    content = string.gsub(content, "\t", "<text:tab/>")
    return pandoc.RawBlock('opendocument',content)
  end
end
