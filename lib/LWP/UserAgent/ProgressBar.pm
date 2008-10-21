package LWP::UserAgent::ProgressBar;

use strict;
use warnings;
use Term::ProgressBar;


use base 'LWP::UserAgent';


our $VERSION = '0.04';

sub post_with_progress {
    my ($self, $url, $form, %args) = @_;
    $self->_request_with_progress('post', $url, $form, %args);
}

sub get_with_progress {
    my ($self, $url, %args) = @_;
    $self->_request_with_progress('get', $url, undef, %args);
}

sub _request_with_progress {
    my ($self, $req, $url, $form, %args) = @_;

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
    $args{':content_cb'} =  sub {
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

    };
    $args{':read_size_hint'} = 8192;

    my $response = $self->$req($url, $req eq 'get' ? (%$form, %args) : ($form, %args));

    print "\n";
    $response->content($content);
    $response;
}


1;


__END__



=head1 NAME

LWP::UserAgent::ProgressBar - An LWP user agent that can display a progress bar

=head1 SYNOPSIS

    my $response = LWP::UserAgent::ProgressBar->new->get_with_progress($url);
    $response->is_success or die "couldn't get $url\n";
    my $content = $response->content;

=head1 DESCRIPTION

This class is a subclass of L<LWP::UserAgent> that provides one additional
method, descibed below.

=head1 METHODS

=over 4



=item get_with_progress

Takes the same arguments as L<LWP::UserAgent>'s C<get()>, but overrides the
C<:content_cb> and C<:read_size_hint> arguments. During download, a progress
bar is displayed.

=item post_with_progress

Takes the same arguments as L<LWP::UserAgent>'s C<post()>, but overrides the
C<:content_cb> and C<:read_size_hint> arguments. During download, a progress
bar is displayed.

=back

LWP::UserAgent::ProgressBar inherits from L<LWP::UserAgent>.

The superclass L<LWP::UserAgent> defines these methods and functions:

    new(), _agent(), _need_proxy(), _new_response(),
    _process_colonic_headers(), _request_sanity_check(), agent(), clone(),
    conn_cache(), cookie_jar(), credentials(), default_header(),
    default_headers(), env_proxy(), from(), get(), get_basic_credentials(),
    head(), is_protocol_supported(), max_redirect(), max_size(), mirror(),
    no_proxy(), parse_head(), post(), prepare_request(), progress(),
    protocols_allowed(), protocols_forbidden(), proxy(), redirect_ok(),
    request(), requests_redirectable(), send_request(), simple_request(),
    timeout(), use_alarm(), use_eval()

The superclass L<LWP::MemberMixin> defines these methods and functions:

    _elem()

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHORS

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>
Ktat C<< ktat at cpan.org >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by the authors.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

