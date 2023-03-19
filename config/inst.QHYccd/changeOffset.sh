#!/bin/sh

for f in `ls *connect.yml`
do
    cat $f  | sed -e "s/Offset : 4/Offset : 11/" > temp.yml
    mv temp.yml $f
done

