#!/usr/bin/perl
use strict;
BEGIN {
    my $file_name = __FILE__; $file_name =~ s{[^/]+$}{}; $file_name ||= '.';
    my $dir_name = $file_name;
    $file_name .= '/../config/perl/libs.txt';
    if (-f $file_name) {
        open my $file, '<', $file_name or die "$0: $file_name: $!";
        unshift @INC, split /:/, scalar <$file>;
    }
    unshift @INC, "$dir_name/../lib", glob "$dir_name/../modules/*/lib";
}
use warnings;
use Karasuma::Config::JSON;
binmode STDOUT, qw(:encoding(utf-8));

my ($key, $type) = @ARGV;
die "Usage: KARASUMA_CONFIG_JSON=path/to/config.json KARASUMA_CONFIG_FILE_DIR_NAME=path/to/config/files $0 key type\n" if not $key or not $type;

my $config = Karasuma::Config::JSON->new_from_env;
my $method = 'get_' . $type;
print $config->$method($key);
