#!/bin/bash

hhmake -M 50 -nocontxt -diff 1000 -add_cons -i stdin -o stdout -v 0 -maxres 65535 -name "${FFINDEX_ENTRY_NAME}"
