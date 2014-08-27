package # hide from PAUSE
Term::ReadLine::Simple::Linux;

use warnings;
use strict;
use 5.008000;

our $VERSION = '0.011';

use Term::ReadKey  qw( GetTerminalSize ReadKey ReadMode );

use Term::ReadLine::Simple::Constants qw( :linux );


sub new {
    return bless {}, $_[0];
}


sub __set_mode {
    #my ( $self ) = @_;
    ReadMode( 'cbreak' );
};


sub __reset_mode {
    #my ( $self ) = @_;
    ReadMode( 'restore' );
}


sub __term_buff_width {
    #my ( $self ) = @_;
    my ( $term_width ) = GetTerminalSize();
    return $term_width;
}


sub __get_key {
    #my ( $self ) = @_;
    my $c1 = ReadKey( 0 );
    return if ! defined $c1;
    if ( $c1 eq "\e" ) {
        my $c2 = ReadKey( 0.10 );
        if ( ! defined $c2 ) {
            return  NEXT_get_key; # KEY_ESC
        }
        elsif ( $c2 eq 'O' ) {
            my $c3 = ReadKey( 0 );
               if ( $c3 eq 'C' ) { return VK_RIGHT; }
            elsif ( $c3 eq 'D' ) { return VK_LEFT; }
            elsif ( $c3 eq 'F' ) { return VK_END; }
            elsif ( $c3 eq 'H' ) { return VK_HOME; }
            elsif ( $c3 eq 'Z' ) { return KEY_BTAB; }
            else {
                return NEXT_get_key;
            }
        }
        elsif ( $c2 eq '[' ) {
            my $c3 = ReadKey( 0 );
               if ( $c3 eq 'C' ) { return VK_RIGHT; }
            elsif ( $c3 eq 'D' ) { return VK_LEFT; }
            elsif ( $c3 eq 'F' ) { return VK_END; }
            elsif ( $c3 eq 'H' ) { return VK_HOME; }
            elsif ( $c3 eq 'Z' ) { return KEY_BTAB; }
            elsif ( $c3 =~ /^[0-9]$/ ) {
                my $c4 = ReadKey( 0 );
                if ( $c4 eq '~' ) {
                    if ( $c3 eq '3' ) { return VK_DELETE; }
                    else {
                        return NEXT_get_key;
                    }
                }
                else {
                    return NEXT_get_key;
                }
            }
            else {
                return NEXT_get_key;
            }
        }
        else {
            return NEXT_get_key;
        }
    }
    else {
        return ord $c1;
    }
};


sub __up    { print "\e[${_[1]}A"; }


sub __left  { print "\e[${_[1]}D"; }


sub __right { print "\e[${_[1]}C"; }


sub __clear_output { print "\e[0J"; }


sub __save_cursor_position    { print "\e[s"; }


sub __restore_cursor_position { print "\e[u"; }



1;

__END__
