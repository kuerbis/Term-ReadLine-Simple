package Term::ReadLine::Simple;

use warnings;
use strict;
use 5.008000;

our $VERSION = '0.012';

use Carp   qw( croak carp );
use Encode qw( encode decode );

use Encode::Locale    qw();
use Unicode::GCString qw();

use Term::ReadLine::Simple::Constants qw( :rl );

my $Plugin_Package;

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        require Term::ReadLine::Simple::Win32;
        $Plugin_Package = 'Term::ReadLine::Simple::Win32';
    }
    else {
        require Term::ReadLine::Simple::Linux;
        $Plugin_Package = 'Term::ReadLine::Simple::Linux';
    }
}

sub ReadLine { 'Term::ReadLine::Simple' }
sub IN {}
sub OUT {}
sub MinLine {}
sub Attribs { {} }
sub Features { { no_features => 1 } }
sub addhistory {}
sub ornaments {}


sub new {
    my $class = shift;
    my ( $name ) = @_;
    my $self = bless {
        name => $name,
    }, $class;
    $self->__set_defaults();
    $self->{plugin} = $Plugin_Package->new();
    return $self;
}


sub DESTROY {
    my ( $self ) = @_;
    $self->__reset_term();
}


sub __set_defaults {
    my ( $self ) = @_;
    #$self->{compat}          = undef if ! defined $self->{compat};
    #$self->{reinit_encoding} = undef if ! defined $self->{reinit_encoding};
    $self->{default} = '' if ! defined $self->{default};
    $self->{no_echo} = 0  if ! defined $self->{no_echo};
}


sub __validate_options {
    my ( $self, $opt ) = @_;
    return if ! defined $opt;
    my $valid = {
        no_echo         => '[ 0 1 2 ]',
        compat          => '[ 0 1 ]',
        reinit_encoding => '',
        default         => '',
    };
    my $sub =  ( caller( 1 ) )[3];
    $sub =~ s/^.+::([^:]+)\z/$1/;
    for my $key ( keys %$opt ) {
        if ( ! exists $valid->{$key} ) {
            croak $sub . ": '$key' is not a valid option name";
        }
        next if ! defined $opt->{$key};
        if ( ref $opt->{$key} ) {
            croak $sub . ": option '$key' : a reference is not a valid value.";
        }
        next if $valid->{$key} eq '';
        if ( $opt->{$key} !~ m/^$valid->{$key}\z/x ) {
            croak $sub . ": option '$key' : '$opt->{$key}' is not a valid value.";
        }
    }
}


sub __init_term {
    my ( $self ) = @_;
    $self->{plugin}->__set_mode();
    if ( $self->{reinit_encoding} ) {
        Encode::Locale::reinit( $self->{reinit_encoding} );
    }

}


sub __reset_term {
    my ( $self ) = @_;
    if ( defined $self->{plugin} ) {
        $self->{plugin}->__reset_mode();
    }
}


sub config {
    my ( $self, $opt ) = @_;
    if ( defined $opt ) {
        croak "config: the (optional) argument must be a HASH reference" if ref $opt ne 'HASH';
        $self->__validate_options( $opt );
        for my $option ( keys %$opt ) {
            $self->{$option} = $opt->{$option};
        }
    }
}


sub readline {
    my ( $self, $prompt, $opt ) = @_;
    if ( defined $prompt ) {
        croak "readline: a reference is not a valid prompt." if ref $prompt;
    }
    else {
        $prompt = '';
    }
    if ( defined $opt ) {
        if ( ! ref $opt ) {
            $opt = { default => $opt };
        }
        elsif ( ref $opt ne 'HASH' ) {
            croak "readline: the (optional) second argument must be a string or a HASH reference";
        }
        else {
            $self->__validate_options( $opt );
        }
    }
    else {
        $opt = {};
    }
    $opt->{default} = $self->{default} if ! defined $opt->{default};
    $opt->{no_echo} = $self->{no_echo} if ! defined $opt->{no_echo};
    my $gcs_prompt    = Unicode::GCString->new( $prompt );
    my $length_prompt = $gcs_prompt->length();
    my $str     = Unicode::GCString->new( $prompt . $opt->{default} );
    my $pos_str = $str->length();
    $self->{prev_str_cols} = $str->columns();

    local $| = 1;
    $self->__init_term();
    $self->{plugin}->__save_cursor_position();
    $self->__print_readline( $opt, $prompt, $str, $pos_str );

    while ( 1 ) {
        my $key = $self->{plugin}->__get_key();
        if ( ! defined $key ) {
            $self->__reset_term();
            carp "EOT: $!";
            return;
        }
        next if $key == NEXT_get_key;
        next if $key == KEY_TAB;
        if ( $key == KEY_BSPACE || $key == CONTROL_H ) {
            if ( $pos_str - $length_prompt ) {
                $pos_str--;
                $str->substr( $pos_str, 1, '' );
            }
        }
        elsif ( $key == CONTROL_U ) {
            $str->substr( $length_prompt, $pos_str - $length_prompt, '' );
            $pos_str = $length_prompt;
        }
        elsif ( $key == CONTROL_K ) {
            $str->substr( $pos_str, $str->length() - $pos_str, '' );
        }
        elsif ( $key == VK_DELETE || $key == CONTROL_D ) {
            if ( $str->length() - $length_prompt ) {
                if ( $pos_str < $str->length() ) {
                    $str->substr( $pos_str, 1, '' );
                }
            }
            else {
                print "\n";
                $self->__reset_term();
                return;
            }
        }
        elsif ( $key == VK_RIGHT || $key == CONTROL_F ) {
            $pos_str++ if $pos_str < $str->length();
        }
        elsif ( $key == VK_LEFT  || $key == CONTROL_B ) {
            if ( $pos_str > $length_prompt ) {
                $self->{manually_right} = 1 if $pos_str == $str->length();
                $pos_str--;
            }
        }
        elsif ( $key == VK_END   || $key == CONTROL_E ) {
            $pos_str = $str->length();
        }
        elsif ( $key == VK_HOME  || $key == CONTROL_A ) {
            $pos_str = $length_prompt;
        }
        else {
            $key = chr $key;
            utf8::upgrade $key;
            if ( $key eq "\n" || $key eq "\r" ) { ###
                $str->substr( 0, $length_prompt, '' );
                print "\n";
                $self->__reset_term();
                if ( $self->{compat} || ! defined $self->{compat} && $ENV{READLINE_SIMPLE_COMPAT} ) {
                    return encode( 'console_in', $str->as_string );
                }
                return $str->as_string;
            }
            else {
                $str->substr( $pos_str, 0, $key );
                $pos_str++;
            }
        }
        $self->__print_readline( $opt, $prompt, $str, $pos_str );
    }
}


sub __print_readline {
    my ( $self, $opt, $prompt, $str, $pos_str ) = @_;
    my $tmp_pos = $str->pos();
    $str->pos( 0 );
    my $str_col = 0;
    my $str_row = 0;
    my @gc_in_row = ();
    my $term_width = $self->{plugin}->__term_buff_width();
    while ( defined( my $gc = $str->next ) ) {
        if ( $term_width < ( $str_col += $gc->columns ) ) {
            $str_col = $gc->columns();
            $str_row++;
        }
        $gc_in_row[$str_row]++;
    }
    if ( $str_col == $term_width ) {
        $str_col = 0;
        $str_row++;
    }
    $str->pos( $tmp_pos );
    #############################################
    $self->{plugin}->__restore_cursor_position();
    if ( $str_row ) {
        print "\n" x $str_row;
        $self->{plugin}->__up( $str_row );
    }
    $self->{plugin}->__clear_output( $self->{prev_str_cols} );
    $self->{plugin}->__save_cursor_position();
    if ( $opt->{no_echo} ) {
        if ( $opt->{no_echo} == 2 ) {
            print $prompt;
            return;
        }
        my $gcs_prompt = Unicode::GCString->new( $prompt );
        print $prompt . ( '*' x ( $str->length() - $gcs_prompt->length() ) );
    }
    else {
        print $str->as_string;
    }
    #############################################
    my $str_before_cursor = $str->substr( 0, $pos_str );
    my $cursor_row = 0;
    my $cursor_col = 0;
    my $gc_sum  = 0;
    for my $row ( 0 .. $#gc_in_row ) {
        if ( $gc_sum + $gc_in_row[$row] < $pos_str ) {
            $gc_sum += $gc_in_row[$row];
        }
        else {
            $cursor_row = $row;
            last;
        }
    }
    $str_before_cursor->pos( $gc_sum );
    my $gc_cursor_row = 0;
    while ( defined( my $gc = $str_before_cursor->next ) ) {
        $cursor_col += $gc->columns();
        $gc_cursor_row++;
    }
    if ( $cursor_col == $term_width ) {
        $cursor_col = 0;
        $cursor_row++;
    }
    elsif ( defined $gc_in_row[$cursor_row + 1] && $gc_cursor_row == $gc_in_row[$cursor_row] ) {
        $cursor_col = 0;
        $cursor_row++;
    }
    if ( $^O eq 'MSWin32' ) {
        $self->{prev_str_cols} = $str->columns();
        my ( $abs_col, $abs_row ) = $self->{plugin}->__get_cursor_position();
        $self->{plugin}->__set_cursor_position( $cursor_col + 1, $cursor_row + $abs_row - $str_row );
        return;
    }
    if ( $str_row > $cursor_row && $str_col == 0 ) {
        --$str_row;
        $str_col = $term_width - 1;
        if ( $self->{manually_right} && $cursor_col == $term_width - 1 ) {
            $self->{plugin}->__right( $term_width - 1 );
        }
    }
    if ( $str_row > $cursor_row ) {
        $self->{plugin}->__up( $str_row - $cursor_row );
    }
    if ( $str_col > $cursor_col ) {
        $self->{plugin}->__left( $str_col - $cursor_col );
    }
    elsif ( $str_col < $cursor_col ) {
        $self->{plugin}->__right( $cursor_col - $str_col );
    }
}




1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Term::ReadLine::Simple - Read a line from STDIN.

=head1 VERSION

Version 0.012

=cut

=head1 SYNOPSIS

    use Term::ReadLine::Simple;

    my $new = Term::ReadLine::Simple->new( 'name' );
    my $line = $new->readline( 'Prompt: ', { default => 'abc' } );

=head1 DESCRIPTION

C<readline> reads a line from STDIN. As soon as C<Return> is pressed C<readline> returns the read string without the
newline character - so no C<chomp> is required.

This module is intended to cope with Unicode (multibyte character/grapheme cluster).

=head2 Keys

C<BackSpace> or C<Strg-H>: Delete the character behind the cursor.

C<Delete> or C<Strg-D>: Delete  the  character at point. Return nothing if the input puffer is empty.

C<Strg-U>: Delete the text backward from the cursor to the beginning of the line.

C<Strg-K>: Delete the text from the cursor to the end of the line.

C<Right-Arrow> or C<Strg-F>: Move forward a character.

C<Left-Arrow> or C<Strg-B>: Move back a character.

C<Home> or C<Strg-A>: Move to the start of the line.

C<End> or C<Strg-E>: Move to the end of the line.

=head1 METHODS

=head2 new

The C<new> method returns a C<Term::ReadLine::Simple> object.

    my $new = Term::ReadLine::Simple->new( 'name' );

The argument is the name of the application.

=head2 config

The method C<config> sets the defaults for the current C<Term::ReadLine::Simple> object.

    $new->config( \%options );

The available options are:

=over

=item

default

Sets the default I<default> string.

Allowed values: a decoded string.

Default: not set.

=item

no_echo

Sets the default value for I<no_echo>.

Allowed values: 0, 1 or 2.

Default: 0.

=back

Options not available in the C<readline> method:

=over

=item

compat

If I<compat> is set to 1, the return value of C<readline> is not decoded else the return value of C<readline>
is decoded.

Setting the environment variable READLINE_SIMPLE_COMPAT to a true value has the same effect as setting I<compat> to 1
unless I<compat> is defined. If I<compat> is defined, READLINE_SIMPLE_COMPAT has no meaning.

Allowed values: 0 or 1.

Default: no set

=item

reinit_encoding

To get the right encoding C<Term::ReadLine::Simple> uses L<Encode::Locale>. Passing an encoding to I<reinit_encoding>
changes the encoding reported by C<Encode::Locale>. See L<Encode::Locale/reinit-encoding> for more details.

Allowed values: an encoding which is recognized by the L<Encode> module.

Default: not set.

=back

=head2 readline

C<readline> reads a line from STDIN.

    $line = $new->readline( $prompt, [ \%options ] );

The fist argument is the prompt string. The optional second argument is the default string if it is not a reference. If
the second argument is a hash-reference, the hash is used to set the different options. The keys/options are

=over

=item

default

Sets a initial value of input.

=item

no_echo

If I<no_echo> is set to 1, "C<*>" are displayed instead of the characters.

If I<no_echo> is set to 2, no output is shown apart from the prompt string.

=back

See L</config> for the default and allowed values.

=head1 REQUIREMENTS

=head2 Perl version

Requires Perl version 5.8.0 or greater.

=head2 Terminal

It is required a terminal which uses a monospaced font.

Unless the OS is MSWin32 the terminal has to understands ANSI escape sequences.

=head2 Encoding layer

It is required to use appropriate I/O encoding layers. If the encoding layer for STDIN doesn't match the terminal's
character set, C<readline> will break if a non ascii character is entered.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Term::ReadLine::Simple

=head1 AUTHOR

Matthäus Kiem <cuer2s@gmail.com>

=head1 CREDITS

Thanks to the L<Perl-Community.de|http://www.perl-community.de> and the people form
L<stackoverflow|http://stackoverflow.com> for the help.

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl 5.10.0. For
details, see the full text of the licenses in the file LICENSE.

=cut
