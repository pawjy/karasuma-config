use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->child ('t_deps/modules/*/lib');
use Karasuma::Config::Web::ServerStatus;
use Test::X1;
use Test::More;
use Path::Class;
use File::Temp;

{
    package test::app::mock;

    sub requires_request_method {
        
    }

    sub send_plain_text {
        $_[0]->{status_code} = 200;
    }

    sub throw {
        #
    }

    sub throw_error {
        $_[0]->{status_code} = $_[1];
    }

    sub bare_param {
        return $_[0]->{params}->{$_[1]};
    }
}

test {
    my $c = shift;

    my $d = dir(File::Temp->newdir);

    my $app = bless {}, 'test::app::mock';
    Karasuma::Config::Web::ServerStatus->process($app, ['server', 'avail'], $d);
    ok $app->{status_code};

    $app->{params} = {action => 'up'};
    Karasuma::Config::Web::ServerStatus->process_admin($app, ['admin', 'server', 'avail'], $d);
    Karasuma::Config::Web::ServerStatus->process($app, ['server', 'avail'], $d);
    is $app->{status_code}, 200;

    $app->{params} = {action => 'down'};
    Karasuma::Config::Web::ServerStatus->process_admin($app, ['admin', 'server', 'avail'], $d);
    Karasuma::Config::Web::ServerStatus->process($app, ['server', 'avail'], $d);
    is $app->{status_code}, 503;

    $app->{params} = {action => 'up'};
    Karasuma::Config::Web::ServerStatus->process_admin($app, ['admin', 'server', 'avail'], $d);
    Karasuma::Config::Web::ServerStatus->process($app, ['server', 'avail'], $d);
    is $app->{status_code}, 200;

    done $c;
} n => 4;

run_tests;
