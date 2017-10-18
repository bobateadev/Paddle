#!/bin/bash
set -e

echo "DEPLOYING TO WEBSITE"
echo "Branch: $TRAVIS_BRANCH"

# deploy to remote server
openssl aes-256-cbc -d -a -in $TRAVIS_BUILD_DIR/paddle/scripts/travis/ubuntu.pem.enc -out $TRAVIS_BUILD_DIR/ubuntu.pem -k $DEC_PASSWD

eval "$(ssh-agent -s)"
chmod 400 $TRAVIS_BUILD_DIR/ubuntu.pem

ssh-add $TRAVIS_BUILD_DIR/ubuntu.pem

echo "------------- $TRAVIS_BUILD_DIR"
ls $TRAVIS_BUILD_DIR
echo "------------- $TRAVIS_BUILD_DIR/build"
ls $TRAVIS_BUILD_DIR/build
echo "------------- $TRAVIS_BUILD_DIR/build/doc"
ls $TRAVIS_BUILD_DIR/build/doc

mkdir -p $TRAVIS_BUILD_DIR/build_docs_versioned/$TRAVIS_BRANCH
cp -r $TRAVIS_BUILD_DIR/build/doc/en/html $TRAVIS_BUILD_DIR/build_docs_versioned/$TRAVIS_BRANCH/en
cp -r $TRAVIS_BUILD_DIR/build/doc/cn/html $TRAVIS_BUILD_DIR/build_docs_versioned/$TRAVIS_BRANCH/cn

# pull PaddlePaddle.org app and strip
# https://github.com/PaddlePaddle/PaddlePaddle.org/archive/master.zip
cd $TRAVIS_BUILD_DIR

curl -LOk https://github.com/PaddlePaddle/PaddlePaddle.org/archive/master.zip
unzip master.zip
cd PaddlePaddle.org-master/
cd portal/

sudo pip install -r requirements.txt

if [ -d ./stripped_doc ]
then
    rm -rf ./stripped_doc
fi
mkdir ./stripped_doc

python manage.py deploy_documentation $TRAVIS_BUILD_DIR/build_docs_versioned/$TRAVIS_BRANCH $TRAVIS_BRANCH ./stripped_doc documentation

# debug purpose, show stripped_doc
# rsync -r ./stripped_doc ubuntu@52.76.173.135:/tmp

cd $TRAVIS_BUILD_DIR

echo "------------- rsync -r ..."
pwd
ls
ls PaddlePaddle.org-master/portal/stripped_doc/
rsync -r PaddlePaddle.org-master/portal/stripped_doc/ ubuntu@52.76.173.135:/var/content/docs

chmod 644 $TRAVIS_BUILD_DIR/ubuntu.pem
rm $TRAVIS_BUILD_DIR/ubuntu.pem
