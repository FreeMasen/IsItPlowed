package Area::Test;
use Moose;
use Plack::Response;
use JSON;
use namespace::autoclean;

has 'request' => (
    is => 'ro',
    isa => 'Plack::Request',
    required => 1,
    handles => [ qw(parameters) ]
);

sub do_it {
    my $self = shift;
    my $resource = shift;
    my $type = shift;

    return $self->bad_request($type) unless $type eq 'json';

    return $self->lookup() if $resource eq 'lookup';
    return $self->route() if $resource eq 'route';

    return $self->not_found($resource);
}

sub route {
    my $self = shift;

    my $route_id = $self->parameters->{route_id} || '';
    my $place_id = $self->parameters->{place_id} || '';
    my $min = $self->parameters->{minimal} || '';

    return $self->routes() unless $self->parameters->values;

    my $response = Plack::Response->new();
    my $obj = {};
    if ($route_id eq 'test-route') {
        $obj->{current_info} = {
            point => {
                lat => '44.74254324',
                lng => '-93.36223377',
            },
            speed => '25mph',
        };

        if ($place_id eq 'testarea:1234') {
            $obj->{time_to_intercept} = '2.5mins';
        }
        elsif ($place_id) {
            $obj->{time_to_intercept} = 'infinity';
        }

        unless ($min) {
            $obj->{geometry} = _geometry();
        }

        $response->status('200');
    }
    elsif ($route_id eq 'another-route') {
        $obj->{current_info} = {
            point => {
                lat => '44.74252324',
                lng => '-93.36223377',
            },
            speed => '25mph',
        };

        if ($place_id) {
            $obj->{time_to_intercept} = 'infinity';
        }

        unless ($min) {
            $obj->{geometry} = _geometry();
        }

        $response->status('200');
    }
    elsif ($route_id eq 'inactive-route') {
        $obj->{current_info} = {
            inactive => 1,
        };

        if ($place_id eq 'testarea:1234') {
            $obj->{time_to_intercept} = 'inifinity';
        }

        unless ($min) {
            $obj->{geometry} = _geometry();
        }
        $response->status('200');
    }
    else {
        $obj = {message => 'no records found'};
        $response->status('404');
    }
 
    my $text = JSON->new->utf8(0)->encode($obj);
    $response->body($text);
    $response->header({'Content-Type' => 'application/json'});
    return $response->finalize;
}

sub _geometry {
    return [sort { $a->{lng} <=> $b->{lng} } (
        {
            lat => 44.76007,
            lng => -93.38913,
        },
        {
            lat => 44.7601,
            lng => -93.39212,
        },
        {
            lat => 44.76022,
            lng => -93.39232,
        },
        {
            lat => 44.76048,
            lng => -93.38793,
        },
        {
            lat => 44.76053,
            lng => -93.40207,
        },
        {
            lat => 44.76077,
            lng => -93.38677,
        },
        {
            lat => 44.75985,
            lng => -93.38993,
        },
        {
            lat => 44.75985,
            lng => -93.39033,
        },
        {
            lat => 44.75985,
            lng => -93.39033,
        },
    )];
}

sub lookup {
    my $self = shift;
    my $q = $self->parameters->{q};

    my $response = Plack::Response->new();
    my $obj = {};
    if ($q eq 'found-one') {
        $obj = {
            point => {
                lat => '44.7599348',
                lng => '-93.391775'
            },
            id => 'testarea:1234',
            name => '8740 McColl Drive, Savage, MN',
            snow_emergency => {
                active => 1,
                route_id => 'test-route',
            },
        };
        $response->status('200');
    }
    elsif ($q eq 'found-many') {
        $obj = {message => 'too many records found'};
        $response->status('400');
    }
    else {
        $obj = {message => 'no records found'};
        $response->status('404');
    }
    my $text = JSON->new->utf8(0)->encode($obj);
    $response->body($text);
    $response->header({'Content-Type' => 'application/json'});
    return $response->finalize;
}

sub routes {
    my $self = shift;
    my $resource = shift;

    my $response = Plack::Response->new();
    my $obj = {
        routes => [
            qw(test-route another-route inactive-route)
        ],
    };
    my $text = JSON->new->utf8(0)->encode($obj);
    $response->body($text);
    $response->status('200');
    return $response->finalize;
}

sub not_found {
    my $self = shift;
    my $resource = shift;

    my $response = Plack::Response->new();
    my $obj = {message => "no such resource: $resource"};
    my $text = JSON->new->utf8(0)->encode($obj);
    $response->body($text);
    $response->status('404');
}

sub bad_request {
    my $self = shift;
    my $type = shift;

    my $response = Plack::Response->new();
    my $obj = {message => "no such data type: $type"};
    my $text = JSON->new->utf8(0)->encode($obj);
    $response->body($text);
    $response->status('404');
    return $response->finalize;
}

__PACKAGE__->meta->make_immutable;
1;
