package Dancer2::Template::Xslate;

use v5.8;
use strict;
use warnings FATAL => 'all';
use utf8;

use Moo;

use Carp qw(croak);
use Dancer2::Core::Types qw(InstanceOf);
use Text::Xslate;
use File::Spec::Functions qw(abs2rel file_name_is_absolute);

our $VERSION = 'v0.2.0'; # VERSION
# ABSTRACT: Text::Xslate template engine for Dancer2

with 'Dancer2::Core::Role::Template';

has '+default_tmpl_ext' => (
    default => sub { 'tx' }
);
has '+engine' => (
    isa => InstanceOf['Text::Xslate']
);

sub _build_engine {
    my ($self) = @_;
    my $settings = $self->settings || {};

    my $engine_config;
    $engine_config = $settings->{'engines'}{'template'}{'Xslate'} if( exists($settings->{'engines'}{'template'}{'Xslate'}) );
    $engine_config ||= {};

    my %engine_config = %{$engine_config};

    my @path = ($self->views);
    $engine_config{'path'} = \@path;

    return Text::Xslate->new(%engine_config);
}

sub render {
    my ($self, $tmpl, $vars) = @_;

    my $xslate = $self->engine;
    my $content = eval {
        if ( ref($tmpl) eq 'SCALAR' ) {
            $xslate->render_string($$tmpl, $vars)
        }
        else {
            my $rel_path = file_name_is_absolute($tmpl)
                ? abs2rel($tmpl, $self->views)
                : $tmpl;
            $xslate->render($rel_path, $vars);
        }
    };
    $@ and croak $@;

    return $content;
}

1;
