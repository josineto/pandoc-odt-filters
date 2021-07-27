echo off

set file="test/Test.md"
set odt="test/Test.odt"
set html="test/Test.html"

cd..

echo Generating %odt%

pandoc %file% -d test/test -t odt -o %odt%

echo Generating %html%

pandoc %file% -d test/test -t html5 -o %html%

echo Open %odt% and %html%. Just %odt% should be affected by odt- like filters.

cd test

pause
