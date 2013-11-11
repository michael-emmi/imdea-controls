imdea-controls
==============

A script to control the room temperature, blinds, and lights at the IMDEA
Software Institute.

Dependencies
------------

* Ruby 1.9.2 or newer
* The Ruby [Mechanize](https://github.com/sparklemotion/mechanize) gem
* An office at the [IMDEA Software Institute](http://www.software.imdea.org)

Usage
-----

    blinds.rb [options]
    -u, --username USERNAME          Your USERNAME
    -p, --password PASSWORD          Your PASSWORD
    -r, --room ROOM                  Set the ROOM number
    -b, --blinds NUM                 Set the blinds to NUM
    -t, --temp TEMP                  Set the TEMPerature
    -w, --window LIGHT               Set the window LIGHT
    -d, --door LIGHT                 Set the door LIGHT
    -l, --lights LIGHT               Set all the LIGHTS
    -v, --verbose

Configuration file
------------------

`blinds.rb` looks for `.blinds.yml` in your home directory `~` and your current
directory `.`.  If `.blinds.yml` exists, `blinds.rb` will read your USERNAME,
PASSWORD, and ROOM.  `.blinds.yml` has the following format:

    username: USERNAME
    password: PASSWORD
    room_no: ROOM

Author
------
[Michael Emmi](https://github.com/michael-emmi)
