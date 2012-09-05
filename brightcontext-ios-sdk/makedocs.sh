#!/usr/bin/env bash

output_dir="./doc"

rm -rf ${output_dir}

doxygen
