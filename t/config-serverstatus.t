use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->child ('t_deps/modules/*/lib');
use Karasuma::Config::ServerStatus;
use Test::X1;
use Test::More;
use File::Temp;
use Path::Class;

test {
    my $c = shift;

    my $d = dir(File::Temp->newdir);
    my $config = Karasuma::Config::ServerStatus->new_from_status_d($d);
    $config->reset;
    ok !$config->is_available;

    $config->up;
    ok $config->is_available;
    
    $config->down;
    ok !$config->is_available;

    $config->up;
    ok $config->is_available;

    done $c;
} n => 4;

run_tests;
