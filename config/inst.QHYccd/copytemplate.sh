#!/bin/sh

for f in `ls *connect.yml`
do
    cp inst.QHYccd.QHY600M-#TEMPLATE.yml $f
done
