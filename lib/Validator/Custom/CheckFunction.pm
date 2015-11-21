package Validator::Custom::CheckFunction;

use strict;
use warnings;

use Carp 'croak';

my $NUM_RE = qr/^[-+]?[0-9]+(:?\.[0-9]+)?$/;

sub defined { defined $_[1] ? 1 : 0 }

sub ascii { defined $_[1] && $_[1] =~ /^[\x21-\x7E]+$/ ? 1 : 0 }

sub between {
  my ($rule, $value, $args) = @_;
  my ($start, $end) = @$args;

    
  croak "Constraint 'between' needs two numeric arguments"
    unless defined($start) && $start =~ /$NUM_RE/ && defined($end) && $end =~ /$NUM_RE/;
  
  return 0 unless defined $value && $value =~ /$NUM_RE/;
  return $value >= $start && $value <= $end ? 1 : 0;
}

sub blank { defined $_[1] && $_[1] eq '' }

sub date {
  my $value = shift;
  
  require Time::Piece;
  
  # To Time::Piece object
  if (ref $value eq 'ARRAY') {
    my $year = $value->[0];
    my $mon  = $value->[1];
    my $mday = $value->[2];
    
    return [0, undef]
      unless defined $year && defined $mon && defined $mday;
    
    unless ($year =~ /^[0-9]{1,4}$/ && $mon =~ /^[0-9]{1,2}$/
     && $mday =~ /^[0-9]{1,2}$/) 
    {
      return 0;
    } 
    
    my $date = sprintf("%04s%02s%02s", $year, $mon, $mday);
    
    my $tp;
    eval {
      local $SIG{__WARN__} = sub { die @_ };
      $tp = Time::Piece->strptime($date, '%Y%m%d');
    };
    
    return $@ ? 0 : 1;
  }
  else {
    $value = '' unless defined $value;
    $value =~ s/[^0-9]//g;
    
    return [0, undef] unless $value =~ /^[0-9]{8}$/;
    
    my $tp;
    eval {
      local $SIG{__WARN__} = sub { die @_ };
      $tp = Time::Piece->strptime($value, '%Y%m%d');
    };
    return $@ ? 0 : 1;
  }
}

sub datetime {
  my ($rule, $value) = @_;
  
  require Time::Piece;
  
  # To Time::Piece object
  if (ref $value eq 'ARRAY') {
    my $year = $value->[0];
    my $mon  = $value->[1];
    my $mday = $value->[2];
    my $hour = $value->[3];
    my $min  = $value->[4];
    my $sec  = $value->[5];

    return [0, undef]
      unless defined $year && defined $mon && defined $mday
        && defined $hour && defined $min && defined $sec;
    
    unless ($year =~ /^[0-9]{1,4}$/ && $mon =~ /^[0-9]{1,2}$/
      && $mday =~ /^[0-9]{1,2}$/ && $hour =~ /^[0-9]{1,2}$/
      && $min =~ /^[0-9]{1,2}$/ && $sec =~ /^[0-9]{1,2}$/) 
    {
      return 0;
    } 
    
    my $date = sprintf("%04s%02s%02s%02s%02s%02s", 
      $year, $mon, $mday, $hour, $min, $sec);
    my $tp;
    eval {
      local $SIG{__WARN__} = sub { die @_ };
      $tp = Time::Piece->strptime($date, '%Y%m%d%H%M%S');
    };
    
    return $@ ? 0 : 1;
  }
  else {
    $value = '' unless defined $value;
    $value =~ s/[^0-9]//g;
    
    return 0 unless $value =~ /^[0-9]{14}$/;
    
    my $tp;
    eval {
      local $SIG{__WARN__} = sub { die @_ };
      $tp = Time::Piece->strptime($value, '%Y%m%d%H%M%S');
    };
    return $@ ? 0 : 1;
  }
}

sub decimal {
  my ($rule, $value, $digits_tmp) = @_;
  
  # �������𐮗�
  my $digits;
  if (defined $digits_tmp) {
    if (ref $digits_tmp eq 'ARRAY') {
      $digits = $digits_tmp;
    }
    else {
      $digits = [$digits_tmp, undef];
    }
  }
  else {
    $digits = [undef, undef];
  }
  
  # ���K�\�����쐬
  my $re;
  if (defined $digits->[0] && defined $digits->[1]) {
    $re = qr/^[0-9]{1,$digits->[0]}(\.[0-9]{0,$digits->[1]})?$/;
  }
  elsif (defined $digits->[0]) {
    $re = qr/^[0-9]{1,$digits->[0]}(\.[0-9]*)?$/;
  }
  elsif (defined $digits->[1]) {
    $re = qr/^[0-9]+(\.[0-9]{0,$digits->[1]})?$/;
  }
  else {
    $re = qr/^[0-9]+(\.[0-9]*)?$/;
  }
  
  # �l���`�F�b�N
  if (defined $value && $value =~ /$re/) {
    return 1;
  }
  else {
    return 0;
  }
}

sub duplication {
  my ($rule, $values) = @_;

  return 0 unless defined $values->[0] && defined $values->[1];
  return $values->[0] eq $values->[1];
}

sub equal_to {
  my ($rule, $value, $target) = @_;
  
  croak "Constraint 'equal_to' needs a numeric argument"
    unless defined $target && $target =~ /$NUM_RE/;
  
  return 0 unless defined $value && $value =~ /$NUM_RE/;
  return $value == $target ? 1 : 0;
}

sub greater_than {
  my ($rule, $value, $target) = @_;
  
  croak "Constraint 'greater_than' needs a numeric argument"
    unless defined $target && $target =~ /$NUM_RE/;
  
  return 0 unless defined $value && $value =~ /$NUM_RE/;
  return $value > $target ? 1 : 0;
}

sub http_url {
  return defined $_[1] && $_[1] =~ /^s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+$/ ? 1 : 0;
}

sub int { defined $_[1] && $_[1] =~ /^\-?[0-9]+$/ ? 1 : 0 }

sub in_array {
  my ($rule, $value, $args) = @_;
  $value = '' unless defined $value;
  my $match = grep { $_ eq $value } @$args;
  return $match > 0 ? 1 : 0;
}

sub length {
  my ($rule, $value, $args) = @_;
  
  return unless defined $value;
  
  my $min;
  my $max;
  if(ref $args eq 'ARRAY') { ($min, $max) = @$args }
  elsif (ref $args eq 'HASH') {
    $min = $args->{min};
    $max = $args->{max};
  }
  else { $min = $max = $args }
  
  croak "Constraint 'length' needs one or two arguments"
    unless defined $min || defined $max;
  
  my $length  = length $value;
  my $is_valid;
  if (defined $min && defined $max) {
    $is_valid = $length >= $min && $length <= $max;
  }
  elsif (defined $min) {
    $is_valid = $length >= $min;
  }
  elsif (defined $max) {
    $is_valid =$length <= $max;
  }
  
  return $is_valid;
}

sub less_than {
  my ($rule, $value, $target) = @_;
  
  croak "Constraint 'less_than' needs a numeric argument"
    unless defined $target && $target =~ /$NUM_RE/;
  
  return 0 unless defined $value && $value =~ /$NUM_RE/;
  return $value < $target ? 1 : 0;
}

sub string { defined $_[1] && !ref $_[1] }
sub not_blank   { defined $_[1] && $_[1] ne '' }
sub not_defined { !defined $_[1] }
sub not_space   { defined $_[1] && $_[1] !~ '^[ \t\n\r\f]*$' ? 1 : 0 }

sub uint { defined $_[1] && $_[1] =~ /^[0-9]+$/ ? 1 : 0 }

sub regex {
  my ($rule, $value, $regex) = @_;
  defined $value && $value =~ /$regex/ ? 1 : 0;
}

sub selected_at_least {
  my ($rule, $values, $num) = @_;
  
  my $selected = ref $values ? $values : [$values];
  $num += 0;
  return scalar(@$selected) >= $num ? 1 : 0;
}

sub space { defined $_[1] && $_[1] =~ '^[ \t\n\r\f]*$' ? 1 : 0 }

1;

=head1 NAME

Validator::Custom::CheckFunction - Checking functions
