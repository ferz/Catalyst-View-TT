package Catalyst::View::TT;

use strict;
use base qw/Catalyst::Base/;
use Template;
use Template::Timer;
use NEXT;

our $VERSION = '0.07';

__PACKAGE__->mk_accessors('template');

=head1 NAME

Catalyst::View::TT - Template View Class

=head1 SYNOPSIS

    # use the helper
    create.pl view TT TT

    # lib/MyApp/View/TT.pm
    package MyApp::View::TT;

    use base 'Catalyst::View::TT';

    __PACKAGE__->config->{DEBUG} = 'all';

    1;
    
    $c->forward('MyApp::View::TT');

=head1 DESCRIPTION

This is the C<Template> view class. Your subclass should inherit 
from this class. If you want to override TT config settings, you 
can do it there by setting __PACKAGE__->config->{OPTION} as shown
in the synopsis. Of interest might be EVAL_PERL, which is disabled
by default, and LOAD_TEMPLATES, which is set to use the provider.

If you want to use EVAL perl, add something like this:

    __PACKAGE__->config->{EVAL_PERL} = 1;
    __PACKAGE__->config->{LOAD_TEMPLATES} = undef;

=head2 METHODS

=cut

sub new {
    my $self = shift;
    my $c    = shift;
    $self = $self->NEXT::new(@_);
    my $root   = $c->config->{root};
    my %config = (
        EVAL_PERL    => 0,
        INCLUDE_PATH => [ $root, "$root/base" ],
        %{ $self->config() }
    );

    unless ( $c->debug && not exists $config{CONTEXT} ) {
       $config{CONTEXT} = Template::Timer->new(%config);
    }

    $self->template( Template->new( \%config ) );
    return $self;
}

=head3 process

Renders the template specified in $c->stash->{template} or $c->request->match
to $c->response->output.

=cut

sub process {
    my ( $self, $c ) = @_;
    $c->res->headers->content_type('text/html;charset=utf8');
    my $output;
    my $name = $c->stash->{template} || $c->req->match;
    unless ($name) {
        $c->log->debug('No template specified for rendering') if $c->debug;
        return 0;
    }
    $c->log->debug(qq/Rendering template "$name"/) if $c->debug;
    unless (
        $self->template->process(
            $name,
            {
                %{ $c->stash },
                base => $c->req->base,
                c    => $c,
                name => $c->config->{name}
            },
            \$output
        )
      )
    {
        my $error = $self->template->error;
        $error = qq/Couldn't render template "$error"/;
        $c->log->error($error);
        $c->errors($error);
    }
    $c->res->output($output);
    return 1;
}

=head3 config

This allows your view subclass to pass additional settings to the
TT config hash.

=cut 

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>
Marcus Ramberg, C<mramberg@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
