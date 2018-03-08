---
title: Testing pandoc-odt-filters
author: José de Mattos Neto
date: 07-03-2018
abstract-title: Testing `abstract.lua`
abstract:
    If this abstract appears as first section in document, with style configured in filter (`abstractODTStyle` variable), test passes.
---

# Testing `odt-captions.lua` (2 tests)

If image and table captions below get correct LibreOffice sequence field, 1st and 2nd tests pass.

![Image by Roger McLassus - Own work, CC BY-SA 3.0, [link](https://commons.wikimedia.org/w/index.php?curid=526228)](img/Detaching_drop.jpg){#fig:public width=80%}

| Column 1 | Column 2 |
| -------- | -------- |
| value 1  | value 2  |

: Dummy table {#tbl:dummy}

# Testing `odt-lists.lua` (2 tests)

If unordered list gets list style configured in filter (`listStyle` variable), and items get paragraph style (`listParaStyle` variable), 1st test passes.

* banana
* apple
* orange

Ordered list style must be of `numListStyle` variable, and item paragraph style must be of `numListParaStyle` variable, then 2nd test passes.

1. item 1
2. item 2
3. item 3

# Testing `odt-anchors.lua` (3 tests)

If all following links work, 3 tests pass (note that image and table links point to caption).

Section link, goes to @sec:testing-odt-bib-style.lua . Image link, goes to @fig:public. Table link, goes to @tbl:dummy.

# Testing `odt-custom-styles.lua` (3 tests) {-}

If above heading gets style configured in filter (`unnumberedStyle` variable), 1st test passes.

If following text gets `Source_Text` character style, 2nd test passes. [This phrase should be in Source_Text style, with **bold here** and *italics here*]{custom-style="Source_Text"}.

If following text gets `Date` paragraph style, 3rd test passes.

::: {custom-style="Date"}
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Maecenas porttitor congue massa.
:::

# Testing `odt-bib-style.lua`

A citation here [@DoeDummybook2018]. If following bibliography gets style configured in filter (`bibliographyStyle` variable), test passes.
