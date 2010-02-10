package Gravong::Particle::Vector;

use strict;
use warnings;
use Class::XSAccessor
  replace   => 0,    # Replace existing methods (if any)
  accessors => {
    x => 'x',
    y => 'y',
  },
  
  ;

sub new {
    my $class = shift;
    my $self = bless {@_}, ref($class) || $class;

    $self->{x} = 0 if !$self->{x};
    $self->{y} = 0 if !$self->{y};
    return $self;
}

sub add {
    my ( $self, $vector ) = @_;

    $self->x( $self->x() + $vector->x() );
    $self->y( $self->y() + $vector->y() );
    return [ $self->x(), $self->y() ];
}

sub mul {
    my ( $self, $scalar ) = @_;
    $self->x( $self->x() * $scalar );
    $self->y( $self->y() * $scalar );
    return [ $self->x(), $self->y() ];
}

1;