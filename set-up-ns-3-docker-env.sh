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
#   - add current user to it
###################################
# more details at: https://docs.docker.com/install/linux/linux-postinstall/

groupadd docker 
service docker restart
usermod -a -G docker $1

###################################
# Step 3:
#   - pull my ns-3.26 docker image
###################################

my_ns_3_26_docker_image="hamelik/ns3.26libdependencies:first"
docker pull ${my_ns_3_26_docker_image}

#########################################
# Step 4:
#   - get the ns-all-in-one-3.26 project
#########################################

ns_allinone_3_26_project="ns-allinone-3.26"
wget http://www.nsnam.org/release/${ns_allinone_3_26_project}.tar.bz2 -P . && tar xjf ${ns_allinone_3_26_project}.tar.bz2

chown -R $1: ${ns_allinone_3_26_project} && chmod -R u+rwx ${ns_allinone_3_26_project}
su - $1
