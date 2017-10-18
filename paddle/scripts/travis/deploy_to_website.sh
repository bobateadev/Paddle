#!/bin/bash
set -e

echo "DEPLOYING TO WEBSITE"
echo "Branch: $TRAVIS_BRANCH"

# deploy to remote server
openssl aes-256-cbc -d -a -in $TRAVIS_BUILD_DIR/paddle/scripts/travis/ubuntu.pem.enc -out $TRAVIS_BUILD_DIR/ubuntu.pem -k $DEC_PASSWD

eval "$(ssh-agent -s)"
chmod 400 $TRAVIS_BUILD_DIR/ubuntu.pem

ssh-add $TRAVIS_BUILD_DIR/ubuntu.pem

if [ "$TRAVIS_BRANCH" != "build_docs_ci_thuan" ]; then
	return
fi

echo "------------- $TRAVIS_BUILD_DIR"
ls $TRAVIS_BUILD_DIR
echo "------------- $TRAVIS_BUILD_DIR/build"
ls $TRAVIS_BUILD_DIR/build
echo "------------- $TRAVIS_BUILD_DIR/build/doc"
ls $TRAVIS_BUILD_DIR/build/doc

mkdir -p $TRAVIS_BUILD_DIR/build_docs_versioned/$TRAVIS_BRANCH
cp -r $TRAVIS_BUILD_DIR/build/doc/en/html $TRAVIS_BUILD_DIR/build_docs_versioned/$TRAVIS_BRANCH/en
cp -r $TRAVIS_BUILD_DIR/build/doc/cn/html $TRAVIS_BUILD_DIR/build_docs_versioned/$TRAVIS_BRANCH/cn

rsync -r $TRAVIS_BUILD_DIR/build_docs_versioned/ ubuntu@52.76.173.135:/var/content/documentation/

chmod 644 $TRAVIS_BUILD_DIR/ubuntu.pem
rm $TRAVIS_BUILD_DIR/ubuntu.pem
