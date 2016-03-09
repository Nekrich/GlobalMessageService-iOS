#!/bin/bash
jazzy -m GlobalMessageService \
--min-acl public \
-a "Global Message Services AG" \
-u https://gms-worldwide.com \
-o ./docs \
--module-version 0.0.1 \
--source-directory ./GlobalMessageService \
-x -workspace,GlobalMessageService.xcworkspace,-scheme,GlobalMessageService \
-c

jazzy -m GlobalMessageService \
--min-acl private \
-a "Global Message Services AG" \
-u https://gms-worldwide.com \
-o ./docs/privateDocs \
--module-version 0.0.1 \
--source-directory ./GlobalMessageService \
-x -workspace,GlobalMessageService.xcworkspace,-scheme,GlobalMessageService \
-c
