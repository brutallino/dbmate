# build image
FROM golang:1.12 as build

# required to force cgo (for sqlite driver) with cross compile
ENV CGO_ENABLED 1

# install database clients
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		default-mysql-client \
		postgresql-client \
		sqlite3 \
	&& rm -rf /var/lib/apt/lists/*

# development dependencies
RUN curl -fsSL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
	| sh -s v1.16.0

# copy source files
COPY . /src
WORKDIR /src

# build
RUN make build

# runtime image
FROM golang:1.12
#RUN apk --no-cache add libc6-compat mysql-client
COPY --from=build /src/dist/dbmate-linux-amd64 /dbmate
ENTRYPOINT ["/dbmate"]
