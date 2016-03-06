package API;
use Moose;
use Plack::Request;
use Plack::Response;
use Area::Test;
use JSON;
use namespace::autoclean;

has 'response' => (
    is => 'ro',
    isa => 'Plack::Response',
    lazy => 1,
    builder => '_response',
);

sub _response { return Plack::Response->new() }

sub run {
    my $self = shift;
    my $env = shift;

    my $req = Plack::Request->new($env);
    my $resp = $self->response;

    my $path = $req->path_info;

    if ($path =~ qr{^/area/test}) {
        (my $stripped = $path) =~ s{^/area/test/}{};
        return Area::Test->new(request => $req)->do_it(split(/\./, $stripped));
    }
    if ($path =~ qr{^/county/scott/lookup\.json$}) {
        $resp->status('200');
        $resp->headers({'Content-Type' => 'application/json'});
        $resp->body('["Hello","World"]');
        return $resp->finalize;
    }

    $resp->status('404');
    $resp->headers({'Content-Type' => 'application/json'});
    my $body = { 'message' => "$path not found" };
    my $text = JSON->new->utf8(0)->encode($body);
    $resp->body($text);
    return $resp->finalize;

}

__PACKAGE__->meta->make_immutable;
1;
