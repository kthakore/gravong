# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use strict;
use warnings;

use SDL;
use SDL::App;
use SDL::Video;
use SDL::Surface;
use SDL::Rect;
use SDL::Event;
use SDL::Events;
use Data::Dumper;

use Physics::Particles;

SDL::init(SDL_INIT_VIDEO);

my $app = SDL::Video::set_video_mode (  800,  600, 32, SDL_HWSURFACE | SDL_DOUBLEBUF );
my $app_rect = SDL::Rect->new(0,0,800,  600);
my @old_part_rect;
my @new_part_rect;
my @color;


use constant G      => 0.03;


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
		      
		      update();
	
	$sim->iterate_step(1);
}


sub update_bg
{
	
return	SDL::Video::fill_rect( $app, $app_rect, SDL::Video::map_RGB ( $app->format, 0, 0, 10 ));
	

}

sub init_particle_surf
{
	my $size = shift;
	my $bg = SDL::Surface->new(SDL_SWSURFACE, $size, $size, 32, 0, 0, 0, 0);
SDL::Video::fill_rect( $bg, SDL::Rect->new(0, 0, $size, $size), rand_color());

	SDL::Video::display_format( $bg );
		return $bg;
}

sub warp
{
   my $p = shift;

	$p->{x} = 0 if ($p->{x} > $app->w);
	$p->{y} = 0 if ($p->{y} > $app->w);
	$p->{x} = $app->w if ($p->{x} < 0);
	$p->{y} = $app->h if ($p->{y} < 0);


}

sub update
{
	
 update_bg();
 foreach my $p (@{ $sim->{p} }) {

#		print Dumper $p;
		
		update_particle($p);
		warp($p)

	}

 SDL::Video::flip($app);


}

sub rand_color
{
   my $r =rand( 30 +255 ) - 30;
   my $b =rand( 30 +255 ) - 30;
   my $g =rand( 30 +255 ) - 30;

  return SDL::Video::map_RGB ( $app->format, $r, $g, $b );
}

sub update_particle
{

 my $p = shift;
 my $size =  $p->{m};
  $color[$p->{n}] = init_particle_surf($size) if !defined $color[$p->{n}];

  my $c = $color[$p->{n}];

 my $new_part_rect = SDL::Rect->new(0, 0, $size, $size);

SDL::Video::blit_surface( $c, $new_part_rect, $app, SDL::Rect->new($p->{x}-$size/2, $p->{y} - $size/2, $app->w, $app->h) );
  
  #SDL::Video::update_rects ( $app, $old_part_rect[$p->{n}], $new_part_rect ) if( defined $old_part_rect[$p->{n}] );
  $old_part_rect[$p->{n}] = $new_part_rect;

 
}




