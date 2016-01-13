git clone 
cd DockerBuilder
docker build -t builderdockerssh .

push resulting image to Openshift registry following procedure at https://access.redhat.com/solutions/2072843. 
docker tag builderdockerssh REGISTRY_IP:PORT/openshift/builderdockerssh
docker push REGISTRY_IP:PORT/openshift/builderdockerssh

generate key pair and copy public key to your ssh server
ssh-keygen -f builder_id
ssh-copy-id -i builder_id.pub root@master.ose3.test

test

create necessary ImageStream and BuildConfig entities
oc process -f bc_sample.json -v SOURCE_SSH_REPOSITORY="root@master:/root/<path to project>",SOURCE_SSH_RIVATE_KEY="$(cat builder_id)" | oc create -f -

oc start-build dockerbuildertest --follow 
