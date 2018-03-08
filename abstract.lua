--
-- Searches for "abstract" entry in metadata and creates a Div in the beginning
-- of the document, containing markup from that entry. An "abstract-title" can
-- also be set on metadata, so this filter will create a header (level 1,
-- unnumbered) for the abstract.
--
-- In formats that support styling elements by classes (HTML for instance), the
-- abstract Div has ".abstract" class. In ODT, the abstract paragraph has style
-- defined by abstractODTStyle (first line of code on this file). Modify that
-- variable if necessary.
--
-- This filter doesn't work with DOCX writer, because that writer already makes
-- an abstract section using "abstract" entry on metadata.
--
-- Usage: on metadata, put following fields:
--
-- abstract: Your *abstract* here, with **markup** allowed^[in ODT, only\
--     italics, bold and line-block are supported]. Put '\' to wrap lines.
--
-- abstract-title: Optional *Abstract* Title (same as abstract markup)
--
-- This will result in the following markup on the beginning of document:
--
-- # Optional *Abstract* Title (same as abstract markup) {-}
--
-- Your *abstract* here, with **markup** allowed^[in ODT, only italics, bold and
-- line-block are supported]. Put '\' to wrap lines.
--
-- dependencies:
--   - util.lua, need to be in the same directory of this filter
--   - odt-custom-styles.lua, IF using with ODT writer. That filte MUST be run
--     AFTER this filter, to make abstract custom-style work.
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018
-- license: GPL version 3 or later

local abstractODTStyle = 'Resumo'

local utilPath = string.match(PANDOC_SCRIPT_FILE, '.*[/\\]')
require ((utilPath or '') .. 'util')

local function getAbstractAttr()
  local attributes = {}
  if FORMAT == 'odt' then
    attributes['custom-style'] = abstractODTStyle
  end
  return pandoc.Attr('abstractDiv', {'.abstract'}, attributes)
end

local function getContents(metaElement)
  local contents = {}
  for _,el in pairs(metaElement) do
    table.insert(contents, el)
  end
  return contents
end

local function getAbstractDiv(metaAbstract)
  return pandoc.Div(pandoc.Para(getContents(metaAbstract)), getAbstractAttr())
end

local function getAbstractHeader(abstractTitle)
  local attr = pandoc.Attr('sec:abstract', {'unnumbered'}, {})
  return pandoc.Header(1, getContents(abstractTitle), attr)
end

function Pandoc (doc)
  if FORMAT ~= 'docx' and doc.meta.abstract then
    table.insert(doc.blocks, 1, getAbstractDiv(doc.meta.abstract))

    if doc.meta['abstract-title'] then
      table.insert(doc.blocks, 1, getAbstractHeader(doc.meta['abstract-title']))
    end

    return pandoc.Pandoc(doc.blocks, doc.meta)
  end
end
