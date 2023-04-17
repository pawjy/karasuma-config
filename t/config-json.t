use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->child ('t_deps/modules/*/lib');
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
} n => 10, name => 'methods';

test {
    my $c = shift;

    my $config = Karasuma::Config::JSON->new_from_config_data({
        hoge => 'abc',
        aaa => 'foo',
        'ab json' => 'abaa.json',
    });
    $config->base_d(file(__FILE__)->dir->subdir('data')->subdir('test1'));
    is $config->get_text('hoge'), 'abc';
    is $config->get_text('aaa'), 'foo';
    eq_or_diff $config->get_file_json('ab json'), {
        hoge => ['aaa', "\x{4e00}"],
        fuga => 124,
    };

    done $c;
} n => 3, name => 'new_from_config_data';

run_tests;
