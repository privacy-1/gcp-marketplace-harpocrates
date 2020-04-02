#!/bin/bash -e

usage() {
PROGRAM=$(basename $0)
echo ""
echo "${PROGRAM} <-l license_file> <-k key_file> <-c cert_file> <-s console domain name> <-p privacyfront domain name>"
echo ""
exit -1
}

APP_NAME=harpocrates
APP_NAMESPACE=${APP_NAME}-ns
REGISTRY=gcr.io/privacy1-ab-public
TAG=1.0.1
DB_ROOT_PASSWORD=$(pwgen 16 1 | tr -d '\n' | base64)
DB_USER_PASSWORD=$(pwgen 16 1 | tr -d '\n' | base64)
JWT_SECRET=$(echo jwt_secret | base64)

license_file=""
key_file=""
cert_file=""
domain_console=""
domain_pf=""

while getopts "l:k:c:w:s:p:" opt; do
  case ${opt} in
    l )
      license_file=$OPTARG
      echo "license file ${license_file}"
      ;;
    k )
      key_file=$OPTARG
      echo "key file ${key_file}"
      ;;
    c )
      cert_file=$OPTARG
      echo "certificate file ${cert_file}"
      ;;
    s )
      domain_console=$OPTARG
      echo "Console domain name ${domain_console}"
      ;;
    p )
      domain_pf=$OPTARG
      echo "Privacyfront domain name ${domain_pf}"
      ;;
    ? )
      usage
      ;;
  esac
done
shift $((OPTIND -1))

echo $license_file
if [ -z "${license_file}" ] || [ -z "${key_file}" ] || [ -z "${cert_file}" ]; then
  usage
fi

license=$(cat $license_file | base64 -w 0)

tls_key=$(cat $key_file | base64 -w 0)

tls_crt=$(cat $cert_file | base64 -w 0)

cmd="mpdev /scripts/install --deployer=$REGISTRY/$APP_NAME/deployer:$TAG \
      --parameters='{"\"name\"": "\"${APP_NAME}\"", \
      "\"namespace\"": "\"${APP_NAMESPACE}\"", \
      "\"db.rootPassword\"": "\"${DB_ROOT_PASSWORD}\"", \
      "\"db.harpocratesPassword\"": "\"${DB_USER_PASSWORD}\"", \
      "\"jwt.secret\"": "\"${JWT_SECRET}\"", \
      "\"p1.license\"": "\"${license}\"", \
      "\"tls.base64EncodedPrivateKey\"": "\"${tls_key}\"", \
      "\"tls.base64EncodedCertificate\"": "\"${tls_crt}\"", \
      "\"domain.console\"": "\"${domain_console}\"", \
      "\"domain.privacyfront\"": "\"${domain_pf}\""}'"

echo $cmd

eval $cmd
