package Kwiki::Weather;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
use mixin 'Kwiki::Installer';

our $VERSION = '0.03';

const class_title => 'Weather Report';
const class_id => 'weather';
const cgi_class => 'Kwiki::Weather::CGI';
field 'geo_weather';

sub register {
    my $registry = shift;
    $registry->add(action => 'weather');
    $registry->add(toolbar => 'weather',
      template => 'weather_button.html');
    $registry->add(wafl => weather => 'Kwiki::Weather::Wafl');
}

sub weather {
    my $zipcode = $self->cgi->zipcode;
    return $self->render_screen(
        content_pane => 'weather_error.html'
    ) unless $zipcode =~ /^\d{5}$/;
    require Geo::Weather;
    my $weather = Geo::Weather->new;
    $weather->get_weather($zipcode);
    $self->geo_weather($weather);
    $self->render_screen;
}

package Kwiki::Weather::Wafl;
use base 'Spoon::Formatter::WaflPhrase';

sub to_html {
    my $zipcode = $self->arguments;
    return $self->wafl_error
      unless $zipcode =~ /^\d{5}$/;
    require Geo::Weather;
    my $weather = Geo::Weather->new;
    $weather->get_weather($zipcode);
    $self->hub->template->process('weather_report.html',
        weather => $weather,
    );
}

package Kwiki::Weather::CGI;
use Kwiki::CGI '-base';
cgi 'zipcode';

package Kwiki::Weather;
1;

__DATA__

=head1 NAME 

Kwiki::Weather - Weather button and WAFL for your Kwiki

=head1 SYNOPSIS

 $ cpan Kwiki::Weather
 $ cd /path/to/kwiki
 $ echo "Kwiki::Weather" >> plugins
 $ kwiki -update

=head1 DESCRIPTION

This adds as weather button in your Kwiki toolbar. Users must specify a zip code in their preferences first.

Additionally, this plugin adds a WAFL phrase you can use to generate a weather report from KwikiText:

    === The Weather in Boston
    {weather: 02115}

Reports are generated by L<Geo::Weather>.

=head1 AUTHORS

Ian Langworth <langworth.com> and Brian Ingerson <ingy@cpan.org>

=head1 SEE ALSO

L<Kwiki>, L<Geo::Weather>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Ian Langworth

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__template/tt2/weather_content.html__
<!-- BEGIN weather_content.html -->
[% self.geo_weather.report %]
<hr/>
[% self.geo_weather.report_forecast %]
<!-- END weather_content.html -->
__template/tt2/weather_error.html__
<!-- BEGIN weather_error.html -->
[% screen_title = 'Weather Report' %]
<p><span class="error">Please specify a zipcode in your Preferences.</span></p>
<!-- END weather_error.html -->
__template/tt2/weather_report.html__
<!-- BEGIN weather_report.html -->
[% weather.report %]
<hr/>
[% weather.report_forecast %]
<!-- END weather_report.html -->
__template/tt2/weather_button.html__
<!-- BEGIN weather_button.html -->
<a href="[% script_name %]?action=weather&zipcode=[% hub.users.current.preferences.zipcode.value %]" title="Local Weather Report">
[% INCLUDE weather_button_icon.html %]
</a>
<!-- END weather_button.html -->
__template/tt2/weather_button_icon.html__
<!-- BEGIN weather_button_icon.html -->
Weather
<!-- END weather_button_icon.html -->
