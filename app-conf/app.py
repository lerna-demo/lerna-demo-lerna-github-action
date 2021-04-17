#!/usr/bin/python

import sys

GIT_BRANCH = sys.argv[1].split('/')[-1]

if GIT_BRANCH in ["main", "dev"]:
    print("::set-output name=kube-env::dev")
    print("::set-output name=kube-config-data-key::/kube_config_data/non-prod")
