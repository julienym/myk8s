#!/bin/bash
set -e

printf '{"base64_encoded":"%s"}\n' $(cat $1 | base64 -w 0)