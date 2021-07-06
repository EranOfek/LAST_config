# LAST_config

Depends on AstroPack for the yaml readout machinery.

The configuration files are arranged according to this logic:

Files start with the class name of the object they refer to. 
They are organized in directories, class by class, to achieve a minimum of
order when they will grow up to a lot of them.

Logical names are built like <unit_label>_<mount#>_<telescope#>. _unit_label_
is a text label (e.g. 'dome', '0', '1'), the other are numbers.

_.create_ configurations are used at the object creation. Usually they 
refer to superclasses (obs.camera, obs.mount, etc.) and use the logical
name.

_.connect_ configurations are enforced after the communication with the
physical device is established. Usually they refer to the driver class,
and use the device physical name or address.