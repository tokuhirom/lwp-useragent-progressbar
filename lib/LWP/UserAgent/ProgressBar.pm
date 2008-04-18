package LWP::UserAgent::ProgressBar;

use strict;
use warnings;
use Term::ProgressBar;


use base 'LWP::UserAgent';


our $VERSION = '0.01';


sub get_with_progress {
    my ($self, $url, %args) = @_;

    # don't buffer the prints to make the status update
    local $| = 1;

    my $bar_name;
    if (defined $args{bar_name}) {
        $bar_name = $args{bar_name};
        delete $args{bar_name};
    }

    my $progress = Term::ProgressBar->new({
        count => 1024,
        (defined $bar_name ? (name => $bar_name) : ()),
        ETA   => 'linear',
    });
   $progress->minor(0);           # turns off the floating asterisks.
   $progress->max_update_rate(1); # only relevant when ETA is used.

    my $did_set_target = 0;
    my $received_size  = 0;
    my $next_update    = 0;
    my $content        = '';

    delete $args{$_} for qw(:content_cb :read_size_hint);

    my $response = $self->get(
        $url,
        %args,
        ':content_cb' => sub {
            my ($data, $cb_response, $protocol) = @_;

            unless ($did_set_target) {
                if (my $content_length = $cb_response->content_length) {
                    $progress->target($content_length);
                    $did_set_target = 1;
                } else {
                    $progress->target($received_size + 2 * length $data);
                }
            }

            $received_size += length $data;
            $content .= $data;

            $next_update = $progress->update($received_size) if
                $received_size >= $next_update;

        },
        ':read_size_hint' => 8192,
    );
    print "\n";
    $response->content($content);
    $response;
}


1;


__END__

{% USE p = PodGenerated %}

=head1 NAME

{% p.package %} - An LWP user agent that can display a progress bar

=head1 SYNOPSIS

    my $response = LWP::UserAgent::ProgressBar->new->get_with_progress($url);
    $response->is_success or die "couldn't get $url\n";
    my $content = $response->content;

=head1 DESCRIPTION

This class is a subclass of L<LWP::UserAgent> that provides one additional
method, descibed below.

{% p.write_inheritance %}

=head1 METHODS

=over 4

{% p.write_methods %}

=item get_with_progress

Takes the same argumentes as L<LWP::UserAgent>'s C<get()>, but overrides the
C<:content_cb> and C<:read_size_hint> arguments. During download, a progress
bar is displayed.

=back

{% PROCESS standard_pod %}

=cut

