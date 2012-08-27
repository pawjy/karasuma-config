use strict;
BEGIN {
    my $file_name = __FILE__; $file_name =~ s{[^/\\]+$}{}; $file_name ||= '.';
    $file_name .= '/../config/perl/libs.txt';
    if (-f $file_name) {
        open my $file, '<', $file_name or die "$0: $file_name: $1";
        unshift @INC, split /:/, <$file>;
    }
}
use warnings;
use Karasuma::Config::Web::ServerStatus;
use Test::X1;
use Test::More;

{
    package test::app::mock;

    sub requires_request_method {
        
    }

    sub send_plain_text {
        $_[0]->{status_code} = 200;
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

    my $app = bless {}, 'test::app::mock';
    Karasuma::Config::Web::ServerStatus->process($app, ['server', 'avail']);
    ok $app->{status_code};

    $app->{params} = {action => 'up'};
    Karasuma::Config::Web::ServerStatus->process_admin($app, ['admin', 'server', 'avail']);
    Karasuma::Config::Web::ServerStatus->process($app, ['server', 'avail']);
    is $app->{status_code}, 200;

    $app->{params} = {action => 'down'};
    Karasuma::Config::Web::ServerStatus->process_admin($app, ['admin', 'server', 'avail']);
    Karasuma::Config::Web::ServerStatus->process($app, ['server', 'avail']);
    is $app->{status_code}, 503;

    $app->{params} = {action => 'up'};
    Karasuma::Config::Web::ServerStatus->process_admin($app, ['admin', 'server', 'avail']);
    Karasuma::Config::Web::ServerStatus->process($app, ['server', 'avail']);
    is $app->{status_code}, 200;

    done $c;
} n => 4;

run_tests;
