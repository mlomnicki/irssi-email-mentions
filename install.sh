#!/bin/sh

$(perl -mMIME::Lite -e print \"MIME::Lite found\" 2> /dev/null)

if [ $? -ne 0 ]; then
  echo "Perl MIME::Lite not found. If you're on Debian try apt-get install libmime-lite-perl"
  exit 1
fi

$(curl --version 2>&1 1>/dev/null)

if [ $? -ne 0 ]; then
  echo "Curl not found"
  exit 1
fi

mkdir -p ~/.irssi/scripts/autorun

OLDPW=$(pwd)

cd ~/.irssi/scripts
curl -s -O https://raw.githubusercontent.com/mlomnicki/irssi-email-mentions/master/email_mentions.pl
cd ~/.irssi/scripts/autorun
ln -sf ../email_mentions.pl

cd "$OLDPW"

echo "Plugin installed. In any irssi window run: /script load email_mentions.pl"
