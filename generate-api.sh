#!/usr/bin/env bash

set -e

hse_branch="master"
doc_ver="v2"

doxybook_bin="doxybin"
doxybook_exec="${doxybook_bin}/bin/doxybook2"
doxybook_zip_url="https://github.com/matusnovak/doxybook2/releases/download/v1.3.6/doxybook2-linux-amd64-v1.3.6.zip"
doxybook_zip="doxybook2-linux-amd64-v1.3.6.zip"
if [[ ! -f ${doxybook_exec} ]]
then
    [[ -f ${doxybook_zip} ]] || wget -q ${doxybook_zip_url}
    rm -rf ${doxybook_bin}
    mkdir ${doxybook_bin}
    unzip ${doxybook_zip} -d ${doxybook_bin}
fi
dep_check=0
for dep in doxygen;
do
    if ! command -v ${dep} &> /dev/null
    then
      echo "Install ${dep} "
      dep_check=1
    fi
done
if [ ${dep_check} -ne 0 ]
then
    exit ${dep_check}
fi

rm -rf hse-clone
git clone https://github.com/hse-project/hse.git hse-clone
poetry install
pushd hse-clone
    git checkout ${hse_branch}
    poetry run meson build -Ddocs=true
    poetry run meson compile -C build doxygen
popd
rm -rf ${doc_ver}/docs/api
mkdir ${doc_ver}/docs/api
${doxybook_exec} --input hse-clone/build/docs/doxygen/api/xml/ --output ${doc_ver}/docs/api --config ${doc_ver}/.doxybook/config.json  --templates ${doc_ver}/.doxybook/templates
rm -rf hse-clone
[[ -f ${doxybook_zip} ]] && rm ${doxybook_zip}
