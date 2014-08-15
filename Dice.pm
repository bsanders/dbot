package        Dice;
require        Exporter;

use DoMath;

our @ISA       = qw(Exporter);
our @EXPORT    = qw(parse_for_rolls d);    # Symbols to be exported by default
our @EXPORT_OK = qw();  # Symbols to be exported on request
our $VERSION   = 0.99;         # Version number

### Include your variables and functions here

sub d
# random integer, 1 to 1st argument, inclusive, modified by 2nd arg
{
  $die_max = shift;
  $mod = shift;

  if ($mod eq "") { $mod = 0; }
  $random = int(rand( $die_max )) + ($mod + 1);

  return (markIfNatural($random, $mod, $die_max));
}

sub markIfNatural
{
  my $result = shift;
  my $mod = shift;
  my $die_max = shift;

# checks to see if it was a natural "20" (or the max of whatever die we rolled)
  if (($result - $mod) eq $die_max)
  { $result = "_" . $result . "_"; }
# Ok, its not a "natural", was it a "1"?
  elsif (($result - $mod) eq "1")
  { $result = "\"" . $result . "\""; }
  return ($result);
}

sub sum_dice
# computes the sum of the dice without displaying each roll
# Arg0 is number of dice, Arg1 is what type, Arg2 is the modifier.
{
  $total = 0;
  for ($i = 1; $i <= $_[0]; $i++)
  {
    $result = d($_[1], $_[2]);
    $result =~ /(-?\d+)/;
    $total = $total + $1;
  }
  return ($total);
}

sub roll_dice
# stores each roll in an array.
# Arg0 is number of dice, Arg1 is what type, Arg2 is the modifier.
{
  my @rolls;
  if (is_positive($_[0]) && is_sane($_[0]) && is_positive($_[1]) && is_sane($_[1]) && is_sane($_[2]))
  {
    for ($i = 1; $i <= $_[0]; $i++)
    {  $rolls[$i] = d($_[1], $_[2]);  }
    return (@rolls);
  }
  else
  {
    $rolls[0] = "";
    return (@rolls);
  }
}


sub show_dice
# display a formatted list of dice
# should display as "total: [ X, Y, Z ]"
{
  $total = 0;
  $result = "";
  $dice_ref = $_[1]; # why is this necessary?
                     # should be able to use $_[1] directly
  if (@$dice_ref eq "") { return ""; }  # if the dice string was funky, abort

  foreach (@$dice_ref)
  {
    /(-?\d+)/;         # looks for 0 or 1 "-", then 1 or more digits.
    $total = $total + $1; # sum the dice.  $1 == result of regexp search.
  }
  $total = $total + $_[2];
  $result = ($total . " [ ");

  for ($i = 1; $i <= $_[0]; $i++)
  {
    $result = $result . @$dice_ref[$i];
    if (($i) ne $_[0])    {      $result = $result . ", ";    }
    else                  {      $result = $result . " ]\n";  }
  }
  return $result;
}

sub is_number
# does the input contain a non-digit?
{
  my $num = shift;
  if ($num =~ /[a-ce-z\^\$\%\@\!\~\`\&\*\|\=\+\_\'\"\;\:\,\.\<\>\?\/]/i)
  { return (0); }
  elsif (($num =~ /.*d.*?d/i))
  { return (0); }
  elsif (($num =~ /^[-\+]?\d+$/) && ($num ne ""))
  { return 1; }
  else
  { print "RIIBTTTT\n"; return (0); } #
}

sub is_positive
# is the number bigger than 0?
{
  if ($_[0] < 1)
  { return (0); }
  else
  { return (1); }
}

sub is_sane
# is the number a sane number?
{
  my $num = shift;
  if ($num > 999)
  { return (0); }
  elsif ($num eq "")
  { return (1); }
  else { return (1); }
}

sub is_saneMod
# is the mod a sane number?
{
  my $mod = shift;
  my $sub_mod;
  $sub_mod = substr($mod, 1,4);
  if ($sub_mod > 999)
  { return (0); }
  elsif ($sub_mod eq "")
  { return (1); }
  else { return (1); }
}


sub roll_single_die
{
  {
  my $text = shift;
  my $roll_type = "";
  my $die_to_roll = "";
  my $die_modifier = "";
 
    $roll_type = $1;
#    if ($text =~ /d(\d{1,3})[-\+]?\d*$/)   #looking for the die to be rolled
    if ($text =~ /^d(\d*)[-\+]?\d*$/i)   #looking for the die to be rolled
    {
      if (!is_sane($1)) {return "";}
      if (!is_number($1)) {return "";}
#      if (!is_positive($1)) {return "";}
      $die_to_roll = $1;
      if ($text =~ /d\d{1,3}([-\+]\d+$)/i) # ends in digit, then (- or +, digits)
      {
        if (!is_saneMod($1)) {return "";}
        if (($roll_type . $die_to_roll . $1) eq $text)
        { $die_modifier = $1; }
        else { return ""; }
      }
    return (d($die_to_roll, $die_modifier));
    }
    return "";
  }
}

sub roll_many_dice
{
  my $text = shift;
  my $num_dice = "";
  my $roll_type = "";
  my $die_to_roll = "";
  my $die_modifier = "";
  my $real_modifier = "0";
  my @rolls;


  $text =~ /^(\d{1,3})/;
  $num_dice = $1;
  if ($text =~ /(#d|d)/i)
  {
    $roll_type = $1;
    if ($text =~ /^\d{1,3}(#d|d)(\d*)((\+\+|--|\+|-)\d{1,3}){0,1}$/i) #weird.
    {                #'d' followed by (digits) then 1 or 0 -, +, <enter>
      if (!is_sane($2)) {return "";}
      if (!is_number($2)) {return "";}
      if (!is_positive($2)) {return "";}

      $die_to_roll = $2;
      if ($text =~ /\d((\+\+|--|\+|-)\d{1,3})$/i)  #look for modifiers
      {
        $die_modifier = $1;
        $real_modifier = $1;
        if ($die_modifier =~ /(\+\+|--)/) { $real_modifier = substr($die_modifier, 1); }
        if (!is_saneMod($real_modifier))   { return "";}
        if (($num_dice . $roll_type . $die_to_roll . $die_modifier) ne $text) 
        { return ""; }
      }
    }
    else { return ""; }
    if (($roll_type =~ /#/) && ($die_modifier =~ /(\+\+|--)/))
    {
      @rolls = roll_dice($num_dice, $die_to_roll, $real_modifier);
      return (show_dice($num_dice, \@rolls, 0));  #  "\@" is a reference to an array
    }
    elsif ($roll_type =~ /#/)
    {
      @rolls = roll_dice($num_dice, $die_to_roll, 0);
      return (show_dice($num_dice, \@rolls, $real_modifier));  #  "\@" is a reference to an array
    }
    elsif ($die_modifier =~ /(\+\+|--)/)
    { return (sum_dice($num_dice, $die_to_roll, $real_modifier));  }
    else
    { return (sum_dice($num_dice, $die_to_roll, "0") + $real_modifier);  }
  }
  return "";
}

sub parse_for_rolls
{
  my $text = shift;

  # lets look to see if they're trying to roll something.
  if ($text =~ /^(#d|d)\d/i)
  { return roll_single_die($text); }
  elsif (($text =~ /^\d{1,3}(#d|d)\d{1,3}/i) && ($text =~ /\d$/))
  { return roll_many_dice($text); }
  else {return "";}

}


1;