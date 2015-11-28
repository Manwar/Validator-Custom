package Validator::Custom::CheckFunction;

use strict;
use warnings;

use Carp 'croak';

my $NUM_RE = qr/^[-+]?[0-9]+(:?\.[0-9]+)?$/;

sub ascii {
  my ($vc, $value, $arg) = @_;
  
  my $is_valid = $value =~ /^[\x21-\x7E]+$/;
  
  return $is_valid;
}

sub decimal {
  my ($vc, $value, $arg) = @_;
  
  my $digits_tmp = $arg;
  
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
  if ($value =~ /$re/) {
    return 1;
  }
  else {
    return 0;
  }
}

sub int {
  my ($vc, $value, $arg) = @_;
  
  my $is_valid = $value =~ /^\-?[0-9]+$/;
  
  return $is_valid;
}

sub in {
  my ($vc, $value, $arg) = @_;
  
  my $valid_values = $arg;
  
  my $match = grep { $_ eq $value } @$valid_values;
  return $match > 0 ? 1 : 0;
}

sub uint {
  my ($vc, $value, $arg) = @_;
  
  my $is_valid = $value =~ /^[0-9]+$/;
  
  return $is_valid;
}

sub selected_at_least {
  my ($vc, $values, $arg) = @_;
  
  my $num = $arg;
  
  my $selected = ref $values ? $values : [$values];
  $num += 0;
  
  my $is_valid = @$selected >= $num;
  
  return $is_valid;
}



1;

=head1 NAME

Validator::Custom::CheckFunction - Checking functions
