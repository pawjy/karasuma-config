package Karasuma::Config::ServerStatus;
use strict;
use warnings;
our $VERSION = '1.0';
use Path::Class;

sub new {
    return bless {}, $_[0];
}

sub status_d {
    return $_[0]->{status_d} ||= file(__FILE__)->dir->parent->parent->parent->subdir('local')->subdir('state', ($ENV{KARASUMA_CONFIG_SERVER_STATUS_KEY} ? ($ENV{KARASUMA_CONFIG_SERVER_STATUS_KEY}) : ()));
}

sub up_f {
    return $_[0]->status_d->file('up');
}

sub is_available {
    return -f $_[0]->up_f;
}

sub reset {
    $_[0]->down;
}

sub up {
    my $up_f = $_[0]->up_f;
    $up_f->dir->mkpath;
    my $file = $up_f->openw;
    print $file time;
    close $file;
}

sub down {
    my $up_f = $_[0]->up_f;
    unlink $up_f if -f $up_f;
}

1;
