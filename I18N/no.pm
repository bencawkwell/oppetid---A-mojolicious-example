package I18N::no;
use base 'I18N';
use utf8;

sub init {
    my $lh = $_[0];  # a newborn handle
    $lh->SUPER::init();
    $lh->{numf_comma} = 1;
    return;
}

our %Lexicon = (
    'Uptime and downtime with [numf,_1] % SLA' => 'Oppetid og nedetid ved SLA [numf,_1] %',
    'Change SLA level:' => 'Endre SLA-nivå:',
    'SLA level of [numf,_1] % uptime/availability gives following periods of potential downtime/unavailability:' => 'En SLA på [numf,_1] % oppetid/tilgjengelighet gir følgende perioder med potensiell nedetid/utilgjengelighet:',
    'Daily' => 'Daglig',
    'Weekly' => 'Ukentlig',
    'Monthly' => 'Månedlig',
    'Yearly' => 'Årlig',
    '%Y years, %m months, %e days, %H hours, %M minutes, %S seconds' => '% Y år,% m måneder,% e dager,% H timer,% M minutter,% S sekunder',
    '%H hours, %M minutes, %S seconds' => '%H timer, %M minutter, %S sekunder',
    '%e days, %H hours, %M minutes, %S seconds' => '%e dager, %H timer, %M minutter, %S sekunder',
    'Link to this page: ' => 'Fast peker til denne siden: ',
    'The above calculations are based on a period starting from [dt,_1].' => 'Ovennevnte beregninger er basert på en periode fra [dt,_1,.].',
    'You can customise the start date by setting the year, month and day below.' => 'Du kan tilpasse startdato ved å angi år, måned og dag nedenfor.',
    'Year' => 'År',
    'Month' => 'Måned',
    'Day' => 'Dag',
    'Change' => 'Endre',
    'Oops, that 404 thing again!' => 'Oops, det 404 ting igjen!',
    _AUTO => 1,
);

1;
