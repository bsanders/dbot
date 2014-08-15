#!/usr/bin/perl -w

use Dice;
use DoMath;
use BotAdmin;
use InitSystem;
use Net::IRC;
use strict;
use Data::Dumper;
use Text::Wrapper;
use vars qw($wrapper $rand_num $roll_type $die_to_roll $die_modifier $current);

srand (time ^ $$ ^ unpack "%L*", `ps axww | gzip`);

# text wrapper to wrap long messages at the approximate length an IRC
# message should be, at its longest
$wrapper = new Text::Wrapper(columns => 400);

my $irc = new Net::IRC;
my $DMnick = 'DMastah`';
my $waiting_for_rolls = "0";

my $conn = $irc->newconn(
	Server 		=> shift || '127.0.0.1',
#	Server		=> shift || 'bobthecowboy.homelinux.net',
	Port		=> shift || '6667',
	Nick		=> 'Dicey`',
	Ircname		=> 'I roll twenties.',
	Username	=> 'dbot'
);

$conn->{channel} = shift || '#wegame';

sub on_connect {

	my $conn = shift;
  
  	# when we connect, join our channel and greet it
	$conn->join($conn->{channel});
#    $conn->join($conn->'\#wednd');
	$conn->privmsg($conn->{channel}, '*cackles gleefully*');
}

sub on_public {

	# on an event, we get connection object and event hash
	my ($conn, $event) = @_;

	# this is what was said in the event
	my $text = $event->{args}[0];
	my $nick = $event->{nick};

    $current = parse_for_rolls($text);
    if ($current ne "")
    {
      $current = ("\cB" . $nick . ",\cB " . $text . ": " . $current);
      $conn->privmsg($event->{to}[0], $current);
    }

    if ($text =~ /^INIT/i && ($nick eq $DMnick))
    {
      $waiting_for_rolls = 1;
      Initiative($text, $conn, $event);
    }

    if ($text =~ /^End(\s)?Init/i && ($nick eq $DMnick) && ($waiting_for_rolls == 1))
    {
      $waiting_for_rolls = 0;
      EndInit($conn, $event);
    }

    if (($text =~ /^((init|init:)\s?|\!)d20((-|\+)(\d{0,3}))?$/i) && ($waiting_for_rolls == 1))
    {
      TrackInit($conn, $event, $nick, $4, $5);
    }
#are they trying to do math?
    if ($text =~ /^\?(.+)/)
    { do_math($1, $conn, $event); }

}


sub on_msg {
	my ($conn, $event) = @_;
	my $text = $event->{args}[0];
	my $nick = $event->{nick};
    $current = parse_for_rolls($text);
    if ($current ne "")
    {
      $current = ("\cB" . $nick . ",\cB " . $text . ": " . $current);
      $conn->privmsg($nick, $current);
      if ($nick ne $DMnick)
      { $conn->privmsg($DMnick, $current); }
      else
      { $conn->privmsg($nick, "rolling to ourselves are we?"); }
    }

    if (IAmDM($text))
    #lets the DM login to gain Admin privledges
    {
      $conn->privmsg($DMnick, ($nick . " is now the Dungeon Master!"));
      $conn->privmsg($nick, ("Hello, DM.  Type '!admin' for a list of commands."));
      $DMnick = $nick;
    }

    if (($text =~ /^!/) && ($nick eq $DMnick))
    #checks if the nickname is the current Admin, if so, allows Admin Access
    {
      Admin_access($conn, $event, $text);
    }
    else
     {
      Normal_access($conn, $event, $text);
     }
}

sub on_notice {

	my ($conn, $event) = @_;

	# This handles nick registration.  On some IRC networks, you can 
	# password-protect you nick.  The IRC server will send you a "notice"
	# as NickServ that you have to identify with your passowrd.
	if (
	($event->{nick} eq 'NickServ') and
	($event->{args}[0] eq 'If you do not change within one minute, I will change your nick.')
	) {
		# send an /msg to NickServ with the password
		$conn->privmsg('NickServ', 'identify dice11');
		
		#
		# This is redundant with the behavior covered in on_msg
		on_connect($conn);
	}
}

sub default {
	# This is helpful to see what an event returns.  Data::Dumper will
	# recursively reveal the structure of any value
	my ($conn, $event) = @_;
	print Dumper($event);

}
	


# add handlers for our standard events
$conn->add_handler('public', \&on_public);
$conn->add_handler('msg', \&on_msg);
$conn->add_handler('notice', \&on_notice);
$conn->add_handler('376', \&on_connect);

# experiment with the cping event, printing out to standard output
$conn->add_handler('cping', \&default);

# start IRC
$irc->start;
