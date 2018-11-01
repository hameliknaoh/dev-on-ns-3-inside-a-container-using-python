###################################
# Step 1
#   - update sys
#   - install docker
###################################

#!$SHELL
apt update 
apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt update 
apt install docker-ce 

###################################
# Step 2:
#   - create docker group
#   - add current uset it
###################################
# more details at: https://docs.docker.com/install/linux/linux-postinstall/

groupadd docker 
service docker restart
usermod -a -G docker $1

###################################
# Step 3:
#   - pull my ns-3 docker image
###################################
docker pull hamelik/ns3.26libdependencies:first
su - $1
