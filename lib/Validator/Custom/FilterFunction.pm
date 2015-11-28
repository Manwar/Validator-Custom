package Validator::Custom::FilterFunction;

use strict;
use warnings;

use Carp 'croak';

### Note
# Filter function return undef if value is undefined

sub remove_blank {
  my ($vc, $values, $arg) = @_;
  
  return $values unless ref $values eq 'ARRAY';
  
  $values = [grep { defined $_ && CORE::length $_} @$values];
  
  return $values;
}

sub trim {
  my ($vc, $value, $arg) = @_;
  
  return undef unless defined $value;
  
  $value =~ s/^[ \t\n\r\f]*(.*?)[ \t\n\r\f]*$/$1/ms;

  return $value;
}

sub trim_collapse {
  my ($vc, $value, $arg) = @_;
  
  return undef unless defined $value;
  
  $value =~ s/[ \t\n\r\f]+/ /g;
  $value =~ s/^[ \t\n\r\f]*(.*?)[ \t\n\r\f]*$/$1/ms;

  return $value;
}

sub trim_lead {
  my ($vc, $value, $arg) = @_;
  
  return undef unless defined $value;

  $value =~ s/^[ \t\n\r\f]+(.*)$/$1/ms;

  return $value;
}

sub trim_trail {
  my ($vc, $value, $arg) = @_;
  
  return undef unless defined $value;

  $value =~ s/^(.*?)[ \t\n\r\f]+$/$1/ms;

  return $value;
}

sub trim_uni {
  my ($vc, $value, $arg) = @_;
  
  return undef unless defined $value;

  $value =~ s/^\s*(.*?)\s*$/$1/ms;

  return $value;
}

sub trim_uni_collapse {
  my ($vc, $value, $arg) = @_;

  return undef unless defined $value;
  
  $value =~ s/\s+/ /g;
  $value =~ s/^\s*(.*?)\s*$/$1/ms;

  return $value;
}

sub trim_uni_lead {
  my ($vc, $value, $arg) = @_;
  
  return undef unless defined $value;
  
  $value =~ s/^\s+(.*)$/$1/ms;
  
  return $value;
}

sub trim_uni_trail {
  my ($vc, $value, $arg) = @_;
  
  return undef unless defined $value;

  $value =~ s/^(.*?)\s+$/$1/ms;

  return $value;
}

1;

=head1 NAME

Validator::Custom::FilterFunction - Filter functions

1;
