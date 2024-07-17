#!/bin/bash
sudo cp /etc/sysctl.conf /root/etc/systemctl.conf_backup
sudo cat' <<EOF> /etc/sysctl.conf
   vm.max_map_count=262144
   fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
      
EOF'

sudo cp /etc/security/limits.conf /root/sec_limit.conf_backup
sudo cat' <<EOF> /etc/security/limits.conf
sonarqube   -   nofile   65536
sonarqube   -   nproc    4096
EOF'

sudo apt-get update -y
sudo apt install zip -y


#java installation
sudo apt install -y openjdk-17-jdk


#sonarqube installation
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip
sudo unzip sonarqube-10.0.0.68432.zip
sudo mv sonarqube-10.0.0.68432 /opt/
sudo mv /opt/sonarqube-10.0.0.68432 /opt/sonarqube


#sudo useradd sonar
#sudo groupadd sonar
 sudo groupadd sonar
#sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown -R sonar:sonar /opt/sonarqube
sudo cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup
sudo sh -c cat' <<EOF> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost:5432/dbsonarqube
sonar.web.host=0.0.0.0
 sonar.web.port=9000
 sonar.web.javaAdditionalOpts=-server
 sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
 sonar.log.level=INFO
 sonar.path.logs=logs
EOF'

sudo sh -c cat' <<EOF> /bin/linux-x86-64/sonar.sh
RUN_AS_USER=sonar
EOF'

#setup systemd service for sonarqube
sudo sh -c cat' <<EOF> /etc/systemd/system/sonar.service
[Unit]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable sonar
sudo systemctl start sonar
sudo systemctl status sonar
