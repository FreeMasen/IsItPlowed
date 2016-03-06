#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Plack::Builder;
use API;

builder {
    mount '/api' => sub { API->new()->run(@_) };
};
