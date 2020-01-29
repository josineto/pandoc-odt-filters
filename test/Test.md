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

# Testing `odt-anchors.lua` (2 tests)

If all following links work, 2 tests pass (note that image and table links point to caption).

Image link, goes to @fig:public. Table link, goes to @tbl:dummy.

# Testing `odt-custom-styles.lua` (3 tests) {-}

If above heading gets style configured in filter (`unnumberedStyle` variable), 1st test passes.

Second test: [this phrase should be in "Source_Text" character style, with **bold here**, *italics here*, `a tab	here` (before "here" word) and a [link to Pandoc](http://pandoc.org) here]{custom-style="Source_Text"}.

Third test: below must be a bold red horizontal rule. If it appears as such, third test passes.

::: {custom-style="Red_20_horizontal_20_rule"}
* * *
:::

Fourth test following below:

::: {custom-style="Date"}
This paragraph should be in "Date" paragraph style,\
with a line break after comma and **bold text here**, *italics text here* and `a tab	here` (before "here" word).

| And this paragraph (in fact, a line block) also should be in "Date" paragraph style,
| with line breaks after each comma,
| with a [link to Pandoc](http://pandoc.org) here and a footnote^[if those two paragraphs get correct styles, and *italics* & **bold** here work, 4th test passes].
:::

# Testing citing performance and `odt-bib-style.lua` (2 tests)

Twenty one citations here: [@BoeBoebook2018; @CoeCoepresentation2018; @DoeDoearticle2018; @FoeFoenewspaperarticle2018; @GoeGoeconferencepaper2018; @HoeHoeblogpost2018; @JoeJoefilm2018], also [@KoeKoedisc2018; @LoeLoevideorecording2018; @MoeMoemanuscript2018; @NoeNoemap2018; @PoePoesculpture2018; @QoeQoewebsite2018; @RoeRoereport2018] and also [@SoeSoesectionBoe2018; @SoeSoesoftware2018; @ToeToethesis2018; @VoeVoedictionaryentry2018; @WoeWoeencyclopediaentry2018; @YoeYoebook2018; @ZoeZoesonata2018]. If these citations and following bibliography appears in correct format (according to CSL-file used), 1st test passes.

Additionally, if following bibliography gets style configured in filter (`bibliographyStyle` variable), 2nd test passes.
