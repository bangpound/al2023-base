# syntax=docker/dockerfile:1.4

FROM public.ecr.aws/amazonlinux/amazonlinux:2023-minimal

RUN <<EOT
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
set -o xtrace

dnf install --assumeyes mariadb105 awscli jq bzip2 zstd &&
  dnf clean all &&
  rm -rf /var/cache/yum
EOT

RUN <<EOT
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
set -o xtrace

cert_dir=/tmp/aws-certs

mkdir -p "${cert_dir}"
mkdir -p /usr/local/share/ca-certificates/aws/

curl --silent --show-error "https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem" > ${cert_dir}/global-bundle.pem

awk 'split_after == 1 {n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1}{print > "aws-ca-" n+1 ".crt"}' < ${cert_dir}/global-bundle.pem

for cert in aws-ca-*; do
  mv "${cert}" /usr/local/share/ca-certificates/aws/
done

update-ca-trust extract
EOT
