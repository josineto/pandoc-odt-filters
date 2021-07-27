--
-- Searches for "abstract" entry in metadata and creates a Div in the beginning
-- of the document, containing markup from that entry. An "abstract-title" can
-- also be set on metadata, so this filter will create a header (level 1,
-- unnumbered) for the abstract.
--
-- In formats that support styling elements by classes (HTML for instance), the
-- abstract Div has ".abstract" class.
--
-- This filter doesn't work with DOCX and ODT writers, because those writers
-- already make an abstract section using "abstract" entry on metadata.
--
-- Usage: on metadata, put following fields:
--
-- abstract: Your *abstract* here, with **markup** allowed. Put '\' to wrap
-- lines.
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
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: february 2018 (first version)
-- license: GPL version 3 or later

local path = require 'pandoc.path'
utilPath = path.directory(PANDOC_SCRIPT_FILE)
dofile(path.join{utilPath, 'util.lua'})

local function getAbstractAttr()
  local attributes = {}
  return pandoc.Attr('abstractDiv', {'abstract'}, attributes)
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
  if FORMAT ~= 'docx' and FORMAT ~= 'odt' and doc.meta.abstract then

    table.insert(doc.blocks, 1, getAbstractDiv(doc.meta.abstract))

    if doc.meta['abstract-title'] then
      table.insert(doc.blocks, 1, getAbstractHeader(doc.meta['abstract-title']))
    end

    return pandoc.Pandoc(doc.blocks, doc.meta)
  end
end
