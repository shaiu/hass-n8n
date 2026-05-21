#!/bin/bash
. /app/n8n-exports.sh

echo "N8N_PATH: ${N8N_PATH}"
echo "N8N_EDITOR_BASE_URL: ${N8N_EDITOR_BASE_URL}"
echo "WEBHOOK_URL: ${WEBHOOK_URL}"

# Allow file nodes to write to /share/* (Obsidian vault, etc).
# n8n's isFilePathBlocked() defaults block /share paths and the task-runner
# subprocess inherits a stripped env where N8N_BLOCK_FILE_ACCESS_TO_N8N_FILES=false
# does not propagate, so the env-var override alone is not enough. Patch the helper
# at startup. Idempotent: the regex only matches the un-patched line.
HELPER=$(find /usr/local/lib/node_modules/n8n -name file-system-helper-functions.js 2>/dev/null | head -1)
if [ -n "${HELPER}" ]; then
  sed -i '/^function isFilePathBlocked/s/{$/{ return false;/' "${HELPER}"
  echo "Patched isFilePathBlocked in ${HELPER}"
fi

###########
## MAIN  ##
###########

exec n8n $N8N_CMD_LINE
