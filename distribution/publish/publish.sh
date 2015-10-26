#!/bin/bash
# start this script by a Hudson shell script:

# chmod u+x ./distribution/publish/publish.sh
# ./distribution/publish/publish.sh

# TODO: cleanup SNAPSHOT builds if more >50, older >30 days

# enable for "debugging" of script
# set -x

version=`cat version.txt`
echo "VERSION=$version"
if [[ "$version" == *"SNAPSHOT"* ]] ; then
  BUILD_TYPE=snapshots
else
  BUILD_TYPE=releases
fi
echo "BUILD_TYPE=$BUILD_TYPE"
UPLOAD_BASE=/home/data/httpd/download.eclipse.org/concierge
UPLOAD_LOCATION=$UPLOAD_BASE/$BUILD_TYPE
PUBLISH_LOG=$UPLOAD_BASE/publish.log
echo "UPLOAD_LOCATION=$UPLOAD_LOCATION"
echo "PUBLISH_LOG=$PUBLISH_LOG"

# get the version of this build
buildVersion=`(cd ./distribution/build/distributions/ ; ls *.tar.gz) | sed -e 's/\.tar\.gz//g'`
echo "buildVersion=$buildVersion"

(
# current time in UTC with Timezone information
now=`date -u '+%Y-%m-%d %H:%M:%S %Z'`
echo "$now: publishing last successful build for $$buildVersion"

# copy latest build artifacts (tar.gz, zip)
echo cp "./distribution/build/distributions/$buildVersion".tar.gz $UPLOAD_LOCATION
cp "./distribution/build/distributions/$buildVersion".tar.gz $UPLOAD_LOCATION
echo cp "./distribution/build/distributions/$buildVersion".zip $UPLOAD_LOCATION
cp "./distribution/build/distributions/$buildVersion".zip $UPLOAD_LOCATION

# now link latest snapshot to this build
if [ "$BUILD_TYPE" == "snapshots" ] ; then
  echo "Link latest snapshot to $buildVersion"
  (
    cd $UPLOAD_LOCATION
    for f in concierge-incubation-SNAPSHOT-latest.tar.gz concierge-incubation-SNAPSHOT-latest.zip ; do
      if [ -f $f ] ; then rm $f ; fi
    done
    # copy files, sym links does not work when downloading files
    echo cp "$buildVersion".tar.gz concierge-incubation-SNAPSHOT-latest.tar.gz
    cp "$buildVersion".tar.gz concierge-incubation-SNAPSHOT-latest.tar.gz
    echo cp "$buildVersion".zip concierge-incubation-SNAPSHOT-latest.zip
    cp "$buildVersion".zip concierge-incubation-SNAPSHOT-latest.zip
  )
fi

echo " "

) | tee >>$PUBLISH_LOG

echo "See http://download.eclipse.org/concierge/$BUILD_TYPE/?d for uploaded files..."

# cleanup
rm /home/data/httpd/download.eclipse.org/concierge/publish.log
