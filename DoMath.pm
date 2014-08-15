package        DoMath;
require        Exporter;

our @ISA       = qw(Exporter);
our @EXPORT    = qw(do_math);    # Symbols to be exported by default
our @EXPORT_OK = qw();  # Symbols to be exported on request
our $VERSION   = 0.5;         # Version number

### Include your variables and functions here

sub fact
{
  my $n = shift;

  if ($n == 0) {  return 1;   }
  if ($n < 2)  {  return $n;  }
  else         {  return $n * fact($n-1);  }
}

sub prep_expr
{
  my $text = shift;
  my $expression = $text;
  my $solution = "";

  my $conn = shift;
  my $event = shift;
  my $nick = shift;

  if ($expression =~ /\d\/0/i)
  {
    $conn->privmsg($event->{to}[0], ("\cB" . $nick . ",\cB " . $text . "= " . "Infinity, jerkass"));
    return;
  }
  if ($expression =~ /(\d*)\!/i)  # looks for factorials
  {
    my $temp = fact($1);
    $_ = $expression;
    s/(\d*\!)/$temp/g;
    $expression = $_;
  }
  if ($expression =~ /(\)\()/i)   # looks for neighboring paren's (x)(y)
  {
    $_ = $expression;
    s/\)\(/\)*\(/g;
    $expression = $_;
  }
  if ($expression =~ /(\^)/i)     # looks for "^" for exponentials
  {
    $_ = $expression;
    s/\^/\*\*/g;
    $expression = $_;
  }

  $solution = eval($expression);
  $conn->privmsg($event->{to}[0], ("\cB" . $nick . ",\cB " . $text . "= " . $solution));
}

sub do_math
{
  my $expression = shift;
  chomp $expression;
  my $conn = shift;
  my $event = shift;
  my $nick = $event->{nick};

  if ($expression =~ /([a-z\@\#\$\&_\=\{\}\[\]\:\;\"\'\?\<\,\>\.\~\`\\\|])/i)
    { print "non-math: $1\n"; return; }
  elsif ($expression =~ /\(\)/i)
    { print "bad parenthesis\n"; return; }
  else { prep_expr($expression, $conn, $event, $nick); }
}

1;