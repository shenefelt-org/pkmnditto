#!/usr/bin/env bash

docker build -t pkmnditto:latest .

docker push ghcr.io/shenefelt-org/pkmnditto:latest

