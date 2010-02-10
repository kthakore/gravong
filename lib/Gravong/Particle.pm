package Gravong::Particle;
use strict;
use warnings;

use Gravong::Particle::State;
use Gravong::Particle::Vector;
use Gravong::Particle::Derivative;


use Class::XSAccessor accessors => {
    previous => 'previous',
    current  => 'current',
};

sub new {
	my $class = shift;
	my $self  = bless { @_ }, $class;
	
	$self->current( Gravong::Particle::State->new() );
	
	$self->current->size( 1);
	$self->current->mass( 1);
	$self->current->invMass(1.0/ $self->current->mass() );
	$self->current->current->position ( Gravong::Particle::Vector->new(2,0,0) );
	$self->current->recalculate();
	$self->previous ( $self->current );
	
	return $self;
}


sub update{   my ($self,$t, $dt) =@_;
   
   $self->previous($self->current);
   $self->integrate($self->current,$t,$dt);

}

#static State interpolate(const State &a, const State &b, float alpha)
sub interpolate{ my ($a, $b, $alpha) = @_;
    my $state = Particles::State->new();
    
    $state = $b;
    $state->position ( $a->position*(1-$alpha) + $b->position*$alpha );
    $state->recalculate();
    return $state;

}

#static Derivative evaluate(const State &state, float t)
#static Derivative evaluate(State state, float t, float dt, const Derivative &derivative)
sub evaluate{
    
    if (scalar @_ == 2)
    {
        my ($state,$t) = @_;
        my $output = Gravong::Particles::Derivative->new();
		$output->velocity ( $state->velocity );		
		forces($state, $t, $output->force);
		return $output;
    }
    elsif (scalar @_ == 5)
    {
        my ($state, $t, $dt, $derivative) = @_;
        $state->{position} += $derivative->velocity * $dt;
		
		$state->recalculate();
		
		$output = Gravong::Particle::Derivative->new( velocity => $state->velocity());
		forces($state, $t+$dt, $output->force);
#		return output;
                return $state;
        
    }
	
}

#static void integrate(State &state, float t, float dt)
sub integrate{
	my ($state, $t, $dt) = @_;
	my $a = evaluate($state, $t);
	my $b = evaluate($state, $t, $dt*0.5, $a);
	my $c = evaluate($state, $t, $dt*0.5, $b);
	my $d = evaluate($state, $t, $dt, $c);
	
}

#static void forces(const State &state, float t, Vector &force, Vector &torque)
sub forces{
	my ($state, $t, $force)	= @_;

	$force = - 10 * $state->position();
}
1;
