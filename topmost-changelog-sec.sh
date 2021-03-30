#!/usr/bin/env bash

chlog_file="CHANGELOG.md"

num_rels=`grep '^##' $chlog_file | wc -l`

if ((num_rels <= 1)) ; then
  sed -n '/^## /,$p' $chlog_file
else
  sed -n '/^## /,/^## /p' $chlog_file | head -n -1
fi

