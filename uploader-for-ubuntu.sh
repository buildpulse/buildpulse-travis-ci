#!/bin/sh -l

set -e

# --- This script is deprecated.
# --- Please upgrade to the BuildPulse Test Reporter for a faster experience!
echo "📣👋📰 A faster BuildPulse integration is now available"
echo "📣👋📰"
echo "📣👋📰 Upgrade to the BuildPulse Test Reporter"
echo "📣👋📰"
echo "📣👋📰 See details at https://github.com/Workshop64/buildpulse-travis-ci"
echo

if [ -z "$BUILDPULSE_ACCESS_KEY_ID" ]
then
  echo "🐛 BUILDPULSE_ACCESS_KEY_ID is missing."
  echo "🧰 To resolve this issue, set the BUILDPULSE_ACCESS_KEY_ID environment variable to your BuildPulse access key ID in the Travis CI settings for your repository (https://docs.travis-ci.com/user/environment-variables#defining-variables-in-repository-settings)."
  exit 1
fi

if [ -z "$BUILDPULSE_SECRET_ACCESS_KEY" ]
then
  echo "🐛 BUILDPULSE_SECRET_ACCESS_KEY is missing."
  echo "🧰 To resolve this issue, set the BUILDPULSE_SECRET_ACCESS_KEY environment variable to your BuildPulse secret access key in the Travis CI settings for your repository (https://docs.travis-ci.com/user/environment-variables#defining-variables-in-repository-settings)."
  exit 1
fi

if ! echo $BUILDPULSE_ACCOUNT_ID | egrep -q '^[0-9]+$'
then
  echo "🐛 The given value is not a valid account ID: ${BUILDPULSE_ACCOUNT_ID}"
  echo "🧰 To resolve this issue, set the BUILDPULSE_ACCOUNT_ID environment variable to your numeric BuildPulse Account ID."
  exit 1
fi
ACCOUNT_ID=$BUILDPULSE_ACCOUNT_ID

if ! echo $BUILDPULSE_REPOSITORY_ID | egrep -q '^[0-9]+$'
then
  echo "🐛 The given value is not a valid repository ID: ${BUILDPULSE_REPOSITORY_ID}"
  echo "🧰 To resolve this issue, set the BUILDPULSE_REPOSITORY_ID environment variable to your numeric BuildPulse Repository ID."
  exit 1
fi
REPOSITORY_ID=$BUILDPULSE_REPOSITORY_ID

if [ ! -d "$BUILDPULSE_REPORT_PATH" ]
then
  echo "🐛 The given path is not a directory: ${BUILDPULSE_REPORT_PATH}"
  echo "🧰 To resolve this issue, set the BUILDPULSE_REPORT_PATH environment variable to the directory that contains your test report(s)."
  exit 1
fi
REPORT_PATH="${BUILDPULSE_REPORT_PATH}"

METADATA_PATH=${REPORT_PATH}/buildpulse.yml
TIMESTAMP=$(date -Iseconds)
UUID=$(cat /proc/sys/kernel/random/uuid)
cat << EOF > "$METADATA_PATH"
---
:branch: $TRAVIS_BRANCH
:build_url: $TRAVIS_JOB_WEB_URL
:check: ${BUILDPULSE_CHECK_NAME:-travis-ci}
:ci_provider: travis-ci
:commit: $TRAVIS_COMMIT
:job: $TRAVIS_JOB_NAME
:repo_name_with_owner: $TRAVIS_REPO_SLUG
:timestamp: '$TIMESTAMP'
:travis_build_dir: $TRAVIS_BUILD_DIR
:travis_build_id: $TRAVIS_BUILD_ID
:travis_build_number: $TRAVIS_BUILD_NUMBER
:travis_build_web_url: $TRAVIS_BUILD_WEB_URL
:travis_commit_range: $TRAVIS_COMMIT_RANGE
:travis_compiler: $TRAVIS_COMPILER
:travis_cpu_arch: $TRAVIS_CPU_ARCH
:travis_debug_mode: $TRAVIS_DEBUG_MODE
:travis_dist: $TRAVIS_DIST
:travis_event_type: $TRAVIS_EVENT_TYPE
:travis_job_id: $TRAVIS_JOB_ID
:travis_job_number: $TRAVIS_JOB_NUMBER
:travis_os_name: $TRAVIS_OS_NAME
:travis_osx_image: $TRAVIS_OSX_IMAGE
:travis_pull_request_branch: $TRAVIS_PULL_REQUEST_BRANCH
:travis_pull_request_sha: $TRAVIS_PULL_REQUEST_SHA
:travis_pull_request_slug: $TRAVIS_PULL_REQUEST_SLUG
:travis_pull_request: $TRAVIS_PULL_REQUEST
:travis_sudo: $TRAVIS_SUDO
:travis_tag: $TRAVIS_TAG
:travis_test_result: $TRAVIS_TEST_RESULT
EOF

ARCHIVE_PATH=/tmp/buildpulse-${UUID}.gz
tar -zcf "${ARCHIVE_PATH}" "${REPORT_PATH}"
S3_URL=s3://$ACCOUNT_ID.buildpulse-uploads/$REPOSITORY_ID/

sudo apt-get -qq update
sudo apt-get -qq install awscli > /dev/null

AWS_ACCESS_KEY_ID="${BUILDPULSE_ACCESS_KEY_ID}" \
  AWS_SECRET_ACCESS_KEY="${BUILDPULSE_SECRET_ACCESS_KEY}" \
  AWS_DEFAULT_REGION=us-east-2 \
  aws s3 cp "${ARCHIVE_PATH}" "${S3_URL}"
