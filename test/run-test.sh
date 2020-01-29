#!/bin/bash
file=test/Test.md
odt=test/Test.odt
html=test/Test.html

cd ..

echo Generating $odt

pandoc -s $file \
  -M bibliography=test/bibliography.yaml \
  -M csl=test/abnt.csl \
  -M numberSections=true \
  -M autoSectionLabels=true \
  -M linkReferences=true \
  -M nameInLink=true \
  --filter pandoc-crossref \
  --filter pandoc-citeproc \
  --lua-filter abstract.lua \
  --lua-filter odt-anchors.lua \
  --lua-filter odt-bib-style.lua \
  --lua-filter odt-captions.lua \
  --lua-filter odt-lists.lua \
  --lua-filter odt-smallcaps.lua \
  --lua-filter odt-custom-styles.lua \
  --resource-path=test \
  --reference-doc=test/custom-reference-doc.odt \
  -p \
  -o $odt \
  -f markdown+smart \
  -t odt

echo Generating $html

pandoc -s $file \
  -M bibliography=test/bibliography.yaml \
  -M csl=test/abnt.csl \
  -M numberSections=true \
  -M autoSectionLabels=true \
  -M linkReferences=true \
  -M nameInLink=true \
  --filter pandoc-crossref \
  --filter pandoc-citeproc \
  --lua-filter abstract.lua \
  --lua-filter odt-anchors.lua \
  --lua-filter odt-bib-style.lua \
  --lua-filter odt-captions.lua \
  --lua-filter odt-lists.lua \
  --lua-filter odt-smallcaps.lua \
  --lua-filter odt-custom-styles.lua \
  --resource-path=test \
  -p \
  -o $html \
  -f markdown+smart \
  -t html5

echo Open $odt and $html. Just $odt should be affected by odt- like filters.

cd test
