#!/usr/bin/env bash

output_dir="./doc"

rm -rf ${output_dir}

doxygen

#open ./doc/html/index.html

#pushd ${output_dir}/html
#for f in *.html; do mv ${f%html}{html,php}; done
#popd

#scp -r ${output_dir}/html/* root@dev04:/var/www/html/wp/docs/ios/
