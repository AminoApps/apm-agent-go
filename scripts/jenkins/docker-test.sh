#!/usr/bin/env bash
set -euxo pipefail

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.
. ${srcdir}/common.bash

jenkins_setup

go get -v -u github.com/jstemmer/go-junit-report
go get -v -u github.com/t-yuki/gocover-cobertura
go get -v -t ./...

export COV_FILE="build/coverage/coverage.cov"
export OUT_FILE="build/test-report.out"
mkdir -p build/coverage

./scripts/docker-compose-testing up -d --build
./scripts/docker-compose-testing run -T --rm go-agent-tests make coverage GOFLAGS=-v 2> >(tee ${OUT_FILE} 1>&2) > ${COV_FILE}

gocover-cobertura < "${COV_FILE}" > build/coverage/coverage-apm-agent-go-docker-report.xml
go-junit-report > build/junit-apm-agent-go-docker.xml < ${OUT_FILE}
