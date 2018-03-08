--
-- Improves lists when converting to ODT, by adding list styles to lists, and
-- apropriate paragraph styles to list items. Only lists that are one level deep
-- are supported; in lists with two or more levels, only the innermost level is
-- improved, generating strange results.
--
-- In bullet lists, the list style turns to that in variable `listStyle`,
-- and the paragraph style of list items turns to that in variable
-- `listParaStyle`.
--
-- In ordered lists, the list style turns to that in variable `numListStyle`,
-- and the paragraph style of list items turns to that in variable
-- `numListParaStyle`.
--
-- Currently, just italics, bold, links and line blocks are preserved in lists;
-- all other markup is ignored.
--
-- dependencies: util.lua, need to be in the same directory of this filter
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018
-- license: GPL version 3 or later

local listStyle = 'List_20_1'
local numListStyle = 'Numbering_20_1'
local listParaStyle = 'List_20_1'
local numListParaStyle = 'Numbering_20_1'

local utilPath = string.match(PANDOC_SCRIPT_FILE, '.*[/\\]')
require ((utilPath or '') .. 'util')

local tags = {}
tags.listStart = '<text:list text:style-name=\"' .. listStyle .. '\">'
tags.numListStart = '<text:list text:style-name=\"' .. numListStyle .. '\">'
tags.listEnd = '</text:list>'
tags.listItemStart = '<text:list-item>'
tags.listItemEnd = '</text:list-item>'

local function listHasInnerList(list)
  local hasInnerList = false
  pandoc.walk_block(list, {
    RawBlock = function (raw)
      hasInnerList = true
    end
  })
  return hasInnerList
end

local function getFilter(forOrderedList)
  local blockToRaw = util.blockToRaw
  blockToRaw.Plain = function (item)
    local paraStyle = listParaStyle
    if forOrderedList then
      paraStyle = numListParaStyle
    end
    local paraStartTag = '<text:p text:style-name=\"' .. paraStyle .. '\">'
    local para = paraStartTag .. pandoc.utils.stringify(item) .. '</text:p>'
    local content = tags.listItemStart .. para .. tags.listItemEnd
    return pandoc.Plain(pandoc.Str(content))
  end
  return blockToRaw
end

local function listFilter(list, isOrdered)
  if listHasInnerList(list) then
    return list
  end
  list = pandoc.walk_block(list, getFilter(isOrdered))
  local listTag = tags.listStart
  if isOrdered then
    listTag = tags.numListStart
  end
  local rawList = listTag .. pandoc.utils.stringify(list) .. tags.listEnd
  return pandoc.RawBlock('opendocument', rawList)
end

function BulletList(list)
  if FORMAT == 'odt' then
    return listFilter(list, false)
  end
end

function OrderedList(list)
  if FORMAT == 'odt' then
    return listFilter(list, true)
  end
end
