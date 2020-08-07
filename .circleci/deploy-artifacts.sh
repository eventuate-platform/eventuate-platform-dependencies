#! /bin/bash -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [  $BRANCH == "master" ] ; then
  BUILD_SNAPSHOT=$(grep '<version>' pom.xml  | head -1 | sed -e 's/.*<version>//' -e 's/<.*//' -e 's/-SNAPSHOT/.BUILD-SNAPSHOT/')

  export AWS_ACCESS_KEY_ID=${S3_REPO_AWS_ACCESS_KEY?}
  export AWS_SECRET_ACCESS_KEY=${S3_REPO_AWS_SECRET_ACCESS_KEY?}

  echo master: publishing $BUILD_SNAPSHOT
  ./mvnw versions:set -D newVersion=$BUILD_SNAPSHOT
  ./mvnw deploy -D deploy.repo=${S3_REPO_DEPLOY_URL?}
  exit 0
fi

if ! [[  $BRANCH =~ ^[0-9]+ ]] ; then
  echo Not release $BRANCH - no PUSH
  exit 0
elif [[  $BRANCH =~ RELEASE$ ]] ; then
  BINTRAY_REPO_TYPE=release
elif [[  $BRANCH =~ M[0-9]+$ ]] ; then
    BINTRAY_REPO_TYPE=milestone
elif [[  $BRANCH =~ RC[0-9]+$ ]] ; then
    BINTRAY_REPO_TYPE=rc
else
  echo cannot figure out bintray for this branch $BRANCH
  exit -1
fi

echo BINTRAY_REPO_TYPE=${BINTRAY_REPO_TYPE}

VERSION=$BRANCH

echo Implement me

exit 99
