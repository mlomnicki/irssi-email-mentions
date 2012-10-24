# Copyright (c) 2012 Michal Lomnicki <michal.lomnicki@gmail.com>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
use POSIX qw(strftime);

use MIME::Lite;

$VERSION = '0.1';
%IRSSI = (
	authors => 'Michal Lomnicki',
	contact => 'michal.lomnicki@gmail.com',
	url => 'https://github.com/mlomnicki/email-mentions-irssi',
	name => 'email_mentions',
	description =>
		"Receive an email when sombody mentions you . " .
		"Requires MIME::Lite.",
	license => 'MIT',
);

my $FORMAT = $IRSSI{'name'} . '_crap';
my $msgs = {};
my $timer;

Irssi::settings_add_str('misc', $IRSSI{'name'} . '_from_address', 'irssi@' . ($ENV{'HOST'} || 'localhost'));
Irssi::settings_add_str('misc', $IRSSI{'name'} . '_to_address', $ENV{'USER'});
Irssi::settings_add_time('misc', $IRSSI{'name'} . '_delay', "2m");

Irssi::theme_register([
  $FORMAT,
  '{line_start}{hilight ' . $IRSSI{'name'} . ':} $0'
]);

setup_changed();

sub setup_changed {
  my $delay = Irssi::settings_get_time($IRSSI{'name'} . '_delay');

  if(defined $timer) {
    Irssi::timeout_remove($timer);
  }
  $timer = Irssi::timeout_add($delay, 'check_messages', '');
}

sub check_messages() {
  if(messages_present()) {
    send_email();
    clear_messages();
  }

  return 0;
}

sub handle_private_message {
  my ($server, $message, $user, $address) = @_;

  queue_message($message, $user, 'Private');
}

sub handle_public_message {
  my ($server, $message, $user, $address, $channel) = @_;

  if($message =~ /($server->{nick})|($\@?all:)/) {
    queue_message($message, $user, $channel);
  }
}

sub queue_message {
  my ($message, $user, $channel) = @_;

  unless (defined $msgs->{$user}) {
    $msgs->{$user} = {};
  };

  unless (defined $msgs->{$user}{$channel}) {
    $msgs->{$user}->{$channel} = [];
  };

  push(@{$msgs->{$user}->{$channel}}, sprintf("[%s] <%s> %s",
      strftime("%T", localtime(time)),
      $user,
      $message));
}

sub generate_email() {
  my @lines = ();

  for my $user (keys %{$msgs}) {
    for my $channel (keys %{$msgs->{$user}}) {
      push(@lines, $channel);
      push(@lines, '=' x length($channel));
      push(@lines, '');

      for my $message (@{$msgs->{$user}->{$channel}}) {
        push(@lines, $message);
      }
      push(@lines, '');
    }
  }

  return join("\n", @lines);
}

sub generate_subject() {
  my $senders = join(", ", keys %{$msgs});
  return "You were mentioned by $senders";
}

sub send_email() {
  my $body = generate_email();
  my $subject = generate_subject();
  my $to = Irssi::settings_get_str($IRSSI{'name'} . '_to_address');
  my $from = Irssi::settings_get_str($IRSSI{'name'} . '_from_address');

  my $email = MIME::Lite->new(
    To => $to,
    From => $from,
    Subject => $subject,
    Data => $body,
  );

  if (! $email->send()) {
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, $FORMAT, "an error occurred when sending an email to $to");
  }
}

sub clear_messages {
  $msgs = {};
}

sub messages_present {
  return scalar(keys(%{$msgs})) > 0;
}


Irssi::signal_add_last("message private", "handle_private_message");
Irssi::signal_add_last("message public", "handle_public_message");
Irssi::signal_add_last("gui key pressed", "clear_messages");
Irssi::signal_add_last("setup changed", "setup_changed");
