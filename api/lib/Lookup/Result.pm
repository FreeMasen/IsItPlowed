package Lookup::Result;
use Moose;
use JSON;
use namespace::autoclean;

has 'web_response' => (
    is => 'ro',
    isa => 'HTTP::Response',
    required => 1
);

has 'decoded_result' => (
    is => 'ro',
    isa => 'Ref',
    lazy => 1,
    builder => '_decoded_result',
);

sub _decoded_result {
    my $self = shift;

    die "request failed!" unless $self->success;
    return JSON->new->utf8(0)->decode($self->web_response->content);
}

sub success {
    my $self = shift;
    return $self->web_response->is_success;
}

sub count {
    my $self = shift;

    return scalar(@{$self->decoded_result->{features}});
}

__PACKAGE__->meta->make_immutable;
1;
