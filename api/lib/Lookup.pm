package Lookup;
use Moose;
use LWP::UserAgent;
use Lookup::Result;
use namespace::autoclean;

has 'base_url' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has 'map' => (
    is => 'ro',
    isa => 'HashRef',
    required => 1,
);

has 'agent' => (
    is => 'ro',
    isa => 'LWP::UserAgent',
    lazy => 1,
    builder => '_ua'
);

sub _ua { LWP::UserAgent->new }

sub fetch {
    my $self = shift;
    my %param = @_;
    my $query = $self->_query(%param);
    return Lookup::Result->new(
        web_response => $self->_ua->get($self->base_url . $query)
    );
};

sub _query {
    my $self = shift;
    my %param = @_;

    my $map = $self->map;

    my @query;
    for my $field (keys %$map) {
        next unless my $value = $param{$field};
        next unless my $mapper = $map->{$field};
     
        $value = '%27' . $value . '%27' if $mapper->{quote};
        push @query, $mapper->{field} . "%3D" . $value;
    }

    return 'where=' . join('+AND+', @query);
}

__PACKAGE__->meta->make_immutable;
1;
