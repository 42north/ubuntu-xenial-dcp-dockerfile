#!/bin/bash
docker build --no-cache -t docker-registry.dev.42n.co:5000/ubuntu-wxwind-io-netcore:1.1.0 ubuntu-wxwind-io-netcore/ &&
docker push docker-registry.dev.42n.co:5000/ubuntu-wxwind-io-netcore:1.1.0