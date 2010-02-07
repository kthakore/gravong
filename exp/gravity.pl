# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use strict;
use warnings;

use SDL;
use SDL::App;
use SDL::Video;
use SDL::Rect;
use SDL::Event;
use SDL::Events;
use Data::Dumper;

use Physics::Particles;

my $app = SDL::App->new ( -title => 'Gravity Sim', -width => 800, -height => 600 );
my @old_part_rect;
my @new_part_rect;
my @color;

my $black = SDL::Video::map_RGB ( $app->format(), 0, 0, 0 );
sub update
{

 SDL::Video::fill_rect
       ( $app, SDL::Rect->new(0, 0, $app->w, $app->h), $black );

}

sub rand_color
{
   my $r =rand( 30 +255 ) - 30;
   my $b =rand( 30 +255 ) - 30;
   my $g =rand( 30 +255 ) - 30;

  return SDL::Video::map_RGB ( $app->format(), $r, $g, $b );


}

sub update_particle
{

 my $p = shift;

  $color[$p->{n}] = rand_color if !defined $color[$p->{n}];

  my $c = $color[$p->{n}];

 my $size =  $p->{m};
 my $new_part_rect =SDL::Rect->new($p->{x}-$size/2, $p->{y} - $size/2, $size, $size);

 SDL::Video::fill_rect
        ( $app, $new_part_rect, $c);

  SDL::Video::update_rects
        ( $app,  $old_part_rect[$p->{n}], $new_part_rect )  if(  defined  $old_part_rect[$p->{n}] );
  $old_part_rect[$p->{n}] = $new_part_rect;
}


use constant G      => 0.003;


my $sim = Physics::Particles->new();



$sim->add_force(
	sub {
		my $p = shift;
		my $excerter = shift;
		my $params = shift;
		my $time_diff = $params->[0];

		my $x_dist = ($excerter->{x} - $p->{x});
		my $y_dist = ($excerter->{y} - $p->{y});
		my $z_dist = ($excerter->{z} - $p->{z});

		my $dist = sqrt($x_dist**2 + $y_dist**2 + $z_dist**2);
			

		# force = m1*m2*unit_vector_from_r1_to_r2/distance**2
		# a = f/m1 (module does that for us)

		my $const = G;
		my $force =
		(
			$dist == 0 ? 0 :
			$const * $p->{m} * $excerter->{m} / $dist**2
			#const = (G * MEARTH / AU / AU)
		);

		return(
			$force * $x_dist,
			$force * $y_dist,
			$force * $z_dist
		);
	},
	1 # symmetric force
);


$sim->add_particle(
	x  => $app->w/2, y  => $app->h/2, z  => 0,
	vx => 0.0,  vy => 0.0,  vz => 0,
	m  => 35,    n  => 1,
);

$sim->add_particle(
	x  => rand( $app->w - 10 ) , y  => rand ( $app->h - 10 ),  z  => 0,
	vx => 0.4,  vy => -0.2,  vz => 0,
	m  => 10,   n  => 0,
);

$sim->add_particle(
	x  => rand( $app->w - 10 ) , y  => rand ( $app->h - 10 ),  z  => 0,
	vx => 0.0,  vy => 0.1,  vz => 0,
	m  => 12,   n  => 2,
);


my $event = SDL::Event->new();

my $cont = 1;
while($cont){

	while (SDL::Events::poll_event($event)) {
		    $cont = 0 if $event->type == SDL_QUIT;
		      }
	foreach my $p (@{ $sim->{p} }) {

#		print Dumper $p;
		update();
		update_particle($p);

		if ($p->{x} > $app->w || $p->{y} > $app->w)
		{
			$p->{x} = $app->w/2;
			$p->{y} = $app->h/2;
		}
	}
	$sim->iterate_step(1);
}


SDL::quit
