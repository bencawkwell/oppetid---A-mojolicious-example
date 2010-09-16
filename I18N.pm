package I18N;
use base qw(Locale::Maketext);

sub dt {
    my $self = shift;
    my $dt = shift;
    my $sep = shift || '/';
    return $dt->dmy($sep);
};

our %Lexicon = ( _AUTO => 1); 
1;
