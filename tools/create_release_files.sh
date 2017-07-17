#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Quick-and-dirty automation of making maven and binary releases. Not robust at all.
# Publishes releases to Maven and packages/copies binary release artifacts.
# Expects to be run in a totally empty directory.
#

#
#  NOTE: The code in this file is based on code from the Apache Spark
#  project, licensed under the Apache License v 2.0
#
#  https://github.com/apache/spark/blob/branch-1.4/dev/create-release/create-release.sh
#

##
#
#   Flink-shaded release script
#   ===================
#
#   Can be called like this:
#
#    sonatype_user=APACHEID sonatype_pw=APACHEIDPASSWORD \
#     RELEASE_CANDIDATE="rc1" RELEASE_BRANCH=release-2.0
#     RELEASE_VERSION=2.0 \
#     USER_NAME=APACHEID \
#     GPG_PASSPHRASE=XXX \
#     GPG_KEY=KEYID \
#     GIT_AUTHOR="`git config --get user.name` <`git config --get user.email`>" \
#     ./create_release_files.sh
#
##


# fail immediately
set -o errexit
set -o nounset
# print command before executing
set -o xtrace

CURR_DIR=`pwd`
if [[ `basename $CURR_DIR` != "tools" ]] ; then
  echo "You have to call the script from the tools/ dir"
  exit 1
fi

##
## Variables with defaults (if not overwritten by environment)
##
GPG_PASSPHRASE=${GPG_PASSPHRASE:-XXX}
GPG_KEY=${GPG_KEY:-XXX}
GIT_AUTHOR=${GIT_AUTHOR:-"Your name <you@apache.org>"}
RELEASE_VERSION=${RELEASE_VERSION:-none}
RELEASE_CANDIDATE=${RELEASE_CANDIDATE:-none}
RELEASE_BRANCH=${RELEASE_BRANCH:-master}
USER_NAME=${USER_NAME:-yourapacheidhere}
MVN=${MVN:-mvn}
GPG=${GPG:-gpg}
sonatype_user=${sonatype_user:-yourapacheidhere}
sonatype_pw=${sonatype_pw:-XXX}
# whether only build the dist local and don't release to apache
IS_LOCAL_DIST=${IS_LOCAL_DIST:-false}
GIT_REPO=${GIT_REPO:-github.com/apache/flink-shaded.git}

if [ "$(uname)" == "Darwin" ]; then
    SHASUM="shasum -a 512"
    MD5SUM="md5 -r"
else
    SHASUM="sha512sum"
    MD5SUM="md5sum"
fi

usage() {
  set +x
  echo "./create_release_files.sh"
  echo ""
  echo "usage:"
  echo ""
  echo "example 1: build apache release"
  echo "  sonatype_user=APACHEID sonatype_pw=APACHEIDPASSWORD \ "
  echo "  RELEASE_VERSION=2.0 RELEASE_CANDIDATE="rc1" RELEASE_BRANCH=release-2.0 \ "
  echo "  USER_NAME=APACHEID GPG_PASSPHRASE=XXX GPG_KEY=KEYID \ "
  echo "  GIT_AUTHOR=\"`git config --get user.name` <`git config --get user.email`>\" \ "
  echo "  GIT_REPO=github.com/apache/flink-shaded.git \ "
  echo "  ./create_release_files.sh"
  echo ""
  echo "example 2: build local release"
  echo "  RELEASE_VERSION=1.2.0 RELEASE_BRANCH=master \ "
  echo "  GPG_PASSPHRASE=XXX GPG_KEY=XXX IS_LOCAL_DIST=true \ "
  echo "  ./create_release_files.sh"

  exit 1
}

# Parse arguments
while (( "$#" )); do
  case $1 in
    --help)
      usage
      ;;
    *)
      break
      ;;
  esac
  shift
done

###########################

prepare() {
  # prepare
  target_branch=release-$RELEASE_VERSION
  if [ "$RELEASE_CANDIDATE" != "none" ]; then
    target_branch=$target_branch-$RELEASE_CANDIDATE
  fi

  if [ -d ./flink-shaded ]; then
    rm -rf flink-shaded
  fi
  git clone http://$GIT_REPO flink-shaded

  cd flink-shaded

  git checkout -b $target_branch origin/$RELEASE_BRANCH
  rm -rf .gitignore .gitattributes .travis.yml deploysettings.xml CHANGELOG .github

  cd ..
}

# create source package
make_source_release() {

  cd flink-shaded

  # local dist have no need to commit to remote
  if [ "$IS_LOCAL_DIST" == "false" ]; then
    git commit --author="$GIT_AUTHOR" -am "Commit for release $RELEASE_VERSION"
    git remote add asf_push https://$USER_NAME@$GIT_REPO
    RELEASE_HASH=`git rev-parse HEAD`
    echo "Echo created release hash $RELEASE_HASH"
  fi

  cd ..

  echo "Creating source package"
  rsync -a --exclude ".git" flink-shaded flink-shaded-$RELEASE_VERSION
  tar czf flink-shaded-${RELEASE_VERSION}-src.tgz flink-shaded-$RELEASE_VERSION
  echo $GPG_PASSPHRASE | $GPG --batch --default-key $GPG_KEY --passphrase-fd 0 --armour --output flink-shaded-$RELEASE_VERSION-src.tgz.asc \
    --detach-sig flink-shaded-$RELEASE_VERSION-src.tgz
  $MD5SUM flink-shaded-$RELEASE_VERSION-src.tgz > flink-shaded-$RELEASE_VERSION-src.tgz.md5
  $SHASUM flink-shaded-$RELEASE_VERSION-src.tgz > flink-shaded-$RELEASE_VERSION-src.tgz.sha
  rm -rf flink-shaded-$RELEASE_VERSION
}

deploy_to_maven() {
  echo "Deploying to repository.apache.org"

  cd flink-shaded
  cp ../../deploysettings.xml .

  $MVN clean deploy -Prelease --settings deploysettings.xml -DskipTests -Dgpg.executable=$GPG -Dgpg.keyname=$GPG_KEY -Dgpg.passphrase=$GPG_PASSPHRASE -DretryFailedDeploymentCount=10

}

copy_data() {
  # Copy data
  echo "Copying release tarballs"
  folder=flink-shaded-$RELEASE_VERSION
  # candidate is not none, append it
  if [ "$RELEASE_CANDIDATE" != "none" ]; then
    folder=$folder-$RELEASE_CANDIDATE
  fi
  sftp $USER_NAME@home.apache.org <<EOF
mkdir public_html/$folder
put flink-*.tgz* public_html/$folder
bye
EOF
  echo "copy done"
}

prepare

make_source_release

if [ "$IS_LOCAL_DIST" == "false" ] ; then
    copy_data
    deploy_to_maven
fi

echo "Done. Don't forget to commit the release version"
