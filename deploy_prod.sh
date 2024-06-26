#!/bin/bash

rsync -avz -e ssh --exclude=cache --exclude=images --exclude=README.md --exclude=.git . admin@216.14.174.91:/Users/admin/pull1/