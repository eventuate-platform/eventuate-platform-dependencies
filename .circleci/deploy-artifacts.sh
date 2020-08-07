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


cat > ~/.m2/settings.xml <<END
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                          https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <servers>
      <server>
        <id>bintray-eventuate-maven-release</id>
        <username>\${bintray.userId}</username>
        <password>\${bintray.apiKey}</password>
      </server>
    </servers>
</settings>
END

./mvnw versions:set -D newVersion=$VERSION
./mvnw deploy -Dbintray.userId=${BINTRAY_USER?} -Dbintray.apiKey=${BINTRAY_KEY?}
