use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Gravong',
    license             => 'perl',
    dist_author         => q{Kartik Thakore  <thakore.kartik@gmail.com>},
    dist_version_from   => 'lib/Gravong.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => 
    {
           'SDL' => '2.3_5',
    },
    add_to_cleanup      => [ 'Gravong-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
