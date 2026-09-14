#!/bin/sh
# vulnerables/web-dvwa starts with no database. Without this, every login
# attempt on a fresh `docker compose up` silently fails until someone
# manually visits setup.php and clicks "Create / Reset Database". This
# script does that automatically so the lab works out of the box.
#
# Two curl gotchas made this fiddly to get right:
#  1. curl's cookie-jar file (-b/-c FILE) round-trip was unreliable in this
#     container — the Cookie header sometimes silently didn't get sent on
#     the follow-up request. Passing the session cookie explicitly via -H
#     avoids this.
#  2. create_db's own POST always returns an empty body with a 302 to
#     setup.php, whether it succeeded or not — the actual "Setup
#     successful" message only appears if you follow that redirect. It's
#     simpler and more reliable to just verify with an actual login
#     attempt afterwards instead of parsing create_db's response.
set -e

get_session() {
  # $1 = page to GET. Prints "PHPSESSID TOKEN" on stdout.
  local page="$1"
  local headers body sessid token
  body=$(mktemp)
  headers=$(curl -s -D - "http://week7-dvwa/$page" -o "$body")
  sessid=$(echo "$headers" | grep -oE 'PHPSESSID=[a-z0-9]+' | head -1 | cut -d= -f2)
  token=$(grep -oE "user_token' value='[a-f0-9]+" "$body" | grep -oE '[a-f0-9]{32}')
  rm -f "$body"
  echo "$sessid $token"
}

echo "Waiting for DVWA to come up..."
until curl -sf http://week7-dvwa/setup.php -o /dev/null; do
  sleep 2
done

attempt=0
while [ "$attempt" -lt 20 ]; do
  attempt=$((attempt + 1))

  set -- $(get_session setup.php)
  SESSID=$1
  TOKEN=$2

  if [ -n "$SESSID" ] && [ -n "$TOKEN" ]; then
    curl -s -H "Cookie: PHPSESSID=$SESSID; security=low" -X POST http://week7-dvwa/setup.php \
      --data-urlencode "create_db=Create / Reset Database" \
      --data-urlencode "user_token=$TOKEN" -o /dev/null
  fi

  # Verify with an actual login attempt, using a fresh session/token pair.
  set -- $(get_session login.php)
  SESSID=$1
  TOKEN=$2

  if [ -n "$SESSID" ] && [ -n "$TOKEN" ]; then
    LOCATION=$(curl -s -H "Cookie: PHPSESSID=$SESSID; security=low" -X POST http://week7-dvwa/login.php \
      --data-urlencode "username=admin" --data-urlencode "password=password" \
      --data-urlencode "Login=Login" --data-urlencode "user_token=$TOKEN" \
      -D - -o /dev/null | grep -i "^Location:")

    case "$LOCATION" in
      *index.php*)
        echo "DVWA database initialized and verified working (attempt $attempt)."
        exit 0
        ;;
    esac
  fi

  echo "Database not ready yet (attempt $attempt), retrying..."
  sleep 3
done

echo "DVWA database init did not verify successfully after $attempt attempts." >&2
exit 1
