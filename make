#!/bin/bash
dub upgrade
DFLAGS="-J=source/" dub build --force
