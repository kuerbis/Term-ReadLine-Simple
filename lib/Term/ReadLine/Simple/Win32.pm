package # hide from PAUSE
Term::ReadLine::Simple::Win32;

use warnings;
use strict;
use 5.008003;

our $VERSION = '0.015';

use Encode qw( decode );

use Encode::Locale qw();
use Win32::Console qw( STD_INPUT_HANDLE ENABLE_PROCESSED_INPUT STD_OUTPUT_HANDLE
                       RIGHT_ALT_PRESSED LEFT_ALT_PRESSED RIGHT_CTRL_PRESSED LEFT_CTRL_PRESSED SHIFT_PRESSED );

use Term::ReadLine::Simple::Constants qw( :win32 );


sub new {
    return bless {}, $_[0];
}


sub __set_mode {
    my ( $self ) = @_;
    $self->{input} = Win32::Console->new( STD_INPUT_HANDLE );
    $self->{old_in_mode} = $self->{input}->Mode();
    $self->{input}->Mode( ENABLE_PROCESSED_INPUT );
    $self->{output} = Win32::Console->new( STD_OUTPUT_HANDLE );
    $self->{def_attr}  = $self->{output}->Attr();
    $self->{bg_color}  = $self->{def_attr} & 0x70;
    $self->{fill_attr} = $self->{bg_color} | $self->{bg_color};
}


sub __reset_mode {
    my ( $self ) = @_;
    if ( defined $self->{input} ) {
        if ( defined $self->{old_in_mode} ) {
            $self->{input}->Mode( $self->{old_in_mode} );
            delete $self->{old_in_mode};
        }
        $self->{input}->Flush;
        # workaround Bug #33513:
        delete $self->{input}{handle};
        delete $self->{output}{handle};
    }
}


sub SHIFTED_MASK () {
      RIGHT_ALT_PRESSED
    | LEFT_ALT_PRESSED
    | RIGHT_CTRL_PRESSED
    | LEFT_CTRL_PRESSED
    | SHIFT_PRESSED
}

sub __get_key {
    my ( $self ) = @_;
    my @event = $self->{input}->Input;
    my $event_type = shift @event;
    return NEXT_get_key if ! defined $event_type;
    if ( $event_type == 1 ) {
        my ( $key_down, $repeat_count, $v_key_code, $v_scan_code, $char, $ctrl_key_state ) = @event;
        return NEXT_get_key if ! $key_down;
        if ( $char ) {
            return ord decode( 'console_in', chr( $char & 0xff ) );
        }
        else{
            if ( $ctrl_key_state & SHIFTED_MASK ) {
                return NEXT_get_key;
            }
            elsif ( $v_key_code == VK_CODE_END )    { return VK_END }
            elsif ( $v_key_code == VK_CODE_HOME )   { return VK_HOME }
            elsif ( $v_key_code == VK_CODE_LEFT )   { return VK_LEFT }
            elsif ( $v_key_code == VK_CODE_UP )     { return VK_UP }
            elsif ( $v_key_code == VK_CODE_RIGHT )  { return VK_RIGHT }
            elsif ( $v_key_code == VK_CODE_DELETE ) { return VK_DELETE }
            else {
                return NEXT_get_key;
            }
        }
    }
    else {
        return NEXT_get_key;
    }
}


sub __term_buff_width {
    my ( $self ) = @_;
    my ( $term_width ) = $self->{output}->MaxWindow();
    return $term_width;
}


sub __get_cursor_position {
    my ( $self ) = @_;
    my ( $col, $row ) = $self->{output}->Cursor();
    return $col + 1, $row + 1;
}


sub __set_cursor_position {
    my ( $self, $col, $row ) = @_;
    $self->{output}->Cursor( $col - 1, $row - 1 );
}


sub __up {
    my ( $self, $rows_up ) = @_;
    return if ! $rows_up; #
    my ( $col, $row ) = $self->__get_cursor_position;
    my $new_row = $row - $rows_up;
    $new_row = 1 if $new_row < 1;
    $self->__set_cursor_position( $col, $new_row  );
}


sub __clear_output{
    my ( $self, $chars ) = @_;
    my ( $col, $row ) = $self->__get_cursor_position();
    $self->{output}->FillAttr(
            $self->{fill_attr},
            $chars,
            $col - 2, $row - 1 );
}


sub __save_cursor_position {
    my ( $self ) = @_;
    $self->{saved_cursor_position} = [ $self->{output}->Cursor() ];
}

sub __restore_cursor_position {
    my ( $self ) = @_;
    $self->{output}->Cursor( @{$self->{saved_cursor_position}} );
}




1;

__END__
