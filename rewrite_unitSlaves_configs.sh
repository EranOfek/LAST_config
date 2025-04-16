#!/bin/bash

for k in {1..10}; do
    unit=`printf "%02d" $k`
    for i in {1..4}; do
        tail +2 config/obs.unitCS/obs.unitCS.#TEMPLATE_SLAVE.create.yml | \
            sed -e s/XX/$unit/ -e s/NN/$i/ >  config/obs.unitCS/obs.unitCS.$unit\_slave_$i.create.yml
    done
done