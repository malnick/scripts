#!/bin/bash
CORP=$(nmap --script ssl-enum-ciphers -p 443 srcclr.com | egrep strength | cut -d: -f2 | tr -d '[[:space:]]')
BLOG=$(nmap --script ssl-enum-ciphers -p 443 blog.srcclr.com | egrep strength | cut -d: -f2 | tr -d '[[:space:]]')
APP=$(nmap --script ssl-enum-ciphers -p 443 app.srcclr.com | egrep strength | cut -d: -f2 | tr -d '[[:space:]]')

if [[ "${CORP}" != "strong" ]]; then
  echo "Corporate URL srcclr.com failed, got ${CORP} cipher rating."
  CORP_RATING=1
else
  echo "Corporate URL srcclr.com is OK, got ${CORP} cipher rating."
  CORP_RATING=0
fi

if [[ "${BLOG}" != "strong" ]]; then
  echo "Blog URL blog.srcclr.com failed, got ${BLOG} cipher rating."
  BLOG_RATING=1
else
  echo "Blog URL blog.srcclr.com is OK, got ${BLOG} cipher rating."
  BLOG_RATING=0
fi

if [[ "${APP}" != "strong" ]]; then
  echo "App URL app.srcclr.com failed, got ${APP} cipher rating."
  APP_RATING=1
else
  echo "Blog URL blog.srcclr.com is OK, got ${APP} cipher rating."
  APP_RATING=0
fi

if [[ $CORP_RATING -eq 1 ]]; then
  exit 1
elif [[ $BLOG_RATING -eq 1 ]]; then
  exit 1
elif [[ $APP_RATING -eq 1 ]]; then
  exit 1
else
  exit 0
fi
