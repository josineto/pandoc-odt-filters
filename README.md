# Pandoc ODT filters

Filters to improve Pandoc's conversion to ODT. [Pandoc](https://github.com/jgm/pandoc) is a great tool to convert between document formats, but conversion to ODT ([OpenDocument](https://en.wikipedia.org/wiki/OpenDocument) format) is poor in some aspects. These filters attempt to workaround those aspects.

At the beginning of each file (it's just a plain text file, you can open with any text editor), there's a little text explaining what the filter does. Please read carefully that little text, and decide by yourself if that filter works for your particular case. In case where customization is possible, there are local variables at the very beginning of code, after text and *before* all `require`s.

None of these filters are guaranteed to work, as I wrote them only to address Pandoc's problems in ODT writer. Hopefully, in the near future none of them will be either necessary, as Pandoc's ODT writer become more robust.

## Requirements

- [Pandoc](https://github.com/jgm/pandoc), minimum version: 2.2.2
- `util.lua` in the same directory of each filter (see below)

## Installation

Just download whatever filter you want, *along with* `util.lua` (see below), and use it!

## Usage

You can use as many filters as you want. Each filter must have his own declaration in command line: `--lua-filter <filter-name>.lua`. Here's an example with just one filter:

~~~~ shell
pandoc -t odt+smart --lua-filter <filter-name>.lua <your-file>.md -o <destination-file>.odt
~~~~

Each filter addresses a particular problem, and few of them need other filters to be run to properly work. Look at the text in the beginning of file, on `dependencies` item, to see if the filter depends upon other(s) filter(s).

All of them use `util.lua` (where I put common filter tasks, to reuse code), so **you need this file too**.

**IMPORTANT NOTE**

All filters can go whatever directory you want, but an `util.lua` **must** be in the same directory of each filter that depends on it. For instance, if you put three filters on three different directories, you need to copy `util.lua` to each of these directories.


## Available filters

| Filter name             | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `abstract.lua`          | [*For all writers except `docx`*] Searches for `abstract` entry in metadata and creates a `Div` in the beginning of the document, containing markup from that entry. An `abstract-title` can also be set on metadata, so this filter will create a header (level 1, unnumbered) for the abstract.                                                                                                                                                                                   | If using with ODT writer, `odt-custom-styles.lua` **must** be run **after** this filter, to make abstract custom-style work.                                                                                                                                                                                                                                                                                                                                              |
| `odt-anchors.lua`       | Corrects anchors when converting to ODT, by adding bookmarks where anchors should come. This allows proper cross-referencing to these anchors with links along the text.                                                                                                                                                                                                                                                                                                            | Currently, only figures and tables anchors are supported, where the anchor is inserted at the caption. Only figures and tables that *have an* `id` are processed (see [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/#general-options) for `autoSectionLabels`). (As of [Pandoc 2.2.2](https://github.com/jgm/pandoc/releases/tag/2.2.2), header bookmarks are created properly; see [Pandoc' issue 4358](https://github.com/jgm/pandoc/issues/4358)).     |
| `odt-bib-style`         | Corrects the style of bibliography when converting to ODT. This is necessary because Pandoc's ODT writer doesn't properly set this style.                                                                                                                                                                                                                                                                                                                                           | `odt-custom-styles.lua` *must* also be used, and must be *after* this filter. Currently, all paragraphs in bibliography are turned into raw blocks with correct style. Because of this, only italics, bold and link markups are keep; all other markup in bibliography is lost. (see [Pandoc's issue 3459](https://github.com/jgm/pandoc/issues/3459)).                                                                                                                   |
| `odt-captions.lua`      | Corrects captions when converting to ODT, by adding sequence fields to the number of caption. This allows the creation of lists of figures, tables, etc.                                                                                                                                                                                                                                                                                                                            | Currently, only figure and table captions are supported. Only images and tables with caption are processed. Expected syntax of caption is the generated by [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref). (see [Pandoc's issue 2401](https://github.com/jgm/pandoc/issues/2401))                                                                                                                                                                        |
| `odt-custom-styles.lua` | Workaround to use custom styles when converting to ODT. This filter turns divs and spans with custom style into ODT raw blocks/inlines, with the ODT code using the custom style. Also, headers with custom style (like the `{-}`, aka `unnumbered` class) are turned into ODT raw heading blocks with the custom style. If variable `useClassAsCustomStyle` is `true`, and element (div/span/header) doesn't have a `custom-style` attribute, then first `class` is used as style. | Currently, the following elements are **ignored** by this filter: blockquotes, lists (see `odt-lists.lua`), tables and code blocks (for `div` styles), and citations, smallcaps (see `odt-smallcaps.lua`), images, quotes, strikeouts, super and subscript, math and code inlines (for `span` styles). This filter will become useless when pandoc finally implement custom styles in ODT writer (see [Pandoc's issue #2106](https://github.com/jgm/pandoc/issues/2106)). | 
| `odt-lists.lua`         | Improves lists when converting to ODT, by adding list styles to lists, and apropriate paragraph styles to list items.                                                                                                                                                                                                                                                                                                                                                               | Only lists that are one level deep are supported; in lists with two or more levels, only the innermost level is improved, generating strange results. Currently, just italics, bold, links and line blocks are preserved in lists; all other markup is ignored.                                                                                                                                                                                                           |
| `odt-smallcaps.lua`     | Turns smallcaps into `span` with custom character style, when converting to ODT. This is necessary because LibreOffice default smallcaps is not *true* smallcaps, but rather *reduced capitalised* letters.                                                                                                                                                                                                                                                                         | You need to use a `reference-doc` with the custom character style properly set. After this, change variable `smallcapsStyle` to the name of that custom character style. Example: use `Myriad Pro:smcp` as font in style configuration. `smcp` is the [OpenType smallcaps feature](https://en.wikipedia.org/wiki/List_of_typographic_features#Features_intended_for_bicameral_[cased]_alphabets_(Latin,_Greek,_Cyrillic,_etc.)).                                          |
| `util.lua`              | Utilities for use by other filters.                                                                                                                                                                                                                                                                                                                                                                                                                                                 | This file **must** be in the same directory of any filter that depends on it.                                                                                                                                                                                                                                                                                                                                                                                             |

## Contributing

Feel free to make pull requests. I've written these filters primarily for my needs, but I hope they can help other people.

### TODO's

Below there are things I didn't resolve yet. Some of them are checked, either because current filters already make the work, or because I already make that work, but for some other problems didn't put that solution here.

- [ ] make TOC work:
  - [ ] filter to put all heading-links in metadata, to access in template
  - [ ] access heading-links in template
  - [ ] get page number of each link (*impossible, I think...*)
- [ ] make TOC position configurable, by `[toc]` markup:
  - [ ] filter to find `[toc]` occurrences and substitute by custom template variable
  - [ ] custom template that recognizes that variable (*hard, I think...*)
- [ ] make pre-textual styles work:
  - [x] get `unnumbered` headings as textual headings (without numbering)
  - [x] mark `unnumbered` headings, that come before first "normal" heading, with custom style
  - [ ] avoid errors with these headings

## License

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

See [LICENSE](https://github.com/jzeneto/pandoc-odt-filters/blob/master/LICENSE) for details.

© 2018 José de Mattos Neto
