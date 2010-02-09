use strict;
use warnings;


#Get SDL from http://github.com/kthakore/SDL_perl/tree/redesign (might be down)
#or from http://search.cpan.org/~kthakore/SDL-2.3_5/

use SDL;
use SDL::App;
use SDL::Video;
use SDL::Surface;
use SDL::Rect;
use SDL::Events;
use SDL::Event;
use SDL::Time;
use SDL::Color;
use SDL::GFX::Primitives;
use Data::Dumper;

use Physics::Particles;

use constant G => 0.03;

SDL::init(SDL_INIT_VIDEO);

my $app = SDL::Video::set_video_mode( 800, 600, 32, SDL_SWSURFACE );
my $app_rect = SDL::Rect->new( 0, 0, 800, 600 );
my @old_part_rect;
my @new_part_rect;
my @color;
my $fps = 30;
my $bg_surf = update_bg($app);
my $par=0;

my $sim = Physics::Particles->new();

$sim->add_force(
    sub {
        my $p         = shift;
        my $excerter  = shift;
        my $params    = shift;
        my $time_diff = $params->[0];

        my $x_dist = ( $excerter->{x} - $p->{x} );
        my $y_dist = ( $excerter->{y} - $p->{y} );
        my $z_dist = ( $excerter->{z} - $p->{z} );

        my $dist = sqrt( $x_dist**2 + $y_dist**2 + $z_dist**2 );


        # force = m1*m2*unit_vector_from_r1_to_r2/distance**2
        # a = f/m1 (module does that for us)

        my $force = (
            $dist == 0
            ? 0
            : G() * $p->{m} * $excerter->{m} / $dist**2
        );

        return ( $force * $x_dist, $force * $y_dist, $force * $z_dist );
    },
    1    # symmetric force
);




rand_particle($sim) foreach(0..5);

my $event = SDL::Event->new();
my $time = SDL::get_ticks;
my $cont = 1;
while ($cont) {

my $oldtime = $time;
  my $now = SDL::get_ticks;

    while ( SDL::Events::poll_event($event) ) {
        $cont = 0
          if $event->type == SDL_QUIT;
    }

    update();

    $sim->iterate_step(1);
    $time = SDL::get_ticks;
  if (($time - $oldtime) < (1000/$fps)) {
    SDL::delay((1000/$fps) - ($time - $oldtime));
  }
}

sub update_bg {
    my $app = shift;
    my $bg =
      SDL::Surface->new( SDL_SWSURFACE, $app->w, $app->h, 32, 0, 0, 0, 0 );

    SDL::Video::fill_rect( $bg, $app_rect,
        SDL::Video::map_RGB( $app->format, 190, 230, 200 ) );

    SDL::Video::display_format($bg);
    return $bg;
}

sub init_particle_surf {
    my $size = shift;
   
    my $bg = SDL::Surface->new( SDL_SWSURFACE, $size+15, $size+15, 32, 0, 0, 0, 255 );
    
    SDL::GFX::Primitives::filled_circle_color($bg, $size/2, $size/2, $size/2 -2, rand_color());

    SDL::Video::display_format($bg);
     my $pixel = SDL::Color->new(0x00, 0x00, 0x00 );
     SDL::Video::set_color_key($bg, SDL_SRCCOLORKEY, $pixel);
    return $bg;
}

sub warp {
    my $p = shift;

    $p->{vx} *= -1       if $p->{x} > ( $app->w - ($p->{m}/2)) && $p->{vx} >0;
    $p->{vy} *= -1       if $p->{y} > ( $app->h - ($p->{m}/2) ) && $p->{vy} > 0;
    $p->{vx} *= -1       if $p->{x} < (0 + ($p->{m}/2) )  && $p->{vx} < 0;
    $p->{vy} *= -1       if $p->{y} < (0  + ($p->{m}/2) ) && $p->{vy} <0;
}

sub update {
    SDL::Video::blit_surface(
        $bg_surf, SDL::Rect->new( 0, 0, $bg_surf->w, $bg_surf->h ),
        $app,     SDL::Rect->new( 0, 0, $app->w,     $app->h )
    );

    foreach my $p ( @{ $sim->{p} } ) {

        #     print Dumper $p;
        update_particle($p);
        warp($p);
    }

    SDL::Video::flip($app);
}

sub rand_color {
        return rand( 0xFFFFFF)  ;

}

sub update_particle {
    my $p    = shift;
    my $size = $p->{m};
    $color[ $p->{n} ] = init_particle_surf($size)
      if not defined $color[ $p->{n} ];

    my $c = $color[ $p->{n} ];

    my $new_part_rect = SDL::Rect->new( 0, 0, $size, $size );

    SDL::Video::blit_surface(
        $c,
        $new_part_rect,
        $app,
        SDL::Rect->new(
            $p->{x} - ($size / 2),
            $p->{y} - ($size / 2),
            $app->w, $app->h
        )
    );

#SDL::Video::update_rects ( $app, $old_part_rect[$p->{n}], $new_part_rect ) if( defined $old_part_rect[$p->{n}] );
    $old_part_rect[ $p->{n} ] = $new_part_rect;
}

sub rand_particle
{
    
    my $sim = shift;

my $t = $par++;
$sim->add_particle ( 
    x  => rand( $app->w ) +50,
    y  => rand( $app->h) +50,
    z  => 0,
    vx => rand(1) - rand(1),
    vy => rand(1) -rand(1),
    vz => 0,
    m  => rand(36)+12,
    n  => $t,
);


}
