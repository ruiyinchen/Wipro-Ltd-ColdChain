#! /bin/bash

dburl1=$1
dbusername1=$2
dbpassword1=$3
dbname1=$4
dnsname=$5
githuburl1=$6
storageurl1=$7
sastoken1=$8
dataxml=$9
gitusername1=${10}
gitpassword1=${11}

#Removing spaces from the variables

dburl=`echo $dburl1 | tr -d " "` 
dbusername=`echo $dbusername1 | tr -d " "` 
dbpassword=`echo $dbpassword1 | tr -d " "`
dbname=`echo $dbname1 | tr -d " "`
githuburl=`echo $githuburl1 | tr -d " "` 
gitusername=`echo $gitusername1 | tr -d " "` 
gitpassword=`echo $gitpassword1 | tr -d " "`
storageurl=`echo $storageurl1 | tr -d " "`
sastoken=`echo $sastoken1 | tr -d " "`

sudo curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh

sudo bash nodesource_setup.sh
sudo apt-get update
sudo apt-get install nodejs -y
sudo npm install forever -g

tmtip=`getent hosts ${dnsname} | awk '{ print $1 }'`

#how ot download a private github repository into the local directory.

#If you are downloading a private repository use the below command and provide the github login credentials and make sure that the password doen't contain any special symbols.

gurl=`echo "$githuburl" | cut -d '/' -f3-5`
giturl="https://${gitusername}:${gitpassword}@${gurl}"
sudo git clone ${giturl}

# If it is a Public repo follow the below command ot download the repository

#sudo git clone $githuburl

dir=`echo "$gurl" | cut -d '/' -f3 | cut -d '.' -f1`
echo "directory url is $dir"

cd "$dir"/cctitan-cron-job-vm/tcp

sudo sed -i "s/.TitanAdmin./\'$dbusername\' /" application_config.js
sudo sed -i "s/.Titan123./\'$dbpassword\' /" application_config.js
sudo sed -i "s/.titanserver.database.windows.net./\'$dburl\' /" application_config.js
sudo sed -i "s/.40.76.42.243./\'$tmtip\' /" application_config.js
sudo sed -i "s/.TitanDB./\'$dbname\' /" application_config.js

sudo nohup forever start server.js

cd ..

cd sp_alert_process

sudo sed -i "s/.TitanAdmin./\'$dbusername\' /" config.js
sudo sed -i "s/.Titan123./\'$dbpassword\' /" config.js
sudo sed -i "s/.titanserver.database.windows.net./\'$dburl\' /" config.js
sudo sed -i "s/.TitanDB./\'$dbname\' /" config.js

sudo nohup forever start sp_alert_process.js

cd ..

cd cold_chain_blockchain

sudo sed -i "s/.TitanAdmin./\'$dbusername\' /" config.js
sudo sed -i "s/.Titan123./\'$dbpassword\' /" config.js
sudo sed -i "s/.titanserver.database.windows.net./\'$dburl\' /" config.js
sudo sed -i "s/.TitanDB./\'$dbname\' /" config.js

sudo nohup forever start app.js

cd ..

#================================================================================
#The followin logic will add teh CORS to the Specified Storage account 
#================================================================================

echo "Adding CORS to the storage account using CURL command"

sudo wget ${dataxml}
sudo mv data.xml?token* data.xml
url="${storageurl}/?restype=service&comp=properties&${sastoken}"
curl --request PUT --url ${url} --header 'Content-Type: application/xml' --data @data.xml

echo "succesfully added CORS to the storage account"

#===============================================================================================
#Updating the sql database with test user

# Password for the SA user (required)

MSSQL_SA_PASSWORD=`echo $dbpassword`
echo Adding Microsoft SQL Server
sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list)"
sudo apt-get update
sudo apt-get install -y mssql-server
MSSQL_PID='express'

# Install SQL Server Agent (recommended)

SQL_INSTALL_AGENT='y'
if [ -z $MSSQL_SA_PASSWORD ]
then
  echo Environment variable MSSQL_SA_PASSWORD must be set for unattended install
  exit 1
fi
echo Adding Microsoft repositories...
sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
repoargs="$(curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list)"
sudo add-apt-repository "${repoargs}"
repoargs="$(curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list)"
sudo add-apt-repository "${repoargs}"
echo Running apt-get update -y...
sudo apt-get update -y
echo Installing SQL Server...
sudo apt-get install -y mssql-server
echo Running mssql-conf setup...
sudo MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD \
     MSSQL_PID=$MSSQL_PID \
     /opt/mssql/bin/mssql-conf -n setup accept-eula
echo Installing mssql-tools and unixODBC developer...
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

# Add SQL Server tools to the path by default:

echo Adding SQL Server tools to your path...
echo PATH="$PATH:/opt/mssql-tools/bin" >> /home/$USER/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /home/$USER/.bashrc
#source /home/$USER/.bashrc

# Configure firewall to allow TCP port 1433:

echo Configuring UFW to allow traffic on port 1433...
sudo ufw allow 1433/tcp
sudo ufw reload

# Restart SQL Server after installing:

echo Restarting SQL Server...
sudo systemctl restart mssql-server

# Connect to server and get the version:

cd /opt/mssql-tools/bin/

sqlvar1=`./sqlcmd -S $dburl -U $dbusername -P $MSSQL_SA_PASSWORD -d $dbname -Q "select count(*) from UserRole_Mapping"`
  
sqlvar=`echo $sqlvar1 | cut -d ' ' -f2`

if [ $sqlvar -eq 0 ]
then
./sqlcmd -S $dburl -U $dbusername -P $MSSQL_SA_PASSWORD -d $dbname -Q "INSERT INTO UserRole_Mapping VALUES ('pradeepts', 'pradeepts@sysgain.com', 'Administrator', 'Active', 'test', NULL, 'NULL', NULL)"
else
echo "user already existed"
fi