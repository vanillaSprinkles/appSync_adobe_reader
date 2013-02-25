#!/bin/bash


DESTINATION_PATH="/tmp/adobe/reader"

mkdir -p ${DESTINATION_PATH}
if ! [ -d ${DESTINATION_PATH} ] && ! [ -w ${DESTINATION_PATH} ]; then
    echo "cannot write to ${DESTIONATION_PATH}; premature exit"
    exit
fi

echo "yay"
exit

AGENT="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:18.0) Gecko/20100101 Firefox/18.0"
#URL="http://get.adobe.com/reader/webservices/json/standalone/?platform_type=Windows&platform_dist=Windows%207&platform_arch=&language=English&eventname=readerotherversions"
REFERER="http://get.adobe.com/reader/enterprise/"
COOKIE="READER_HTTPREFERER=; READER_NEW_USER=true;"


DLFILE=adobe_urls.grepme

# --header "Accept-Language: en-US,en;q=0.5" --header "Accept-Encoding: gzip, deflate" 

#_# wget --user-agent="${AGENT}" --referer=${REFERER}  --header "X-Requested-With: XMLHttpRequest"  --header "Cookie: ${COOKIE}"  ${URL} -O ${DLFILE} 2>/dev/null

#_# sed 's/"/\n/g' adobe_urls.grepme  | grep -Eo "http.*\.exe" | sed 's/\\//g'

#### MAC HEADER
#Accept-Encoding: gzip,deflate,sdch
#Accept-Language: en-US,en;q=0.8
#Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3
####


URL=()

# Win 8
URL+=("http://get.adobe.com/reader/webservices/json/standalone/?platform_type=Windows&platform_dist=Windows%208&platform_arch=&language=English&eventname=readerotherversions")
# Win 7
URL+=("http://get.adobe.com/reader/webservices/json/standalone/?platform_type=Windows&platform_dist=Windows%207&platform_arch=&language=English&eventname=readerotherversions")
# Mac 10.8
URL+=("http://get.adobe.com/reader/webservices/json/standalone/?platform_type=Macintosh&platform_dist=OSX&platform_arch=x86-32&platform_misc=10.8.0&language=English&eventname=readerotherversions")
# Mac 10.7.2 - 10.7.5
URL+=("http://get.adobe.com/reader/webservices/json/standalone/?platform_type=Macintosh&platform_dist=OSX&platform_arch=x86-32&platform_misc=10.7.5&language=English&eventname=readerotherversions")
# Mac 10.7   - 10.7.1
URL+=("http://get.adobe.com/reader/webservices/json/standalone/?platform_type=Macintosh&platform_dist=OSX&platform_arch=x86-32&platform_misc=10.7.1&language=English&eventname=readerotherversions")
# Mac 10.6.4 - 10.6.8
URL+=("http://get.adobe.com/reader/webservices/json/standalone/?platform_type=Macintosh&platform_dist=OSX&platform_arch=x86-32&platform_misc=10.6.8&language=English&eventname=readerotherversions")
# Mac 10.6   - 10.6.3
URL+=("http://get.adobe.com/reader/webservices/json/standalone/?platform_type=Macintosh&platform_dist=OSX&platform_arch=x86-32&platform_misc=10.6.3&language=English&eventname=readerotherversions")

DEBUG=0
rm -f /tmp/adobe_Murls 2>&1 1>/dev/null
rm -f /tmp/adobe_Wurls 2>&1 1>/dev/null
for vURL in ${URL[@]}; do
  rm -f ${DLFILE}
  if [[ $DEBUG -eq 1 ]]; then
    echo ${vURL}
  else
    wget --quiet -q  --user-agent="${AGENT}" --referer=${REFERER}  --header "X-Requested-With: XMLHttpRequest"  --header "Cookie: ${COOKIE}"  ${vURL} -O ${DLFILE}  2>/dev/null
    sed 's/"/\n/g' ${DLFILE}  | grep -Eo "http.*\.exe" | sed 's/\\//g' >> /tmp/adobe_Wurls
    sed 's/"/\n/g' ${DLFILE}  | grep -Eo "http.*\.dmg" | sed 's/\\//g' >> /tmp/adobe_Murls
  fi
done
rm -f ${DLFILE}


if [[ $DEBUG -eq 1 ]]; then
  sort -ur /tmp/adobe_Wurls
  sort -ur /tmp/adobe_Murls
else
  Wurls=$(sort -ur /tmp/adobe_Wurls)
  Murls=$(sort -ur /tmp/adobe_Murls)
fi
rm -f /tmp/adobe_Murls 2>&1 1>/dev/null
rm -f /tmp/adobe_Wurls 2>&1 1>/dev/null


for URL in ${Wurls[@]} ${Murls[@]}; do
    file=${URL//*en_US\/}
    OS=${URL//*\/win\/*/win}
    [[ ${#OS} -gt 3 ]] && OS=${URL//*\/mac\/*/mac}
    bVerT=${URL/#*${OS}\/}
    bVer=${bVerT//.x*/.x}

# WGET 
# sha1
# URL
    mkdir -p new_files
    echo -e "${file} ${URL}"  >  "new_files/${OS}_${bVer}.txt"
	
#    verT=${URL//*reader/}
#    ver
#    wget ${URL}
done
