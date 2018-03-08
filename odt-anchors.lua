--
-- Corrects anchors when converting to ODT, by adding bookmarks where anchors
-- should come. This allows proper cross-referencing to these anchors with
-- links along the text.
--
-- Currently, only headers, figures and tables anchors are supported. In images
-- and tables, the anchor is inserted at the caption.
--
-- Example: in a header with text "Heading 1", this filter inserts
-- bookmark-start tag before the text, and bookmark-end tag after.
--
-- Syntax:
-- <text:bookmark-start text:name="ELEMENTID"/>
-- ELEMENT TEXT
-- <text:bookmark-end text:name="ELEMENTID"/>
--
-- dependencies: util.lua, need to be in the same directory of this filter
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018
-- license: GPL version 3 or later

local utilPath = string.match(PANDOC_SCRIPT_FILE, '.*[/\\]')
require ((utilPath or '') .. 'util')

local function getBookmarkById(id)
  local bookmarkStart = '<text:bookmark-start text:name=\"' .. id .. '\"/>'
  local bookmarkEnd = '<text:bookmark-end text:name=\"' .. id .. '\"/>'
  return bookmarkStart, bookmarkEnd
end

function Header (hx)
  if FORMAT == 'odt' and hx.attr.identifier then
    local startTag, endTag = getBookmarkById(hx.attr.identifier)
    hx.content = util.putTagsOnContent(hx.content, startTag, endTag)
  end
  return hx
end

function Image (img)
  if FORMAT == 'odt' and img.caption and img.attr.identifier then
    local startTag, endTag = getBookmarkById(img.attr.identifier)
    img.caption = util.putTagsOnContent(img.caption, startTag, endTag)
  end
  return img
end

function Div (div)
  if FORMAT == 'odt' and util.isTableDiv(div) and div.attr.identifier then
    local id = div.attr.identifier
    return pandoc.walk_block(div, {
      Table = function(el)
        if el.caption then
          local startTag, endTag = getBookmarkById(id)
          el.caption = util.putTagsOnContent(el.caption, startTag, endTag)
        end
        return el
      end
    })
  end
  return div
end
