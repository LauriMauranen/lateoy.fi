#!/bin/bash

set -ueo pipefail

sudo podman compose run -d --service-ports nginx
