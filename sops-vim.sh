#!/bin/sh
SOPS_AGE_KEY_FILE=age.agekey EDITOR=/usr/bin/vim sops edit $1
