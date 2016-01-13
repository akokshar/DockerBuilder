Cusotm builder image. (derived from https://github.com/openshift/origin/tree/master/images/builder/docker/custom-docker-builder)
Downloads your docker project by ssh, builds and push resulting image to Openshift docker-registry.

1. Build builder

- clone and build image
  git clone 
  cd DockerBuilder
  docker build -t builderdockerssh .

- push resulting image to Openshift registry following procedure at https://access.redhat.com/solutions/2072843. (Use namespace 'openshift' to make builder image accessible for any project)
  docker tag builderdockerssh REGISTRY_IP:PORT/openshift/builderdockerssh
  docker push REGISTRY_IP:PORT/openshift/builderdockerssh

- generate key pair and copy public key to your ssh server
  ssh-keygen -f builder_id
  ssh-copy-id -i builder_id.pub root@master.ose3.test

2. Test builder

- create necessary ImageStream and BuildConfig entities
  oc process -f bc_sample.json -v SOURCE_SSH_REPOSITORY="root@master:/root/<path to project>",SOURCE_SSH_RIVATE_KEY="$(cat builder_id)" | oc create -f -

- build your project 
  oc start-build dockerbuildertest --follow 
