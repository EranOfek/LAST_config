#!/bin/bash

instructions()
{
  echo "This script creates new configuration files for all of the components"
  echo " of a new LAST unit at Neot Smadar, copying from templates."
  echo "Syntax:"
  echo  "  " $0 " UNIT# MountName C1_SN# C2_SN# C3_SN# C4_SN#"
  echo "where: Unit# is the number of the unit (e.g., 5)"
  echo "       MountName is the string returned by instXerxesMount.PhysicalId"
  echo "       C1_SN#...C4_SN# are the full serial numbers of the four cameras"
  echo "       (17 alphanumeric digits, without the QHY600M- prefix)"
}

if [[ -z $1 || $1 == "-h" || $1 == "-?" ]]; then
  instructions;
  exit
fi

unit=`printf "%02d" $1`

echo "Creating configuration files for unit $unit"

##################

echo "  - Creating power switches configurations"

## TODO: a flag for changing between staging and production IP addresses
subnet=3; # 2 in production
ipbase=50; # 0 in production
address1=$(( $ipbase + 2 * $unit - 1 ))
address2=$(( $ipbase + 2 * $unit ))

tail +2 config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.#TEMPLATE.create.yml \
   | sed -e s/X.X/$subnet.$address1/ > \
   config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.$unit\_1.create.yml

tail +2 config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.#TEMPLATE.create.yml \
   | sed -e s/X.X/$subnet.$address2/ > \
   config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.$unit\_2.create.yml

tail +2 config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.#TEMPLATE.destroy.yml \
   | sed -e "s/\[0, 0, 0, 0, 0, 0\]/[0, 0, 0, 0, 0, 0]/" > \
   config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.$unit\_1.destroy.yml

tail +2 config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.#TEMPLATE.destroy.yml \
   | sed -e "s/\[0, 0, 0, 0, 0, 0\]/[0, 0, 1, 1, 0, 0]/" > \
   config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.$unit\_2.destroy.yml

tail +2 config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.#TEMPLATE.connect.yml >\
   config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.PSWITCH$unit\E.connect.yml

tail +2 config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.#TEMPLATE.connect.yml >\
   config/inst.tinycontrolIPpowerSocket/inst.tinycontrolIPpowerSocket.PSWITCH$unit\W.connect.yml

################

if [[ -z $2 ]]; then
   echo "I'm expecting an identification string of the mount controller box; aborting"
   exit
fi

echo "  - Creating inst.XerxesMount...connect configuration"

tail +2 config/inst.XerxesMount/inst.XerxesMount.#TEMPLATE.connect.yml >\
        config/inst.XerxesMount/inst.XerxesMount.$2.connect.yml


###############

if [[ -z $3 || -z $4 || -z $5 || -z $6 ]]; then
   echo "I'm expecting four alphanumeric serial numbers of QHY cameras; aborting"
   exit
fi

echo "  - Creating four inst.QHYccd...connect configurations"

tail +2 config/inst.QHYccd/inst.QHYccd.QHY600M-#TEMPLATE.connect.yml >\
        config/inst.QHYccd/inst.QHYccd.QHY600M-$3.connect.yml
tail +2 config/inst.QHYccd/inst.QHYccd.QHY600M-#TEMPLATE.connect.yml >\
        config/inst.QHYccd/inst.QHYccd.QHY600M-$4.connect.yml
tail +2 config/inst.QHYccd/inst.QHYccd.QHY600M-#TEMPLATE.connect.yml >\
        config/inst.QHYccd/inst.QHYccd.QHY600M-$5.connect.yml
tail +2 config/inst.QHYccd/inst.QHYccd.QHY600M-#TEMPLATE.connect.yml >\
        config/inst.QHYccd/inst.QHYccd.QHY600M-$6.connect.yml


