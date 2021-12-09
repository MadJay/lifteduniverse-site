. ./.circleci/helpers/bash-tools.sh

# ---------------------------------------------------------------------------
headerline "scan-coverity.sh"
# ---------------------------------------------------------------------------
. ./.circleci/helpers/debundle-context.sh
. ./.circleci/helpers/docker_registry_login.sh
# ---------------------------------------------------------------------------
headerline "CIRCLE_TAG=${CIRCLE_TAG}"
# ---------------------------------------------------------------------------

component=`echo "${CIRCLE_TAG}" | cut -d/ -f2`
stage=`echo   "${CIRCLE_TAG}" | cut -d/ -f3`
version=`echo   "${CIRCLE_TAG}" | cut -d/ -f4`
# ---------------------------------------------------------------------------
headerline "Build Parameters"
# ---------------------------------------------------------------------------

echo "|> CIRCLE_TAG     : ${CIRCLE_TAG}"
echo "|> component      : ${component}"
echo "|> stage          : ${stage}"
echo "|> version        : ${version}"
echo "|> SCANNER_IMAGE  : ${SCANNER_IMAGE}"
echo

# When debug is enabled, send scan data to dev environment
if [[ ${DEBUG} == "on" ]]; then
	CONNECT_HOST="connect-platform-wowza-coverity-dev.util-a.wowza.com"
	CONNECT_DATAPORT="9091"
else
	CONNECT_HOST="connect-platform-wowza-coverity-prod.util-a.wowza.com"
	CONNECT_DATAPORT="9090"
fi

component=${component} \
stage=${stage} \
version=${version} \
scanner_image=${SCANNER_IMAGE} \
CONNECT_HOST=${CONNECT_HOST} \
CONNECT_DATAPORT=${CONNECT_DATAPORT} \
DEBUG=${DEBUG} \
/bin/bash .circleci/helpers/coverity-configure-and-scan.sh

exit_code=$?
if [[ "${exit_code}" -ne 0 ]]; then
	echo "build command exit code was non zero: ${exit_code}"
	exit 1
fi
