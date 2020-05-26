FROM quay.io/patrickpierson/docker-jre:11.0.5_alpine_3.11
MAINTAINER patrick.pierson@ironnet.com

# Export HTTP & Transport
EXPOSE 9200 9300

ENV ES_VERSION 7.7.0

ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/elasticsearch"
ENV ES_TARBAL "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz"
ENV ES_TARBALL_SHA "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz.sha512"

# Install Elasticsearch.
RUN apk add --no-cache --update bash ca-certificates su-exec util-linux curl
RUN apk add --no-cache -t .build-deps openssl \
  && cd /tmp \
  && echo "===> Install Elasticsearch..." \
  && curl -o elasticsearch.tar.gz -Lskj "$ES_TARBAL"; \
	if [ "$ES_TARBALL_ASC" ]; then \
		curl -o elasticsearch.tar.gz.sha512 -Lskj "$ES_TARBALL_SHA"; \
		shasum -a 512 elasticsearch.tar.gz; \
	fi; \
  tar -xf elasticsearch.tar.gz \
  && ls -lah \
  && mv elasticsearch-$ES_VERSION /elasticsearch \
  && adduser -DH -s /sbin/nologin elasticsearch \
  && mkdir -p /elasticsearch/config/scripts /elasticsearch/plugins \
  && chown -R elasticsearch:elasticsearch /elasticsearch \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

ENV PATH /elasticsearch/bin:$PATH

WORKDIR /elasticsearch

# Copy configuration
COPY config /elasticsearch/config

# Copy run script
COPY run.sh /

# Set environment variables defaults
ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"
ENV CLUSTER_NAME elasticsearch-default
ENV NODE_MASTER true
ENV NODE_DATA true
ENV NODE_INGEST true
ENV HTTP_ENABLE true
ENV NETWORK_HOST _site_
ENV HTTP_CORS_ENABLE true
ENV HTTP_CORS_ALLOW_ORIGIN *
ENV NUMBER_OF_MASTERS 1
ENV MAX_LOCAL_STORAGE_NODES 1
ENV SHARD_ALLOCATION_AWARENESS ""
ENV SHARD_ALLOCATION_AWARENESS_ATTR ""
ENV MEMORY_LOCK true
ENV REPO_LOCATIONS ""

# Volume for Elasticsearch data
VOLUME ["/data"]

CMD ["/run.sh"]
