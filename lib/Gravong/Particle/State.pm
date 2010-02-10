package Gravong::Particle::State;
use strict;
use warnings;
use Class::XSAccessor 
 replace   => 1,
accessors => {
   
    position => 'position',
    momentum => 'momentum',
    velocity => 'velocity',
    mass     => 'mass',
    invMass  => 'invMass'
};

sub new {
    my $class = shift;
    my $self = bless {@_}, ref($class) || $class;

    $self->{position} = 0 if !$self->{position};
    $self->{momentum} = 0 if !$self->{momentum};
    $self->{velocity} = 0 if !$self->{velocity};
    $self->{mass}     = 1 if !$self->{mass};
    $self->{invMass}  = 1 if !$self->{invMass};
    return $self;
}

sub recalculate {
    my $self = shift;

    $self->{velocity} = $self->{momentum} * $self->{invMass};
}



1;


