package Karasuma::Config::JSON;
use strict;
use warnings;
use Path::Class;
use Encode;
use MIME::Base64;
use JSON::Functions::XS qw(file2perl);

sub new_from_env {
    my $file_name = $ENV{KARASUMA_CONFIG_JSON} || die "|KARASUMA_CONFIG_JSON| is not set";
    my $service = $_[0]->new_from_json_f(file($file_name));
    my $dir_name = $ENV{KARASUMA_CONFIG_FILE_DIR_NAME}
        || die "|KARASUMA_CONFIG_FILE_DIR_NAME| is not set";
    $service->base_d(dir($dir_name));
    return $service;
}

sub new_from_json_f {
    return bless {json_f => $_[1]}, $_[0];
}

sub base_d {
    if (@_ > 1) {
        $_[0]->{base_d} = $_[1];
    }
    return $_[0]->{base_d};
}

sub config_data {
    my $self = shift;
    return $self->{config_data} ||= file2perl $self->{json_f};
}

sub get_text {
    my ($self, $key) = @_;
    return $self->config_data->{$key}; # or undef
}

sub get_file_text {
    my ($self, $key) = @_;
    return $self->{file_text}->{$key} if exists $self->{file_text}->{$key};
    my $file_name = $self->config_data->{$key};
    return $self->{file_text}->{$key} = undef unless defined $file_name;
    my $f = $self->base_d->file($file_name);
    return $self->{file_text}->{$key} = undef unless -f $f;
    return $self->{file_text}->{$key} = decode 'utf-8', scalar $f->slurp;
}

sub get_file_base64_text {
    my ($self, $key) = @_;
    return $self->{file_base64_text}->{$key}
        if exists $self->{file_base64_text}->{$key};
    my $file_name = $self->config_data->{$key};
    return $self->{file_base64_text}->{$key} = undef unless defined $file_name;
    my $f = $self->base_d->file($file_name);
    return $self->{file_base64_text}->{$key} = undef unless -f $f;
    return $self->{file_base64_text}->{$key}
        = decode 'utf-8', decode_base64 scalar $f->slurp;
}

sub get_file_json {
    my ($self, $key) = @_;
    return $self->{file_json}->{$key} if exists $self->{file_json}->{$key};
    my $file_name = $self->config_data->{$key};
    return $self->{file_json}->{$key} = undef unless defined $file_name;
    my $f = $self->base_d->file($file_name);
    return $self->{file_json}->{$key} = undef unless -f $f;
    return $self->{file_json}->{$key} = file2perl $f;
}

sub get_file_json_base64values {
    my ($self, $key) = @_;
    return $self->{file_json_base64values}->{$key}
        if exists $self->{file_json_base64values}->{$key};
    my $file_name = $self->config_data->{$key};
    return $self->{file_json_base64values}->{$key} = undef
        unless defined $file_name;
    my $f = $self->base_d->file($file_name);
    return $self->{file_json_base64values}->{$key} = undef unless -f $f;
    my $values = file2perl $f;
    for (keys %$values) {
        next unless defined $values->{$_};
        $values->{$_} = decode 'utf-8', decode_base64 $values->{$_};
    }
    return $self->{file_json_base64values}->{$key} = $values;
}

1;

