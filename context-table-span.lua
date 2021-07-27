--
-- Makes row spans kind of possible in Pandoc tables, when using ConTeXt
-- writer with Pandoc. Only pipe tables (using | as column separator)
-- were tested; other Pandoc tables perhaps work too.
--
-- This filter does not make *real* row spans; it just disables the bottom
-- border of marked cells, which then seem to be spanned. Because of this,
-- it needs to disable automatic column widths put by Pandoc, and also
-- disables alignment in the column marked (see below).
--
-- Usage: considering the row span as a group of individual cells, in such
-- a column:
--
-- 1. do *not* specify any alignment in the column with row span.
-- 2. mark the upmost cell of group with `sc` (including backticks, making
-- an inline code) in its very beginning. `sc` stands for *span horizontally
-- centered*; if you want left/right align, use `sl`/`sr` instead.
-- 3. if you need a span of more than 1 row, mark all cells but last of group.
-- 4. mark all cells of the column with `c`, `l` or `r` (center, left, right)
-- in their beginnings.
--
-- Example: in Markdown file:
--
-- | `c` Head A     |   Head B    | `l` Head C     |
-- | -------------- |:-----------:| -------------- |
-- | `sc` Cell A1-2 |   Cell B1   | `l` Cell C1    |
-- |                |   Cell B2   | `sl` Cell C2-3 |
-- | `c` Cell A3    |   Cell B3   |                |
--
-- This results in a table with cells A1-A2 and C2-C3 joined (note `sc` and
-- `sl` marks), with column A centered (note `c` marks) and column C left
-- aligned (note `l` marks).
--
-- author:
--   - name: José de Mattos Neto
--   - address: https://github.com/jzeneto
-- date: january 2019 (first version)
-- license: GPL version 3 or later

local conversions = {}
conversions.sc = '[bottomframe=off, align=center]'
conversions.sl = '[bottomframe=off, align=right]' -- ConTeXt align is inverted
conversions.sr = '[bottomframe=off, align=left]'  -- ConTeXt align is inverted
conversions.c = '[align=center]'
conversions.l = '[align=right]' -- ConTeXt align is inverted
conversions.r = '[align=left]'  -- ConTeXt align is inverted

function Table (tbl)
  if FORMAT == 'context' then
    local hasSpans = false
    tbl = pandoc.walk_block(tbl, {
      Code = function (code)
        local raw = conversions[code.text]
        if raw then
          hasSpans = true
          return pandoc.RawInline('context', raw)
        end
      end
    })
    if (hasSpans) then
      local size = #tbl.widths
      tbl.widths = {}
      for i=1, size do
        table.insert(tbl.widths, 0.0)
      end
    end
    return tbl
  end
end
