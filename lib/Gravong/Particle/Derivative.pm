package Gravong::Particle::Derivative;
use strict;
use warnings;
use Gravong::Particle::Vector;
use Class::XSAccessor accessors => {
     replace   => 1,
    velocity => 'velocity',
    force     => 'force',
};

sub new {
    my $class = shift;
    my $self = bless {@_}, ref($class) || $class;

    $self->{velocity} = Gravong::Particle::Vector->new(0,0) if !$self->{velocity};
    $self->{force} = Gravong::Particle::Vector->new(0,0) if !$self->{force};
    return $self;
}

1;