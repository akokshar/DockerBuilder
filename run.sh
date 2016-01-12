#!/bin/bash
set -o pipefail

echo "*** Builder Enviroment ***"
env
echo "*** ------------------ ***"

if [ ! -e "/var/run/docker.sock" ]; then
	echo "Docker socket error. Use 'exposeDockerSocket' option of a 'CustomBuildStrategy' to set it"
	exit 1
fi

if [ -z "${OUTPUT_IMAGE}" ]; then
	echo "Output image name is not defined. Use 'OUTPUT_IMAGE' enviroment variable"
	exit 1
fi

TAG="${OUTPUT_REGISTRY}/${OUTPUT_IMAGE}"

if [[ -z "${SOURCE_SSH_REPOSITORY}" ]]; then
	echo "Source ssh repository is no set. Use 'SOURCE_SSH_REPOSITORY' enviroment variables"
	echo "format user@host:/path"
	exit 1
fi

if [ -z "${SOURCE_SSH_RIVATE_KEY}" ]; then
	echo "SSH identity for '${SOURCE_SSH_REPOSITORY}' is not defined . Use 'SOURCE_SSH_RIVATE_KEY' enviroment variables"
	exit 1
fi

BUILD_DIR=$(mktemp --directory --suffix=docker-build)

IDENTITY=$(mktemp --suffix=builder_id)
printenv SOURCE_SSH_RIVATE_KEY > ${IDENTITY}

echo "itentyty file content:"
cat ${IDENTITY}

echo "Copying sources from '"${SOURCE_SSH_REPOSITORY}"'to '"${BUILD_DIR}"'"
scp -o "StrictHostKeyChecking no" -i ${IDENTITY} -r ${SOURCE_SSH_REPOSITORY}/* ${BUILD_DIR}

echo "list of copied files:"
ls -la ${BUILD_DIR}

echo "building image..."

docker build --rm -t "${TAG}" "${BUILD_DIR}"

if [[ -d /var/run/secrets/openshift.io/push ]] && [[ ! -e /root/.dockercfg ]]; then
	cp /var/run/secrets/openshift.io/push/.dockercfg /root/.dockercfg
fi

if [ -n "${OUTPUT_IMAGE}" ] || [ -s "/root/.dockercfg" ]; then
	docker push "${TAG}"
fi

exit 0
