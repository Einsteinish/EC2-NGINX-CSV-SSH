EC2, Bash, Nginx, CSV parsing, and SSH
========

## How to run
The shell script, start.sh, takes 4 args (ip, key, url, column):

```
$ ./start.sh 3.91.68.9 my.pem https://data.cityofnewyork.us/api/views/833y-fsy8/rows.csv?accessType=DOWNLOAD 4
```

We can run it from our local machine, and it generates an nginx web server config script that runs on remote via ssh. The config script does nginx install, parse the csv, and then puts V.txt files into the web root, /var/www/html.

We can find a sample output from a run at the bottom of README.  
It used [NYPD Shooting Incident Data (Historic)](https://data.cityofnewyork.us/api/views/833y-fsy8/rows.csv?accessType=DOWNLOAD). 
The script has been tested on my Mac (bash 5.1.4) and deployed an nginx on Ubuntu 16.0.4 using my pem key.

After the CSV parsing, the generated V.txt files look like this:
```
ubuntu@ip-172-31-35-14:/var/www/html$ ls
BRONX.txt  BROOKLYN.txt  MANHATTAN.txt  QUEENS.txt  STATEN.txt  index.nginx-debian.html
```

## sample output:
Here is the sample output from the run:
```
$ ./start.sh 3.91.68.9 my.pem https://data.cityofnewyork.us/api/views/833y-fsy8/rows.csv?accessType=DOWNLOAD 4

Hit:1 http://us-east-1.ec2.archive.ubuntu.com/ubuntu bionic InRelease
Hit:2 http://us-east-1.ec2.archive.ubuntu.com/ubuntu bionic-updates InRelease
Hit:3 http://us-east-1.ec2.archive.ubuntu.com/ubuntu bionic-backports InRelease
Get:4 http://security.ubuntu.com/ubuntu bionic-security InRelease [88.7 kB]
Fetched 88.7 kB in 0s (276 kB/s)
Reading package lists...
Reading package lists...
Building dependency tree...
Reading state information...
nginx is already the newest version (1.14.0-0ubuntu1.7).
0 upgraded, 0 newly installed, 0 to remove and 20 not upgraded.
Synchronizing state of nginx.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable nginx
--2021-04-27 02:32:39--  https://data.cityofnewyork.us/api/views/833y-fsy8/rows.csv?accessType=DOWNLOAD
Resolving data.cityofnewyork.us (data.cityofnewyork.us)... 52.206.140.199, 52.206.68.26, 52.206.140.205
Connecting to data.cityofnewyork.us (data.cityofnewyork.us)|52.206.140.199|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/csv]
Saving to: ‘sample.csv’

     0K .......... .......... .......... .......... .......... 35.0M
    50K .......... .......... .......... .......... .......... 1.15M
...
  3800K .......... .......... .......... .......... ...         245M=0.9s

2021-04-27 02:32:40 (4.28 MB/s) - ‘sample.csv’ saved [3935678]

8913
6195
3225
2647
646
 --- input ---
ip : 3.91.68.9
private keyp : my.pem
url : https://data.cityofnewyork.us/api/views/833y-fsy8/rows.csv?accessType=DOWNLOAD
column : 4
----------------

uniq.txt                                                            100%   86     0.9KB/s   00:00    
testing ...  curl with 3.91.68.9/BROOKLYN.txt
8913
```


## Footprints:
The script makes minimal changes to a local machine. It creates 3 files on the working directory: hong.sh, start.sh, uniq.txt.
On the remote machine, it create 2 files in the ubuntu home dir: sample.csv uniq.txt and the V.txt files in web root directory.
The "start.sh" is the main script, and others are generated during the install, config, and parsing step:
* start.sh - initially we only need this script
* hong.sh - it is generated by the "start.sh and it's a local script that will be running on remote instance via ssh.
* sample.csv - downloaded csv file.
* uniq.txt - it is created by the "hong.sh". It's a product of csv parsing and it has rows of (count Value) pairs. The V.txt files are generated based on this "uniq.txt". On local machine, it is used to make a curl request (to check the correct web display).

