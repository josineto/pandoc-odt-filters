--
-- Corrects captions when converting to ODT, by adding sequence fields to the
-- number of caption. This allows the creation of lists of figures, tables, etc.
--
-- Currently, only figure and table captions are supported. Only images and
-- tables with caption are processed.
--
-- Example: in a image with caption "Figure 1: Image with caption", this filter
-- inserts a field at the number "1", using syntax below.
--
-- Syntax of sequence field:
--
-- For images:
-- <text:sequence text:ref-name="refIDOFIMAGE" text:name="Illustration" text:formula="ooow:Illustration+1" style:num-format="1">
-- 1 (or whatever number)
-- </text:sequence>
--
-- For tables:
-- <text:sequence text:ref-name="refIDOFTABLE" text:name="Table" text:formula="ooow:Table+1" style:num-format="1">
-- 1 (or whatever number)
-- </text:sequence>
--
-- dependencies: util.lua, need to be in the same directory of this filter
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018 (first version)
-- license: GPL version 3 or later

local path = require 'pandoc.path'
utilPath = path.directory(PANDOC_SCRIPT_FILE)
dofile(path.join{utilPath, 'util.lua'})

local function correctCaption(caption, id, sequenceName)
  local newCaption = {}
  local seqStart = '<text:sequence text:ref-name=\"ref' .. id .. '\" text:name=\"' .. sequenceName .. '\" text:formula=\"ooow:' .. sequenceName .. '+1\" style:num-format=\"1\">'
  local seqEnd = '</text:sequence>'

  for i, el in pairs(caption) do
    local notDone = true
    if notDone and el.c and type(el.c) == 'string' and string.find(el.c, "%d+:$") then
      table.insert(newCaption, pandoc.RawInline("opendocument", seqStart))
      table.insert(newCaption, pandoc.Str(string.match(el.c, "%d+")))
      table.insert(newCaption, pandoc.RawInline("opendocument", seqEnd))
      table.insert(newCaption, pandoc.Str(":"))
      notDone = false
    else
      table.insert(newCaption, el)
    end
  end
  return newCaption
end

-- These names are NOT for customization; instead, they are internally
-- used by LibreOffice to generate lists of figures/tables.
local sequenceNames = {}
sequenceNames.image = 'Figure'
sequenceNames.table = 'Table'

function Image (img)
  if FORMAT == 'odt' and img.caption then
    local id = util.getImageId(img)
    img.caption = correctCaption(img.caption, id, sequenceNames.image)
    return img
  end
end

function Div (div)
  if FORMAT == 'odt' and util.isTableDiv(div) then
    local id = util.getTableId(div)
    return pandoc.walk_block(div, {
      Table = function(el)
        if el.caption and el.caption.long and el.caption.long[1] then
          local content = el.caption.long[1].content
          el.caption.long[1].content = correctCaption(content, id, sequenceNames.table)
        end
        return el
      end
    })
  end
end
