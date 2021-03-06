use 5.008003;
use warnings;
use strict;
use ExtUtils::MakeMaker;


my %prereqs_os_specific;
my %test_prereqs_os_specific;
if ( $^O eq 'MSWin32' ) {
    %prereqs_os_specific = (
        'Win32::Console' => 0,
    );
}
else {
    %prereqs_os_specific = (
        'Term::ReadKey'  => 0,
    );
}


WriteMakefile(
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.008003',
    LICENSE          => 'perl',
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
              type => 'git',
              web  => 'https://github.com/kuerbis/Term-ReadLine-Simple',
              url  => 'https://github.com/kuerbis/Term-ReadLine-Simple.git',
            },
        },
    },
    AUTHOR           => 'Matthaeus Kiem <cuer2s@gmail.com>',
    NAME             => 'Term::ReadLine::Simple',
    ABSTRACT_FROM    => 'lib/Term/ReadLine/Simple.pm',
    VERSION_FROM     => 'lib/Term/ReadLine/Simple.pm',
    EXE_FILES        => [],
    BUILD_REQUIRES   => {
        'File::Spec::Functions' => 0,
        'FindBin'               => 0,
        'Test::More'            => 0,
        'Test::Fatal'           => 0,
    },
    PREREQ_PM => {
        'strict'            => 0,
        'warnings'          => 0,
        'Carp'              => 0,
        'Encode'            => 0,
        'Encode::Locale'    => 0,
        'Exporter'          => 0,
        'List::Util'        => '1.33',
        'Text::LineFold'    => 0,
        'Unicode::GCString' => 0,
        %prereqs_os_specific,
    },
    dist  => {
        COMPRESS => 'gzip',
        SUFFIX   => '.gz',
        TARFLAGS => '--format=gnu -cvf',
    },
    clean => {
        FILES => 'Term-ReadLine-Simple-*',
    },
);
