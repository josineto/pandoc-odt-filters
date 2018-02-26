--
-- Workaround to use custom styles when converting to ODT. This filter turns
-- divs and spans with custom style into ODT raw blocks/inlines, with the ODT code
-- using the custom style. Also, headers with custom style (like the {-}, aka
-- "unnumbered" class) are turned into ODT raw heading blocks with the
-- custom style.
--
-- This filter will become useless when pandoc finally implement custom styles
-- in ODT writer (see https://github.com/jgm/pandoc/issues/2106 on this).
--
-- Currently, just italics, bold, links and line blocks are preserved in divs,
-- and italics, bold and links in spans; all other markup is ignored.
--
-- dependencies: util.lua, need to be in "filters/" relative to the directory
--               where pandoc is run
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018
-- license: GPL version 3 or later

local unnumberedStyle = 'Título_20_textual'

require 'filters/util'

function Div (div)
  if FORMAT == 'odt' and div.attr and div.attr.attributes then
    local customStyle = div.attr.attributes['custom-style']
    if customStyle then
      div = pandoc.walk_block(div, util.blockToRaw)
      local startTag = '<text:p text:style-name=\"' .. customStyle .. '\">'
      local endTag = '</text:p>'
      local content = startTag .. pandoc.utils.stringify(div) .. endTag
      return pandoc.RawBlock('opendocument',content)
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
    return pandoc.RawBlock('opendocument',content)
  end
end
