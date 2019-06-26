ROOT_DIR := $(shell pwd)
PATH := ${ROOT_DIR}/node/current/bin:${ROOT_DIR}/node_modules/.bin:${PATH}
TAG ?= latest
IMAGE = gcr.io/metamarkets-prod-xpn-host/druid-console
all: compile

init: install-node-modules install-bower-components copy-bower-css-and-fonts
#
# node
#

install-node-modules:
	@npm install

install-bower-components:
	@node_modules/.bin/bower install --allow-root

copy-bower-css-and-fonts:
	@mkdir -p static/css
	@cp bower_components/bootstrap/dist/css/bootstrap-theme.css bower_components/bootstrap/dist/css/bootstrap.css bower_components/font-awesome/css/font-awesome.css static/css
	@mkdir -p static/fonts
	@cp bower_components/font-awesome/fonts/* static/fonts

#
# app
#

compile:
	@mkdir -p target/src
	@cd target && ln -s ../build && ln -s ../static
	@cd target/src && ln -s ../../src/server

#
# clean
#

clean-all: clean clean-node-modules clean-bower-components

clean:
	@rm -rfv target

clean-node-modules:
	@rm -rfv node_modules

clean-bower-components:
	@rm -rfv bower_components
	@rm -rfv static/css
	@rm -rfv static/fonts

.PHONY: build
build:
	@docker build . -t ${IMAGE}:${TAG}

.PHONY: run
run:
	@docker run --rm -e NODE_ENV=production -e ZK_HOSTNAME="zk.metamx-metrics.com" -e ZK_SERVICE_DISC_PATH="/prod/discovery" -p 8080:8080 ${IMAGE}:${TAG}
