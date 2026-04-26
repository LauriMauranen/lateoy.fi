#!/bin/bash

set -ueo pipefail

sudo podman compose run --name nginx -d --service-ports nginx
