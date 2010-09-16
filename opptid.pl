#!/usr/bin/perl

# Using Mojolicious::Lite will enable "strict" and "warnings"
use Mojolicious::Lite;
use DateTime;
use DateTime::Duration;
use DateTime::Format::Duration;

@ARGV = qw( daemon ) unless @ARGV;

plugin charset => {charset => 'utf8'};
plugin 'i18n' => {namespace => 'I18N'};
our $config->{languages} = ['en', 'no'];
app->secret('05L0 p4rL mong4rS');

sub calculator {
    my $self = shift;
    my $percentage  = $self->param('percentage');
    my $year = $self->param('year');
    my $month = $self->param('month');
    my $day = $self->param('day');
    $percentage =~ s/\,/\./;
    if ($percentage !~ /^[1-9][0-9]?(\.\d{1,4})?$/)
    {
        $self->redirect_to('/99.9');
    }
    my $decimal = (100 - $percentage) / 100;
    my $start_date;
    if($year && $year =~ /\d{4}/ && $month =~ /0[1-9]|1[0-2]/ && $day =~ /0[1-9]|[1-2][0-9]|3[0-1]/) {
        $start_date = DateTime->new(   year   => $year,
                                month  => $month,
                                day    => $day,
                                time_zone => 'UTC' );
    }
    else {
        $start_date = DateTime->now( time_zone => 'UTC' );
    }
    my $downtime = {};
    foreach (qw(day week month year)) {
        my $duration = DateTime::Duration->new( $_.'s' => 1 );
        my $later = $start_date->clone->add_duration($duration);
        my $seconds_dur = $later->subtract_datetime_absolute($start_date);
        #$d->in_units('seconds');
        $seconds_dur->multiply($decimal);
        $downtime->{$_} = $seconds_dur;
    }
    $self->render(
        template => 'downtime',
        percentage  => $percentage,
        downtime    => $downtime,
        start_date  => $start_date,
        year        => $year,
        month       => $month,
        day         => $day,
    );
}

# Index page redirects
any '/' => sub {
    my $self = shift;
    my $percentage  = $self->param('percentage') || '99.9';
    my $year = $self->param('year');
    my $month = $self->param('month');
    my $day = $self->param('day');
    if($year =~ /\d{4}/ && $month =~ /0[1-9]|1[0-2]/ && $day =~ /0[1-9]|[1-2][0-9]|3[0-1]/) {
        $self->redirect_to("/$year/$month/$day/$percentage");
    }
    else
    {
        $self->redirect_to("/$year/$month/$day/$percentage");
    }
} => 'index';

# /99.9
get '/(.percentage)' => [percentage => qr/\d*((\.|,)\d*)?/] => \&calculator;
# /2010/09/15/99.9
get '/:year/:month/:day/(.percentage)' => [percentage => qr/\d*((\.|,)\d*)?/] => \&calculator => 'calculator';

# Determine correct language
app->plugins->add_hook(after_static_dispatch => sub { 
    my ($self, $c) = @_; 
    # We don't want to parse static files urls
    return if $c->res->code;

    if (my $path = $c->tx->req->url->path) {
        my $part = $path->parts->[0];
        my $code = $c->session('ln');

        if ($part && grep { $part eq $_ } @{$config->{languages}}) {
            shift @{$path->parts};
            $c->app->log->debug("Found language $part in url");
            $c->stash->{i18n}->languages($part);
            $c->session(ln => $part);
        }
        elsif ($code && grep { $code eq $_ } @{$config->{languages}}) {
            $c->app->log->debug("Found language $code in session");
            $c->stash->{i18n}->languages($code);
        }
        else
        {
            $c->stash->{i18n}->languages('no');
            $c->session(ln => 'no');
        }
    }
});

# format_duration helper
app->renderer->add_helper(
    format_duration => sub {
        my ($self, $duration, $pattern) = @_;
        $pattern = $pattern || '%Y years, %m months, %e days, %H hours, %M minutes, %S seconds';
        my $i18n_handle = $self->{stash}->{i18n};
        $pattern = $i18n_handle->localize($pattern) if $i18n_handle;
        my $dtf = DateTime::Format::Duration->new(
            pattern => $pattern,
            normalise => 1,
        );
        return $dtf->format_duration($duration)
    }
);

# Start the Mojolicious command system
app->start;

__DATA__

@@ layouts/default.html.ep
<!doctype html>
<html>
<head>
    <title>Mojo Calc Demo</title>
</head>
<body>
  <%= content %>
</body>
</html>

@@ downtime.html.ep
% layout 'default';
<h1>
    <%=l 'Uptime and downtime with [numf,_1] % SLA', $percentage %>
</h1>
<ul>
    <% my $language_link = {%>
        <% my ($code, $label) = @_; =%>
        <% if($i18n->languages ne $code) { =%>
        <a href="/<%= $code %><%= url_for 'calculator' %>">
        <% } =%>
            <%= $label %>
        <% if($i18n->languages ne $code) { =%>
        </a>
        <% } =%>
    <%}%>
    <li>
        <%== $language_link->('no','norsk') %>
    </li>
    <li>
        <%== $language_link->('en','english') %>
    </li>
</ul>
<form method="post" action="<%= url_for 'index' %>">
    <% if ($year && $month && $day) { %>
    <input type="hidden" name="year" value="<%= $year %>" />
    <input type="hidden" name="month" value="<%= $month %>" />
    <input type="hidden" name="day" value="<%= $day %>" />
    <% } %>
    <label for="percentage">
        <%=l 'Change SLA level:' %>
    </label>
    <input type="text" id="percentage" name="percentage" value="<%= l '[numf,_1]', $percentage %>" />
</form>
<p>
<%=l 'SLA level of [numf,_1] % uptime/availability gives following periods of potential downtime/unavailability:', $percentage %>
</p>
<dl>
    <dt><%=l 'Daily' %></dt>
    <dd>
        <%== format_duration($downtime->{day}, '%H hours, %M minutes, %S seconds') %>
    </dd>
    <dt><%=l 'Weekly' %></dt>
    <dd>
        <%= format_duration($downtime->{week}, '%e days, %H hours, %M minutes, %S seconds') %>
    </dd>
    <dt><%=l 'Monthly' %></dt>
    <dd>
        <%= format_duration($downtime->{month}, '%e days, %H hours, %M minutes, %S seconds') %>
    </dd>
    <dt><%=l 'Yearly' %></dt>
    <dd>
        <%= format_duration($downtime->{year}, '%e days, %H hours, %M minutes, %S seconds') %>
    </dd>
</dl>
<p>
    <%= l 'The above calculations are based on a period starting from [dt,_1].',$start_date %>
    <%= l 'You can customise the start date by setting the year, month and day below.' %>
</p>
<form method="post" action="<%= url_for 'index' %>">
    <form method="post" action="<%= url_for 'index' %>">
    <input type="hidden" name="percentage" value="<%= $percentage %>" />
    <label for="year">
        <%=l 'Year' %>
    </label>
    <input type="text" id="year" name="year" value="<%= $year %>" />
    <label for="month">
        <%=l 'Month' %>
    </label>
    <select id="month" name="month">
    <option></option>
    <% for (1 .. 12) { %>
        <% my $v = '0'.$_; %>
        <% $v = substr($v,-2,2); %>
        <% my $selected = ($month && $v eq $month) ? ' selected="selected"' : 0; %>
        <option value="<%= $v %>" <%= $selected %>><%= $v %></option>
    <% } %>
    </select>
    <label for="day">
        <%=l 'Day' %>
    </label>
    <select id="day" name="day">
    <option></option>
    <% for (1 .. 31) { %>
        <% my $v = '0'.$_; %>
        <% $v = substr($v,-2,2); %>
        <% my $selected = ($day && $v eq $day) ? ' selected="selected"' : 0; %>
        <option value="<%= $v %>" <%= $selected %>><%= $v %></option>
    <% } %>
    </select>
    <input type="submit" value="<%=l 'Change' %>" />
</form>

@@ not_found.html.ep
% layout 'default';
<h1>
    <%=l 'Oops, that 404 thing again!' %>
</h1>
