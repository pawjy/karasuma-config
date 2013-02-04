package Karasuma::Config::Web::ServerStatus;
use strict;
use warnings;
our $VERSION = '1.0';
use Karasuma::Config::ServerStatus;

sub process {
    my ($self, $app, $path, $status_d) = @_;
    
    # /server/avail
    if (defined $path->[1] and $path->[1] eq 'avail' and
            not defined $path->[2]) {
        my $action = Karasuma::Config::ServerStatus->new_from_status_d($status_d);
        if ($action->is_available) {
            $app->send_plain_text('200 OK');
            return $app->throw;
        } else {
            return $app->throw_error(503, reason_phrase => 'Server is up but is under maintenance');
        }
    }

    return $app->throw_error(404);
}

# You should protect this action by HTTP auth or something, if
# required, before invocation!
sub process_admin {
    my ($self, $app, $path, $status_d) = @_;
    
    # /admin/server/avail
    if (defined $path->[2] and $path->[2] eq 'avail' and
        not defined $path->[3]) {
        $app->requires_request_method({POST => 1});
        
        my $action = $app->bare_param('action') || '';
        if ($action eq 'up') {
            Karasuma::Config::ServerStatus->new_from_status_d($status_d)->up;
            return $app->throw_error(200, reason_phrase => 'Done');
        } elsif ($action eq 'down') {
            Karasuma::Config::ServerStatus->new_from_status_d($status_d)->down;
            return $app->throw_error(200, reason_phrase => 'Done');
        } else {
            return $app->throw_error(400, reason_phrase => 'Bad |action|');
        }
    }

    return $app->throw_error(404);
}

1;

__END__

# Startup
use Karasuma::Config::ServerStatus;
use Path::Class;
Karasuma::Config::ServerStatus->new_from_status_d(dir("path/to/status"))->reset;

POST /admin/server/avail?action=up
POST /admin/server/avail?action=down
GET /server/avail
