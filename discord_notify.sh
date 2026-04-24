#!/bin/bash
# Notify Discord of a Jenkins build event.
# Usage: discord_notify.sh failure|fixed|aborted|changed
# Reads DISCORD_WEBHOOK, JOB_NAME, BUILD_NUMBER, BUILD_URL from the Jenkins environment.

set -euo pipefail

SCENARIO="${1:-}"

case "${SCENARIO}" in
  failure)
    TITLE="Failure! - ${JOB_NAME}"
    COLOR=16724787 ;; # 0xFF3333
  fixed)
    TITLE="Fixed! - ${JOB_NAME}"
    COLOR=244736   ;; # 0x03BB00
  aborted)
    TITLE="Aborted! - ${JOB_NAME}"
    COLOR=8421504  ;; # 0x808080
  changed)
    TITLE="Changed! - ${JOB_NAME}"
    COLOR=16750848 ;; # 0xFFAA00
  *)
    echo "Usage: $0 failure|fixed|aborted|changed" >&2
    exit 1
    ;;
esac

DESC="$(printf '**Job**: %s\n**Build #**: [%s](%sstages/)' "${JOB_NAME}" "${BUILD_NUMBER}" "${BUILD_URL}")"

PAYLOAD="$(jq -n \
  --arg title "${TITLE}" \
  --arg desc "${DESC}" \
  --arg url "${BUILD_URL}" \
  --argjson color "${COLOR}" \
  '{
    username: "Jenkins",
    embeds: [{
      title: $title,
      description: $desc,
      color: $color,
      url: $url,
    }]
  }')"

echo "Sending Discord ${SCENARIO} notification for ${JOB_NAME} #${BUILD_NUMBER}..."

HTTP_CODE="$(curl -s -o /dev/stderr -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d "${PAYLOAD}" \
  "${DISCORD_WEBHOOK}")"

if [[ "${HTTP_CODE}" -lt 200 || "${HTTP_CODE}" -gt 299 ]]; then
  echo "Discord webhook returned HTTP ${HTTP_CODE}" >&2
  exit 1
fi

echo "Discord notification sent (HTTP ${HTTP_CODE})"
