package        NPCGen;
require        Exporter;

use            Dice;
use            Switch;

our @ISA       = qw(Exporter);
our @EXPORT    = qw(npc gen_npc);    # Symbols to be exported by default
our @EXPORT_OK = qw();  # Symbols to be exported on request
our $VERSION   = 0.1;         # Version number

my @classes = (
    "classes", "\cB1.\cB Cleric", "\cB2.\cB Fighter", "\cB3.\cB Wizard", "\cB4.\cB Rogue");
my @races = (
    "races", "\cB1.\cB Human", "\cB2.\cB Elf");


sub gen_npc
{
  my $conn = shift;
  my $recipient = shift;
  my $seed = shift;

  my @character = split(/:/, $seed);

#  $conn->privmsg($recipient, "seed: $seed");
#  foreach (@character) { $conn->privmsg($recipient, "$_");  }


  switch ($character[0])
  {
    case ("1")      { print "Human\n"; }
    case ("2")      { print "Elf\n"; }
  }

  switch ($character[1])
  {
    case ("1")
    {
      print "Cleric\n"; 
      my $hp = d(8);
      print "$hp\n";
    }
    case ("2")
    {
      print "Fighter\n";
      my $hp = d(10);
      print "$hp\n";
    }
    case ("3")
    {
      print "Wizard\n"; 
      my $hp = d(4);
      print "$hp\n";
    }
    case ("4")
    {
      print "Rogue\n"; 
      my $hp = d(6);
      print "$hp\n";
    }
  }
}

sub npc
{
  my $conn = shift;
  my $recipient = shift;

  list_choices($conn, $recipient, \@races);
  list_choices($conn, $recipient, \@classes);

  $conn->privmsg($recipient, ("Use the command \cB!dmgen num:num\cB to generate an NPC."));
}

sub list_choices
{
  my $conn = shift;
  my $recipient = shift;
  my $list_ref = shift;

  @list = @{$list_ref};

  $conn->privmsg($recipient, ("Here is a list of $list[0] to choose from."));
  shift @list;
  foreach (@list) { $conn->privmsg($recipient, "$_");  }
}