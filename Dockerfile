#
# Copyright 2015-2016 The OpenZipkin Authors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
#
FROM openzipkin/jre-full:1.8.0_112
MAINTAINER OpenZipkin "http://zipkin.io/"

ARG STORAGE_TYPE
ENV ZIPKIN_REPO https://jcenter.bintray.com
ENV DEPENDENCIES_VERSION 1.5.2

# Use to set heap, trust store or other system properties.
ENV JAVA_OPTS -Djava.security.egd=file:/dev/./urandom

WORKDIR /zipkin-dependencies

# Enable cron by running with entrypoint: crond -f -d 8
# * Bundling this configuration is a convenience, noting not everyone will use cron
# * Cron invokes this job hourly to process today's spans and daily to process yesterday's
COPY periodic/ /etc/periodic/

# Adds coreutils to allow date formatting of 'yesterday'
RUN apk add --no-cache coreutils && \
    curl -SL $ZIPKIN_REPO/io/zipkin/dependencies/zipkin-dependencies/$DEPENDENCIES_VERSION/zipkin-dependencies-$DEPENDENCIES_VERSION.jar > zipkin-dependencies.jar

# Default entrypoint is to run the dependencies job on-demand, processing today's spans.
CMD java ${JAVA_OPTS} -jar zipkin-dependencies.jar
