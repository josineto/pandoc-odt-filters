--
-- Corrects the style of bibliography when converting to ODT. This is necessary
-- because Pandoc's ODT writer doesn't properly set this style.
--
-- Currently, all paragraphs in bibliography are turned into raw blocks with
-- correct style. Because of this, only italics, bold and link markups are keep;
-- all other markup is lost.
--
-- dependencies:
--   - util.lua, need to be in "filters/" relative to the directory
--     where pandoc is run
--   - odt-custom-styles.lua, need to be used, and used AFTER this filter
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018
-- license: GPL version 3 or later

local bibliographyStyle = 'Bibliography_20_1'

require 'filters/util'

function Div (div)
  if FORMAT == 'odt' and div.attr and div.attr.classes[1] then
    local class = div.attr.classes[1]
    if class == 'references' then
      div = pandoc.walk_block(div, {
        Para = function(para)
          local startTag = '<text:p text:style-name=\"' .. bibliographyStyle .. '\">'
          local endTag = '</text:p>'
          para = pandoc.walk_block(para, util.blockToRaw)
          local content = startTag .. pandoc.utils.stringify(para) .. endTag
          return pandoc.RawBlock('opendocument',content)
        end
      })
      return div
    end
  end
end
