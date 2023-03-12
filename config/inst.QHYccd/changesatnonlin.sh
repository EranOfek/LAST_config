#!/bin/sh

for f in `ls *connect.yml`
do
    head -9 $f > temp.yml
    tail +19 $f >> temp.yml
    cat temp.yml | sed -e "s/# Measured parameters like above, but repeated here for the current mode,//" \
                 -e "s/#  not looked up lookup from above/# measured values as per Table 4 of the Overview paper/" \
                 -e "s/\['GAIN',0.9\]/\['GAIN',0.75\]/" \
                 -e "s/\['READNOI',4.5\]/\['READNOI',3.0\]/" \
                 -e "s/\['SATURVAL',60000\]/\['SATURVAL',62000\]/" \
                 -e "s/\['DARKCUR',0.01\]/\['DARKCUR',0.008\]/" \
                 -e "s/\['NONLIN',50000\]/\['NONLIN',62000\]/" > $f
done

rm temp.yml
