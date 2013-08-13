#!/bin/sh -x
# assumptions: postgres is installed, postgres user credentials required
# postgres initial setup - creates databases for air quality project
# does not install schemas or tables
# these instructions were tested on ubuntu 12

# create the 'superuser' role -- will prompt you for passwords
sudo -u postgres createuser --superuser --pwprompt --createdb $1

# create the 'application' role -- will prompt you for passwords
sudo -u postgres createuser --pwprompt --no-createdb --no-superuser --no-createrole $2

# create the default database
createdb -U internal platform

# create the testing database if necessary
#createdb -U internal platformtest

