#!/bin/bash

#   Copyright (C) 2013-2014 Computer Sciences Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

set -e

function gen_thrift () {
    thrift_src="$1"
    language_name=$2
    language_gen_suffix=$3
    language_opt=$4
    declare -a args=("$@")
    language_args=${args[@]:4}

    thrift_gen="$thrift_src/../../../target/thrift-gen/$language_gen_suffix"
    artifact_base="${thrift_src}/../../../"

    rm -rf "${thrift_gen}"
    mkdir -p "${thrift_gen}"

    common_args="-I $thrift_src "
    common_args+="-I ${artifact_base}/target/thrift-deps/src/main/thrift "

    for thrift_file in "${thrift_src}"/*.thrift; do
        if [[ ${language_name} == "Go" && -z "$(type -P gofmt)" ]]; then
            echo "[WARN] Skipping Go because it is not installed or on the path"
        else
            echo "Generating $language_name code for $(basename ${thrift_file})"
            thrift ${common_args} --gen ${language_opt} ${language_args} -out "${thrift_gen}" "${thrift_file}"
        fi
    done

    if [[ ${language_name} == "C++" ]]; then
        echo "Moving $language_name include files to include directory"
        mkdir "${thrift_gen}/include"
        mv "${thrift_gen}"/*.h "${thrift_gen}"/include

        echo "Removing skeleton files"
        rm -f "${thrift_gen}"/*.skeleton.cpp
    elif [[ ${language_name} == "Python" ]]; then
        # delete top level __init__.py
        rm -f "${thrift_gen}"/__init__.py
        ./generate_package_manifest.py -m "${artifact_base}" -t python
    elif [[ ${language_name} == "NodeJS" ]]; then
        ./generate_package_manifest.py -m "${artifact_base}" -t node
    fi
}

declare -a GENS=(\
    "Java java java:hashcode" \
    "C++ cpp cpp:cob_style" \
    "Python python py:new_style" \
    "NodeJS node js:node -r" \
    "Go go go")

THRIFT_REQ_VERSION="0.9.1"

#If generation_mode is "all", the script will fail if all the supported languages cannot be generated
#Any other value will generate whatever languages it can, outputting a warning for languages that cannot be generated
#Currently, Go is the only language with special requirements
generation_mode=$1

if [[ -z "$(type -P thrift)" ]]; then
    echo "Thrift ${THRIFT_REQ_VERSION} must be installed and on the PATH" >&2
    exit 1
fi

thrift_version_str="$(thrift --version)" || true
thrift_version="${thrift_version_str##* }"
if [[ "${thrift_version}" != "${THRIFT_REQ_VERSION}" ]]; then
    echo "Thrift is installed and on the PATH but is not version ${THRIFT_REQ_VERSION}" >&2
    echo "Thrift version found: ${thrift_version}" >&2
    exit 1
fi

if [[ generation_mode == "all" && -z "$(type -P gofmt)" ]]; then
    echo "Go (including gofmt) must be installed and on the PATH" >&2
    echo "This can be installed using Homebrew with 'brew install go'" >&2
    exit 1
fi

DIR=${2-.}

for thrift_src in $(find ${DIR} -path "*/src/main/thrift" -a ! -path "*target*"); do
    thrift_dir="$(cd "${thrift_src}" && pwd -P)"

    echo "Going into $(dirname ${thrift_dir})"

    for gen in "${GENS[@]}"; do
        gen_thrift "${thrift_src}" ${gen}
    done
done
