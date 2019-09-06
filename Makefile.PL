use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'SWC_BATCH_CHECK',
    AUTHOR              => q{Damien OHalloran <damienoh@gwu.edu>},
    VERSION_FROM        => 'lib/SWC_BATCH_CHECK.pm',
    LICENSE             => 'gpl_2',
    PL_FILES            => {},
    MIN_PERL_VERSION    => 5.006,
    CONFIGURE_REQUIRES  => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Sys::Hostname'           => 0,
        'File::Basename'          => 0,
        'Term::ANSIColor'         => 0,
        'Moose'                   => 2.0,
        'Modern::Perl'            => 1.0,
        'List::Util'              => 0,
        'Win32::Console::ANSI'    => 0
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'SWC_BATCH_CHECK-*' },
);
