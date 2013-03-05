irssi-email-mentions
=========================

Receive an email when somebody mentions you on IRC.

- You're mailed when somebody mentions you (or when your nick appears in the message)
- You're mailed when a message is send to everyone on the channel
- You're mailed when somebody sends you a private message

Requirements
============

This plugin uses sendmail wrapper to send emails.
If you have postfix or exim installed it's already in your system.
Otherwise you can use [nullmailer](http://untroubled.org/nullmailer/) or
[ssmtp](http://wiki.debian.org/sSMTP).

You'll also need MIME::Lite library for Perl.

On Debian/Ubuntu you can install it with

    apt-get install libmime-lite-perl

Install
=======

Copy email_mentions.pl to ~/.scripts/irssi and optionally symlink it to ~/.scripts/irssi/autorun

Lame install
============


    $ ssh username@your-shell.net
    $ curl https://github.com/mlomnicki/irssi-email-mentions/master/install.sh | sh


Open Irssi and type the following command in any window

    /script load email_mentions.pl

Configure
=========

Define how long should the plugin wait for activity? 2 minutes is default

30s = 30 seconds, 5m = 5 minutes, etc.

    /set email_mentions_delay 5m

Set email recipient. yourUsername@localhost is default

    /set email_mentions_to_address you@gmail.com

Set email sender. irssi@localhost is default

    /set email_mentions_from_address irssi@example.net


Don't forget to save your config

    /save
