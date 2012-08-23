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
use Karasuma::Config::JSON;
use Test::X1;
use Test::More;
use Test::Differences;
use Path::Class;

test {
    my $c = shift;

    my $json_f = file(__FILE__)->dir->subdir('data')->file('test1.json');
    my $config = Karasuma::Config::JSON->new_from_json_f($json_f);
    $config->base_d($json_f->dir->subdir('test1'));

    is $config->get_text('notfound'), undef;
    is $config->get_text('hoge'), 'fuga';

    is $config->get_file_text('fuga'), "abc\x{4e00}\naaa\n";
    is $config->get_file_text('FUGA'), undef;
    is $config->get_file_base64_text('aa-aa'), "abc\x{4e00}\naaa";
    is $config->get_file_base64_text('aaaa'), undef;

    eq_or_diff $config->get_file_json('ab json'), {
        hoge => ['aaa', "\x{4e00}"],
        fuga => 124,
    };
    eq_or_diff $config->get_file_json('abjson'), undef;
    eq_or_diff $config->get_file_json_base64values('axxa.json'), {
        fuga => "aaa bbb",
        hoge => "\x{4e00}",
    };
    eq_or_diff $config->get_file_json_base64values('axxa'), undef;

    done $c;
};

run_tests;
