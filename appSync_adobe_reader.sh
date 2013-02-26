#!/bin/bash

## software repo dir
repo="_srepo"

# optional # repo-checksum sub-folder name
repoChk="checksums"



# Working Directory
TWDIR="/tmp/appSync_adobe_reader"

mkdir -p ${TWDIR}
if ! [ -d ${TWDIR} ] || ! [ -w ${TWDIR} ]; then
    echo "cannot write to ${TWDIR}; premature exit"
    exit
fi



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
rm -f  ${TWDIR}/adobe_Murls  ${TWDIR}/adobe_Wurls  2>&1 1>/dev/null
for vURL in ${URL[@]}; do
  rm -f ${DLFILE}
  if [[ $DEBUG -eq 1 ]]; then
    echo ${vURL}
  else
    ## sends the json-style html packet to server for to get a list of each version's Binary Url; listed in  adobe_Xurls  [Mac and Windows urls]
    wget --quiet -q  --user-agent="${AGENT}" --referer=${REFERER}  --header "X-Requested-With: XMLHttpRequest"  --header "Cookie: ${COOKIE}"  ${vURL} -O ${DLFILE}  2>/dev/null
    sed 's/"/\n/g' ${DLFILE}  | grep -Eo "http.*\.exe" | sed 's/\\//g' >> ${TWDIR}/adobe_Wurls
    sed 's/"/\n/g' ${DLFILE}  | grep -Eo "http.*\.dmg" | sed 's/\\//g' >> ${TWDIR}/adobe_Murls
  fi
done
rm -f ${DLFILE}


if [[ $DEBUG -eq 1 ]]; then
  sort -ur ${TWDIR}/adobe_Wurls
  sort -ur ${TWDIR}/adobe_Murls
else
  Wurls=$(sort -ur ${TWDIR}/adobe_Wurls)
  Murls=$(sort -ur ${TWDIR}/adobe_Murls)
fi
rm -f  ${TWDIR}/adobe_Murls  ${TWDIR}/adobe_Wurls  2>&1 1>/dev/null


rFl=($(find ${repo}/${repoChk}  -maxdepth 1 -type f -exec cat {} \;  2>/dev/null))
szt=${#rFl[@]}
sz_rFl=$(( szt / 3 ))

for URL in ${Wurls[@]} ${Murls[@]}; do
    file=${URL//*en_US\/}
    OS=${URL//*\/win\/*/win}
    [[ ${#OS} -gt 3 ]] && OS=${URL//*\/mac\/*/mac}
    bVerT=${URL/#*${OS}\/}
    bVer=${bVerT//.x*/.x}

# WGET 
# sha1
# URL
    n_chk_f="new_files"
    mkdir -p ${TWDIR}/${n_chk_f}
    echo -e "${file} ${URL}"  >  "${TWDIR}/${n_chk_f}/${OS}_${bVer}.txt"
    # [0] inst-name
    # [1] file-url
    # [2] sha1

    fileExists=0
    if [[ $sz_rFl == 0 ]]; then
	wget --quiet -q  ${URL} -O "${TWDIR}/${file}"  2>/dev/null
	openssl dgst -sha1 "${TWDIR}/${file}" | cut -d' ' -f2 >> "${TWDIR}/${n_chk_f}/${OS}_${bVer}.txt"
	mkdir -p "${TWDIR}/${repoChk}"
	mv "${TWDIR}/${n_chk_f}/${OS}_${bVer}.txt" "${TWDIR}/${repoChk}/."
    else
	## for every file in Repo-Check, check if it matches file-to-download
	for (( i=0; i < sz_rFl*3; i=i+3 )); do
#	    echo " ${file}  == ${rFl[${i}]}"
	    if [[ "${file}" == "${rFl[$i]}" ]]; then
		fileExists=1
		i=sz_rFl*3
	    fi
	done
	# download file, generate sha1 digest
	if [[ $fileExists == 0 ]]; then
	    wget --quiet -q  ${URL} -O "${TWDIR}/${file}"  2>/dev/null
	    openssl dgst -sha1 "${TWDIR}/${file}" | cut -d' ' -f2 >> "${TWDIR}/${n_chk_f}/${OS}_${bVer}.txt"
	    mkdir -p "${TWDIR}/${repoChk}"
	    mv "${TWDIR}/${n_chk_f}/${OS}_${bVer}.txt" "${TWDIR}/${repoChk}/."
	    
	    # if old Ver checksum file exists
	    if [[ -e  ${repo}/${repoChk}/${OS}_${bVer}.txt ]]; then
		mkdir -p ${repo}/older/${repoChk}
		olVerInst=($(cut -d' ' -f1 ${repo}/${repoChk}/${OS}_${bVer}.txt ))
#		olVerChk=$(cut -d' ' -f3 ${repo}/${repoChk}/${OS}_${bVer}.txt )
		#_# move out older checksum to old-folder, concatenate any others with same name such that NEWEST is on top
		touch "${repo}/older/${repoChk}/${OS}_${bVer}.txt"
		mv "${repo}/${repoChk}/${OS}_${bVer}.txtB" "${repo}/older/${repoChk}/${OS}_${bVer}.txt"
		cat "${repo}/older/${repoChk}/${OS}_${bVer}.txt" "${repo}/older/${repoChk}/${OS}_${bVer}.txtB" > "${repo}/older/${repoChk}/${OS}_${bVer}.txtC"
		mv "${repo}/older/${repoChk}/${OS}_${bVer}.txtC"  "${repo}/older/${repoChk}/${OS}_${bVer}.txt" -f
		rm -f "${repo}/older/${repoChk}/${OS}_${bVer}.txtB"  "${repo}/older/${repoChk}/${OS}_${bVer}.txtC"
		#_# move out old installer to old-folder
		mv "${repo}/${olVerInst}" "${repo}/older/."
	    fi
	fi

    fi
    
    if [[ $fileExists == 0 ]]; then
        #_# move in new installer and new checksum
	mkdir -p "${repo}/${repoChk}"
	mv "${TWDIR}/${file}" "${repo}"/.
	mv "${TWDIR}/${repoChk}"/*  "${repo}/${repoChk}"/.
    fi

done


rm -rf ${TWDIR}

