--
-- Turns smallcaps into span with custom character style, when converting
-- to ODT. This is necessary because LibreOffice default smallcaps is not true
-- smallcaps, but rather reduced capitalised letters.
--
-- Currently, it's necessary to create the style "Versalete" on a reference-doc
-- to this filter properly work. To turn on true smallcaps, add ":smcp" to the
-- name of the font. For instance, "Myriad Pro:smcp". It's ugly, but currently
-- it's the only option to true smallcaps in LibreOffice (Word doesn't even
-- have an option like this, it's always fake smallcaps).
--
-- Syntax:
-- <text:span text:style-name="Versalete">
-- TEXT TO BE TRUE SMALLCAPS
-- </text:span>
--
-- dependencies: util.lua, need to be in "filters/" relative to the directory
--               where pandoc is run
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018
-- license: GPL version 3 or later

local smallcapsStyle = 'Versalete'

require 'filters/util'

function SmallCaps (sc)
  if FORMAT == 'odt' then
    local startTag = '<text:span text:style-name=\"' .. smallcapsStyle .. '\">'
    local endTag = '</text:span>'
    sc.content = util.putTagsOnContent(sc.content, startTag, endTag)
  end
  return pandoc.Span(sc.content)
end
