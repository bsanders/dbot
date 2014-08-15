package        BotAdmin;
require        Exporter;

use DoMath;
use InitSystem;
use DMHelper;
use NPCGen;

our @ISA       = qw(Exporter);
our @EXPORT    = qw(Greeting Admin_access Normal_access IAmDM);    # Symbols to be exported by default
our @EXPORT_OK = qw();  # Symbols to be exported on request
our $VERSION   = 0.9;         # Version number

sub Greeting
{
  my $greeting = shift;
  if ($greeting =~ /(hey|hi|heya|hello)/i)
    { return ($1 . ", back at ya"); }
  else { return ""; }
}

sub IAmDM
{
  my $pass_attempt = shift;
  if (($pass_attempt =~ /^(these dice go to (11|eleven))$/i))
    { return 1; }
  else { return 0; }
}

sub FakeRoll
{
  my $conn = shift;
  my $channel = shift;
  my $nick = shift;
  my $operator = shift;
  my $mod_num = shift;
  my $result = shift;

    my $current = ("\cB" . $nick . ",\cB d22" . $operator . $mod_num . ": " . $result);
    $conn->privmsg($channel, $current);

}

sub Normal_access
{
  my $conn = shift;
  my $event = shift;
  my $command = shift;

#  my $text = $event->{args}[0];
  my $nick = $event->{nick};

  my @list_of_commands = (
"\cB!join #channel\cB to have dbot join a channel;",
"\cB!printinit\cB to print the initiative order;",
"\cB!help\cB to get help on how to use this dicebot;",
"\cB!dm\cB to see the DM's helper menu;",
"\cB!list\cB to see this message;");


  if ($command =~ /^!list/i)
  {
    foreach (@list_of_commands) { $conn->privmsg($nick, $_); }
  }

  if ($command =~ /^!join (#.*)/i)
  {
    $conn->join($1);
    return;
  }

  if ($command =~ /^!printinit/i)
  {
    PrintInit($conn, $nick);
    return;
  }

  if ($command =~ /^!dm/i)
  {
    dmhelper($conn, $nick, $command);
    return;
  }
}

sub Admin_access
{
  my $conn = shift;
  my $event = shift;
  my $command = shift;

#  my $text = $event->{args}[0];
  my $nick = $event->{nick};

  my @list_of_commands = (
"\cB!join #channel\cB to have dbot join a channel;",
"\cB!nick nick_name\cB to change dbot's nickname;",
"\cB!say #channel|nick_name your message\cB to send a message from dbot;",
"\cB!addinit #channel nick_name roll|d20+N\cB to add a roll to initiative;",
"\cB!rminit #channel nick_name\cB to remove a roll from initiative;",
"\cB!chinit #channel nick_name roll|d20+N\cB to change an initiative roll;",
"\cB!printinit #channel|nick_name\cB to print the initiative order;",
"\cB!init\cB init stuff;",
"\cB!admin\cB to see this message;");

  if ($command =~ /!admin/i)
  {
    foreach (@list_of_commands) { $conn->privmsg($nick, $_); }
  }

  if ($command =~ /!join (#.*)/i)
  {
    $conn->join($1);
    return;
  }

  if ($command =~ /!nick (.*)/i)
  {
    $conn->nick($1);
    return;
  }

  if ($command =~ /!say (#?.*?) (.*)/i)
  {
    $conn->privmsg($1, $2);
    return;
  }

  if ($command =~ /!addinit (#.*?) (.*?) ((d20((-|\+)(\d{1,3}))?)|(-?\d{1,3}))$/i)
  {
    AddInit($conn, $1, $2, $6, $7, $8);
#    PrintInit($conn, $1);
    return;
  }

  if ($command =~ /!rminit (#.*?) (.*)/i)
  {
    RemoveInit($conn, $1, $2);
#    PrintInit($conn, $1);
    return;
  }

  if ($command =~ /!chinit (#.*?) (.*?) ((d20((-|\+)(\d{1,3}))?)|(-?\d{1,3}))$/i)
  {
    ChangeInit($conn, $1, $2, $6, $7, $8);
    PrintInit($conn, $1);
    return;
  }

  if ($command =~ /!printinit (#?.*)/i)
  {
    PrintInit($conn, $1);
    return;
  }

  if ($command =~ /!init/i)
  {

    PrintInit($conn, $1);
    return;
  }


  if ($command =~ /!fakeroll (#.*?) (.*?) ((d22((-|\+)(\d{1,3}))?) (-?\d{1,3}))$/i)
  {
    FakeRoll($conn, $1, $2, $6, $7, $8);
    return;
  }

  if ($command =~ /^!dmnpc/i)
  {
    npc($conn, $nick);
    return;
  }
  
  if ($command =~ /^!dmgen(\ (.*))?/i)
  {
    gen_npc($conn, $nick, $2);
    return;
  }
}