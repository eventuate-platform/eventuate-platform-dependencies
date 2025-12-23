#! /bin/bash -e

VERSION=$(date '+%Y%m%d%H%M%S')
DEPLOY_DIR=$(pwd)/build/test-deploy

./gradlew --parallel -P version=$VERSION -P deployUrl=file://$DEPLOY_DIR publish

./gradlew --parallel -P version=$VERSION -P eventuateMavenRepoUrl=file://$DEPLOY_DIR,https://snapshots.repositories.eventuate.io/repository --build-file test-example/build.gradle assemble