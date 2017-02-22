#!/bin/bash

search="@import url(\"\/\/fonts.googleapis.com\/css?family=Roboto:400,500\");"
replace="@import url(\"..\/..\/roboto.css\\\");"
sed  "s/${search}/${replace}/g" _build/html/_static/bootswatch-3.3.4/sandstone/bootstrap.min.css > _build/html/_static/bootswatch-3.3.4/sandstone/bootstrap.min.css.tmp
mv -f _build/html/_static/bootswatch-3.3.4/sandstone/bootstrap.min.css.tmp _build/html/_static/bootswatch-3.3.4/sandstone/bootstrap.min.css

search="navbar-brand{float:left;padding:20px 15px"
replace="navbar-brand{float:left;padding:8px 15px"
sed  "s/${search}/${replace}/g" _build/html/_static/bootswatch-3.3.4/sandstone/bootstrap.min.css > _build/html/_static/bootswatch-3.3.4/sandstone/bootstrap.min.css.tmp
mv -f _build/html/_static/bootswatch-3.3.4/sandstone/bootstrap.min.css.tmp _build/html/_static/bootswatch-3.3.4/sandstone/bootstrap.min.css

cd _build/html
rm -rf _static/bootstrap-2.3.2
rm -rf _static/bootswatch-2.3.2
rm -rf _sources
find . -name "*" -type f > files.txt
cp -Rf * ../../../docs/
cd ../..
