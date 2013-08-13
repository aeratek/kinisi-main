Steps to setup the web application [REQUIRED]
----
Requirements: node (npm), postgres, linux, git


1. Ensure node is installed. TODO - add checks for this inside scripts.
2. Ensure postgres is installed. This is a bit more involved and hasn't been scripted. This README will loosely guide the steps.

On your linux box, run the equivalent packagement tools to install at least the latest version of git and recently modern version of postgres, say 9.X for these scripts.

    sudo apt-get install git
    sudo apt-get install postgresql

With that last command, on my linux machine, I installed postgres v9.1.  For the necessary changes made post-install, following the instructions here:
https://help.ubuntu.com/10.04/serverguide/postgresql.html

Note: I have documented my steps as best as possible here, but you should read the PostgreSQL admin guide if you want more in-depth information that is out of scope for this README. This is by no means a complete setup to secure everything.

3. Modify postgresq.conf.
    sudo vim /etc/postgresql/9.1/main/postgresql.conf

On my version, I changed line 59 to remove the hashtag/pound sign.

    #listen_addresses = 'localhost' 
to

    listen_addresses = 'localhost'

Note: this should be an external IP address to allow external connections 
 

4. Modify pg_hba.conf.

    sudo vim /etc/postgresql/9.1/main/pg_hba.conf 

changed the first non-commented line to:

    local   all             postgres                                peer
    local   all             all                                     peer
to

    local   all             postgres                                md5 
    local   all             all                                     md5 

5. Changed the default postgres user password according to the instructions given in the link above.

6. Execute install_pg_helper.sh to install the roles. The password set in Step 5 is required for this step.

7. Git clone this repository to the desired location on the server. Change directories to that folder and run: 


    npm install.
