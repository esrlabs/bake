#!/bin/bash
search="@import url(\"\/\/fonts.googleapis.com\/css?family=Roboto:400,500\");"
replace="@import url(\"..\/..\/roboto.css\\\");"
sed -i "s/${search}/${replace}/g" _build/html/_static/bootswatch-3.3.4/sandstone/bootstrap.min.css
