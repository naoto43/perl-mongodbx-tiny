use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'MongoDBx::Tiny',
    AUTHOR              => q{Naoto ISHIKAWA <toona at seesaa.co.jp>},
    VERSION_FROM        => 'lib/MongoDBx/Tiny.pm',
    ABSTRACT_FROM       => 'lib/MongoDBx/Tiny.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'MongoDBx-Tiny-*' },
);
