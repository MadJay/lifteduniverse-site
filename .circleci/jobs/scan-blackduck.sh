. ./.circleci/helpers/bash-tools.sh

# ---------------------------------------------------------------------------
headerline "scan-blackduck.sh"
# ---------------------------------------------------------------------------
. ./.circleci/helpers/debundle-context.sh
. ./.circleci/helpers/docker_registry_login.sh
# ---------------------------------------------------------------------------
headerline "CIRCLE_TAG=${CIRCLE_TAG}"
# ---------------------------------------------------------------------------

component=`echo "${CIRCLE_TAG}" | cut -d/ -f2`
stage=`echo   "${CIRCLE_TAG}" | cut -d/ -f3`

# ---------------------------------------------------------------------------
headerline "Build Parameters"
# ---------------------------------------------------------------------------

echo "|> CIRCLE_TAG     : ${CIRCLE_TAG}"
echo "|> component      : ${component}"
echo "|> stage          : ${stage}"
echo "|> SCANNER_IMAGE  : ${SCANNER_IMAGE}"
echo


component=${component} \
stage=${stage} \
scanner_image=${SCANNER_IMAGE} \
blackduck_access_token=${BLACKDUCK_ACCESS_TOKEN} \
DEBUG=${DEBUG} \
/bin/bash .circleci/helpers/blackduck-configure-and-scan.sh



exit_code=$?
if [[ "${exit_code}" -ne 0 ]]; then
	echo "build command exit code was non zero: ${exit_code}"
	exit 1
fi
