#!/bin/bash

# the present version creates configuration files using the mastrolindo branch
#  Id convention. TODO, a flag for creating files (or links?) using the
#  Locator.CanonicalLocation naming convention of branch webapi_transition
#  (If I count correctly, this should affect only obs. configurations, not inst.,
#   except for inst.tinycontrolIPpowerSocket.create and .destroy)

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
  echo "       A way to retrieve them in Matlab: Q=inst.QHYccd; Q.allQHYCameraNames"
}

if [[ -z $1 || $1 == "-h" || $1 == "-?" ]]; then
  instructions;
  exit
fi

unit=`printf "%02d" $1`

echo "Creating configuration files for unit $unit :"

##################

echo "  - creating power switches configurations"

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

echo "  - creating inst.XerxesMount...connect configuration"

tail +2 config/inst.XerxesMount/inst.XerxesMount.#TEMPLATE.connect.yml >\
        config/inst.XerxesMount/inst.XerxesMount.$2.connect.yml


###############

if [[ -z $3 || -z $4 || -z $5 || -z $6 ]]; then
   echo "I'm expecting four alphanumeric serial numbers of QHY cameras; aborting"
   exit
fi

echo "  - creating four inst.QHYccd...connect configurations"

for s in $3 $4 $5 $6; do
    tail +2 config/inst.QHYccd/inst.QHYccd.QHY600M-#TEMPLATE.connect.yml >\
           config/inst.QHYccd/inst.QHYccd.QHY600M-$s.connect.yml
done

echo "  - creating four obs.camera...create configurations"

tail +3 config/obs.camera/obs.camera.#TEMPLATE.create.yml |\
        sed -e s/XXXXXXXXXXXXXXXXX/$3/  -e s/lastXX/last$unit\e/g \
            -e s/dataX/data1/ -e s/NN/1/ -e s/NESW/NE/ > \
        config/obs.camera/obs.camera.$unit\_1_1.create.yml
tail +3 config/obs.camera/obs.camera.#TEMPLATE.create.yml |\
        sed -e s/XXXXXXXXXXXXXXXXX/$4/  -e s/lastXX/last$unit\e/g \
            -e s/dataX/data2/ -e s/NN/2/ -e s/NESW/SE/ > \
        config/obs.camera/obs.camera.$unit\_1_2.create.yml
tail +3 config/obs.camera/obs.camera.#TEMPLATE.create.yml |\
        sed -e s/XXXXXXXXXXXXXXXXX/$5/  -e s/lastXX/last$unit\w/g \
            -e s/dataX/data1/ -e s/NN/3/ -e s/NESW/SW/ > \
        config/obs.camera/obs.camera.$unit\_1_3.create.yml
tail +3 config/obs.camera/obs.camera.#TEMPLATE.create.yml |\
        sed -e s/XXXXXXXXXXXXXXXXX/$6/  -e s/lastXX/last$unit\w/g \
            -e s/dataX/data2/ -e s/NN/4/ -e s/NESW/NW/ > \
        config/obs.camera/obs.camera.$unit\_1_4.create.yml

###############

echo "  - creating four obs.focuser...create configurations"

tail +3 config/obs.focuser/obs.focuser.#TEMPLATE.create.yml | \
   sed -e s/XXXX/pci-0000:48:00.0-usb-0:2:1.0/ > \
   config/obs.focuser/obs.focuser.$unit\_1_1.create.yml
tail +3 config/obs.focuser/obs.focuser.#TEMPLATE.create.yml | \
   sed -e s/XXXX/pci-0000:49:00.0-usb-0:2:1.0/ > \
   config/obs.focuser/obs.focuser.$unit\_1_2.create.yml
tail +3 config/obs.focuser/obs.focuser.#TEMPLATE.create.yml | \
   sed -e s/XXXX/pci-0000:49:00.0-usb-0:2:1.0/ > \
   config/obs.focuser/obs.focuser.$unit\_1_3.create.yml
tail +3 config/obs.focuser/obs.focuser.#TEMPLATE.create.yml | \
   sed -e s/XXXX/pci-0000:48:00.0-usb-0:2:1.0/ > \
   config/obs.focuser/obs.focuser.$unit\_1_4.create.yml


###############

echo "  - creating obs.mount...create configuration"

tail +3 config/obs.mount/obs.mount.#TEMPLATE.create.yml | \
   sed -e "s|XXXX|\/dev\/ttyS4|" -e s/lastXX/last$unit\e/ > \
   config/obs.mount/obs.mount.$unit\_1.create.yml

###############

echo "  - creating obs.unitCS...create configuration for master and four slaves"

tail +2 config/obs.unitCS/obs.unitCS.#TEMPLATE_MASTER.create.yml > \
    config/obs.unitCS/obs.UnitCS.$unit.create.yml

for i in {1..4}; do
    tail +2 config/obs.unitCS/obs.unitCS.#TEMPLATE_SLAVE.create.yml | \
        sed -e s/XX/$unit/ -e s/NN/$i/ >  config/obs.unitCS/obs.UnitCS.$unit\_slave_$i.create.yml
done

###############

echo "  - creating four obs.util.SpawnedMatlab...create configurations, for slaves"

tail +2 config/obs.util.SpawnedMatlab/obs.util.SpawnedMatlab.#TEMPLATE.create.yml | \
    sed -e s/XX/$unit\e/ > \
    config/obs.util.SpawnedMatlab/obs.util.SpawnedMatlab.$unit\_slave_1.create.yml
tail +2 config/obs.util.SpawnedMatlab/obs.util.SpawnedMatlab.#TEMPLATE.create.yml | \
    sed -e s/XX/$unit\e/ > \
    config/obs.util.SpawnedMatlab/obs.util.SpawnedMatlab.$unit\_slave_2.create.yml
tail +2 config/obs.util.SpawnedMatlab/obs.util.SpawnedMatlab.#TEMPLATE.create.yml | \
    sed -e s/XX/$unit\w/ > \
    config/obs.util.SpawnedMatlab/obs.util.SpawnedMatlab.$unit\_slave_3.create.yml
tail +2 config/obs.util.SpawnedMatlab/obs.util.SpawnedMatlab.#TEMPLATE.create.yml | \
    sed -e s/XX/$unit\w/ > \
    config/obs.util.SpawnedMatlab/obs.util.SpawnedMatlab.$unit\_slave_4.create.yml

