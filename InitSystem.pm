package        InitSystem;
require        Exporter;

our @ISA       = qw(Exporter);
our @EXPORT    = qw(Initiative EndInit TrackInit PrintInit AddInit RemoveInit ChangeInit $waiting_for_rolls);    # Symbols to be exported by default
our @EXPORT_OK = qw();  # Symbols to be exported on request
our $VERSION   = 0.5;         # Version number

use Dice;

### Include your variables and functions here

my $round_num = 1;
my %c_inits;
@final_inits = ();


#not really used anymore....
sub by_number
{
  if ($b > $a) { -1 } elsif ($b < $a) { 1 } else { 0 }
}

sub sort_inits  # "bubble sort"
{
  my $array_ref = shift;   # We get passed an array reference as Arg1, 
  @inits_to_sort = @$array_ref;  # dereferencing the array
  my $array_leng = @inits_to_sort; # using @array in scalar context gives the num_elements
  my $temp = "";
  my $first = "";
  my $second = "";
  my ($i, $j) = 0;
  for ($i = 1; ($i <= $array_leng); $i++)
  {
    for ($j = 0; $j < $array_leng-1; $j++)
    {
      $inits_to_sort[($j+1)] =~ /\((-?\d*)\)/i;
      $first = $1;
      $inits_to_sort[$j] =~ /\((-?\d*)\)/i;
      $second = $1;
      if (($first > $second) && ($first ne ""))
      {
        ($inits_to_sort[$j], $inits_to_sort[$j+1]) = ($inits_to_sort[$j+1], $inits_to_sort[$j]);
#         $temp = $inits_to_sort[$j];
#         $inits_to_sort[$j] = $inits_to_sort[$j+1];
#         $inits_to_sort[$j+1] = $temp;
      }
    }
  }
#  print @inits_to_sort;
  return (@inits_to_sort);
}

sub Initiative
{
  my $text = shift;
  my $conn = shift;
  my $event = shift;

  # Delete all of the old inits from last round.
  @final_inits = ();
  foreach $item (keys %c_inits)
  {  delete $c_inits{$item};  }

  # determine if this is the 1st round, if not, add 1 to the previous round number
  if ($text =~ /^INIT (\d+)/i)
    { $round_num = $1; }
  elsif ($text =~ /^INIT next/i)
    { $round_num++; }
  else { $round_num = "1"; }

  $conn->privmsg($event->{to}[0], ("DM has called for Initiative!  Round: " . $round_num));
}

sub EndInit
{
  my $conn = shift;
  my $event = shift;

  my $channel = $event->{to}[0];
  $conn->privmsg($channel, "Initiative rolling is now over for round: " . $round_num ."!");
  @final_inits = sort_inits(\@final_inits);
  PrintInit($conn, $channel);
}

sub PrintInit
{
  my $conn = shift;
  my $channel = shift;
  unless ($channel =~ /^\#.*/i)
  { } #print "tag\n"; }#$channel = $channel->{to}[0]; 

  my $init_string = "Initiative order is: [ ";
  my $i = 0;

  # using @array in a scalar context is the number of items in the array
  # -1 to account for the 0th element
  # and another -1 to account for the last element that we print after the loop
  if (($#final_inits) >= 0)  # if there's only 1 element in the array, we won't need comma's
  {
    for ($i = 0; $i <= (@final_inits -2); $i++)
    {  $init_string = $init_string . $final_inits[$i] . ", ";}
    $init_string = $init_string . $final_inits[$#final_inits] . " ]\n";
  }
  else { $init_string = $init_string . "empty! ]\n"; }  

  $conn->privmsg($channel, "$init_string");
}

sub TrackInit
{
  my $conn = shift;
  my $event = shift;

  # if you've already rolled init this round, you can't roll again
  my $nick = shift;
  return if exists $c_inits{ $nick };

  my $roll = "";
  my $operator = shift;
  my $mod_num = shift;
  if ((defined $mod_num) && (defined $operator))
  {
    $mod = $operator . $mod_num;
    $roll = d(20, $mod);
    $conn->privmsg($event->{to}[0], ("\cB" . $nick . ",\cB d20" . $mod . ": " . $roll));
  }
  else
  {
    $mod = 0;
    $roll = d(20, $mod);
    $conn->privmsg($event->{to}[0], ("\cB" . $nick . ",\cB d20" . ": " . $roll));
  }

  $_ = $roll;
  s/("|_)(-?\d+)("|_)/$2/i;  # strip out our "natural" markings, if any
  $c_inits{$nick} = $_;

  push(@final_inits, ("\cB$nick\cB($c_inits{$nick})"));  #add the result to an array to be processed in EndInit();
}

sub AddInit
{
  my $conn = shift;
  my $channel = shift;
  my $nick = shift;
  my $operator = shift;
  my $mod_num = shift;
  my $result = shift;

  if ((defined $result) && ($result ne "-"))
  # player already rolled (maybe they didn't roll in time, or messed up)
  {
    $_ = $result;
    s/("|_)(-?\d+)("|_)/$2/i;  # strip out our "natural" markings, if any
    @final_inits = (@final_inits, "$nick($_)");
    @final_inits = sort_inits(\@final_inits);
    $conn->privmsg($channel, ("DM is adding an initiative roll for $nick"));
  }
  #otherwise we'll need to roll for the character
  elsif ((defined $mod_num) && (defined $operator))
  {
    $mod = $operator . $mod_num;
    $roll = d(20, $mod);
    $conn->privmsg($channel, ("DM is adding an initiative roll for: $nick"));
    $conn->privmsg($channel, ("\cB" . $nick . ",\cB d20" . $mod . ": " . $roll));
    $_ = $roll;
    s/("|_)(-?\d+)("|_)/$2/i;  # strip out our "natural" markings, if any
    @final_inits = (@final_inits, "$nick($_)");
    @final_inits = sort_inits(\@final_inits);
  }
  else
  {
    $mod = 0;
    $roll = d(20, $mod);
    $conn->privmsg($channel, ("DM is adding an initiative roll for: $nick"));
    $conn->privmsg($channel, ("\cB" . $nick . ",\cB d20" . ": " . $roll));
    $_ = $roll;
    s/("|_)(-?\d+)("|_)/$2/i;  # strip out our "natural" markings, if any
    @final_inits = (@final_inits, "$nick($_)");
    @final_inits = sort_inits(\@final_inits);
  }
}

sub RemoveInit
{
# grab $conn, $channel, $nick
#compare $nick with each $elem of @final_inits
# when/if it matches, delete $final_inits[$elem]
  my $conn = shift;
  my $channel = shift;
  my $nick = shift;
  $_ = $nick;
  s/^(.*)? .*/$1/i;
  $nick = $_;
  for (my $x = 0; $x <= $#final_inits; $x++)
  {
    if ($final_inits[$x] =~ /^($nick)/i)
      {  splice(@final_inits, $x, 1);  }
  }
}

sub ChangeInit
{
  my $conn = shift;
  my $channel = shift;
  my $nick = shift;
  my $operator = shift;
  my $mod_num = shift;
  my $result = shift;

  RemoveInit($conn, $channel, $nick);
  AddInit($conn, $channel, $nick, $operator, $mod_num, $result);
}

1;