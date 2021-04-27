#!/bin/bash

# bash version 5.1.4  

# args
# 1. IP address of the fresh AWS instance, currently running
# 2. the name of a file containing the instance’s private SSH key
# 3. the URL of a public comma-separated values (CSV) file
# 4. the column number of the CSV to analyze

# run sample
#  ./start.sh ipaddr pkey url column
#  ./start.sh 3.91.68.9 einsteinish.pem https://data.cityofnewyork.us/api/views/833y-fsy8/rows.csv?accessType=DOWNLOAD 4

ipaddr=$1
pkey=$2
url=$3
column=$4

# local script that will be running on remote instance
MY_SCRIPT=hong.sh

# create the local script
cat <<EOF > $MY_SCRIPT
#!/bin/bash

# update and install nginx
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl reload nginx
sudo systemctl enable nginx

# csv parse and creates V.txt files
CSV_FILE=sample.csv
wget $url -O \$CSV_FILE
awk -v col=$column -F ',' '{if (NR>1) print \$col}' \$CSV_FILE | sort | uniq -c | sort -nr > uniq.txt

WEB_ROOT=/var/www/html
while IFS=" " read -r count V remainder
do
  echo \$count | sudo tee \$WEB_ROOT/\$V.txt
done < "uniq.txt"
EOF

# remote run a local script that's just created
chmod +x $MY_SCRIPT
ssh -i ~/.ssh/$pkey ubuntu@$ipaddr 'bash -s' < $MY_SCRIPT $url $column

echo " --- input args ---"
echo "ip : $ipaddr"
echo "private keyp : $pkey"
echo "url : $url"
echo "column : $column"
echo "----------------"
echo

# copy the file (count Value) from remote to local
scp -i ~/.ssh/einsteinish.pem ubuntu@$ipaddr:uniq.txt .

# testing the display with the 1st row data
name=`awk 'NR==1{print $2}' uniq.txt`
echo "testing ...  curl with $ipaddr/$name.txt"
curl $ipaddr/$name.txt
