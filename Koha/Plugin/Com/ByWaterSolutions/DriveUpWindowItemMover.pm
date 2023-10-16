package Koha::Plugin::Com::ByWaterSolutions::DriveUpWindowItemMover;

## It's good practice to use Modern::Perl
use Modern::Perl;

## Required for all plugins
use base qw(Koha::Plugins::Base);

use Mojo::JSON qw(decode_json);
use YAML::XS qw(Load);

use Koha::Items;

## Here we set our plugin version
our $VERSION         = "{VERSION}";
our $MINIMUM_VERSION = "{MINIMUM_VERSION}";

our $metadata = {
    name            => 'Drive Up Window Item Mover',
    author          => 'Kyle M Hall',
    date_authored   => '2009-01-27',
    date_updated    => "1900-01-01",
    minimum_version => $MINIMUM_VERSION,
    maximum_version => undef,
    version         => $VERSION,
    description     => 'Move items between main libraries and drive up windows automatically.'
};

sub new {
    my ($class, $args) = @_;

    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    my $self = $class->SUPER::new($args);

    return $self;
}

sub after_circ_action {
    my ($self, $params) = @_;

    my $action   = $params->{action};
    my $checkout = $params->{payload}->{checkout};

    return unless $action eq 'checkin';

    my $branches_to_windows = Load $self->retrieve_data('mapping');
    my $windows_to_branches = {map { $branches_to_windows->{$_} => $_ } keys %$branches_to_windows};

    my $item = $checkout->item;

    if (my $housing_library = $windows_to_branches->{$item->holdingbranch}) {

        # Item is currently at a pickup window
        if ($item->holds({found => 'W'})->count == 0) {
            $item->update({holdingbranch => $housing_library});

            my $transfer = $item->get_transfer;
            $transfer->receive if $transfer;
        }
    }
}

sub cronjob_nightly {
    my ( $self ) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(qq{UPDATE items LEFT JOIN reserves USING ( itemnumber ) SET holdingbranch = homebranch WHERE holdingbranch = ? AND ( found != "W" AND found != 'T' )};

    my $branches_to_windows = Load $self->retrieve_data('mapping');
    my $windows_to_branches = {map { $branches_to_windows->{$_} => $_ } keys %$branches_to_windows};

    foreach my $window ( keys %$windows_to_branches ) {
        $sth->execute($window);
    }
}

=head
sub after_item_action {
    my ($self, $params) = @_;

    my $action = $params->{action};
    my $item   = $params->{item};
}

sub after_hold_action {
    my ($self, $params) = @_;

    my $action = $params->{action};
    my $hold   = $params->{payload}->{hold};
}
=cut

sub configure {
    my ($self, $args) = @_;
    my $cgi = $self->{'cgi'};

    unless ($cgi->param('save')) {
        my $template = $self->get_template({file => 'configure.tt'});

        $template->param(mapping => $self->retrieve_data('mapping'),);

        $self->output_html($template->output());
    }
    else {
        $self->store_data({mapping => $cgi->param('mapping'),});
        $self->go_home();
    }
}

## This is the 'install' method. Any database tables or other setup that should
## be done when the plugin if first installed should be executed in this method.
## The installation method should always return true if the installation succeeded
## or false if it failed.
sub install() {
    my ($self, $args) = @_;

    return 1;
}

## This is the 'upgrade' method. It will be triggered when a newer version of a
## plugin is installed over an existing older version of a plugin
sub upgrade {
    my ($self, $args) = @_;

    return 1;
}

## This method will be run just before the plugin files are deleted
## when a plugin is uninstalled. It is good practice to clean up
## after ourselves!
sub uninstall() {
    my ($self, $args) = @_;

    return 1;
}

1;
