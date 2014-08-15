package        DMHelper;
require        Exporter;


#use            Time::HiRes qw(sleep);

our @ISA       = qw(Exporter);
our @EXPORT    = qw(printlist dmhelper);    # Symbols to be exported by default
our @EXPORT_OK = qw();  # Symbols to be exported on request
our $VERSION   = 0.1;         # Version number

sub dmhelper
{
  my $conn = shift;
  my $nick = shift;
  my $command = shift;

  my @list_of_commands = (
"\cB!dmhelp\cB to get help on how to use this dicebot;",
"\cB!dm/feats/\cB to list all of the feats;",
"\cB!dm/feats/!list/item\cB to list all of the item feats;",
"\cB!dmlist\cB to see this message;");

  if ($command =~ /^!dmlist/i)
  {
    foreach (@list_of_commands) { $conn->privmsg($nick, $_); }
  }

  if ($command =~ /^!dm\/feats\/$/i)
  {
    list($conn, $nick, "all");
  }
  
  if ($command =~ /^!dm\/feats\/(.*)$/i)
  {
    list($conn, $nick, "$1");
  }

  if ($command =~ /^!dmnpc(.*)$/i)
  {
    gen_npc($conn, $nick);
  }
}


sub list
{
  my $conn = shift;
  my $nick = shift;
  my $search = shift;

  open(FILE, "data/PHBFeatList-sorted.txt") or die "Cannot read file: $!";
print "file opened\n";
  my @lines = <FILE>;

  if ($search eq "all")
  {
print "print all records\n";
    my $x = 0;
    foreach $_ (@lines)
    {
      $conn->privmsg($nick, "$_");
      $x++;
      if ($x % 5 == 0)
      {
        print "....";
        $conn->privmsg($nick, "....");
        sleep(3);
      }
    }
  }
  else
  {
print "printing $search records\n";
    my $print_flag = "false";
    foreach $_ (@lines)
    {
      if ($_ eq "<$search>\n")
      {
        print "$_\n";
        $print_flag = "true";
      }
      elsif (($_ eq "</$search>\n") || ($_ eq "</$search>"))
      {
        print "$_\n";
        $print_flag = "false";
      }
      elsif ($print_flag eq "true")
      {
        $conn->privmsg($nick, "$_");
      }
      else { print "ummm?\n"; }
    }
  }
}
