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

-- Required escapes.
-- Ampersand ('&') MUST be the first element added to table `escapes`.
local escapes = {}
escapes["&"] = "&amp;"
escapes["<"] = "&lt;"
escapes[">"] = "&gt;"
local escPattern = "([&<>])"
util.escape = function (text)
  text = string.gsub(text, escPattern, function(char)
           return escapes[char]
         end)
  return text
end

local tags = {}
tags.emph = '<text:span text:style-name=\"Emphasis\">'
tags.strong = '<text:span text:style-name=\"Strong_20_Emphasis\">'
tags.spanEnd = '</text:span>'
tags.linkEnd = '</text:a>'
tags.lineBreak = '<text:line-break />'
tags.noteStart = '<text:note text:id=\"ftn0\" text:note-class=\"footnote\">' ..
  '<text:note-citation>1</text:note-citation><text:note-body>' ..
  '<text:p text:style-name=\"Footnote\">'
tags.noteEnd = '</text:p></text:note-body></text:note>'

local filters = {}
filters.str = function(str)
  local content = util.escape(pandoc.utils.stringify(str))
  return pandoc.Str(content)
end

filters.emph = function(emph)
  local content = tags.emph .. util.escape(pandoc.utils.stringify(emph)) .. tags.spanEnd
  return pandoc.Str(content)
end

filters.strong = function(strong)
  local content = tags.strong .. util.escape(pandoc.utils.stringify(strong)) .. tags.spanEnd
  return pandoc.Str(content)
end

filters.link = function(link)
  local linkTag = '<text:a xlink:type=\"simple\" xlink:href=\"' .. util.escape(link.target) .. '\" office:name=\"\">'
  local content = linkTag .. util.escape(pandoc.utils.stringify(link)) .. tags.linkEnd
  return pandoc.Str(content)
end

filters.lineBreak = function(line)
  return pandoc.Str(tags.lineBreak)
end

filters.note = function(note)
  local noteSpan = pandoc.Span(note.c)
  local content = tags.noteStart .. pandoc.utils.stringify(noteSpan) .. tags.noteEnd
  return pandoc.Str(content)
end

filters.div = function(div)
  return div.content
end

filters.rawInline = function(raw)
  return pandoc.Str(raw.text)
end

util.inlineToRaw = {
  Emph = filters.emph,
  Strong = filters.strong,
  Str = filters.str,
  Link = filters.link,
  LineBreak = filters.lineBreak,
  Note = filters.note,
  RawInline = filters.rawInline
}

util.blockToRaw = util.inlineToRaw
util.blockToRaw.Div = filters.div

util.tags = tags
