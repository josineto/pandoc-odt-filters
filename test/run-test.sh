#!/bin/bash
file=test/Test.md
odt=test/Test.odt
html=test/Test.html

cd ..

echo Generating $odt

pandoc $file -d test/test -t odt -o $odt

echo Generating $html

pandoc $file -d test/test -t html5 -o $html

echo Open $odt and $html. Just $odt should be affected by odt- like filters.

cd test
