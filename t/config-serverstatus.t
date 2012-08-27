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
use Karasuma::Config::ServerStatus;
use Test::X1;
use Test::More;

test {
    my $c = shift;

    my $config = Karasuma::Config::ServerStatus->new;
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
