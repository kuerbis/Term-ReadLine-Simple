package # hide from PAUSE
Term::ReadLine::Simple::Constants;

use warnings;
use strict;
use 5.008003;

our $VERSION = '0.016';

use Exporter qw( import );

our @EXPORT_OK = qw(
        NEXT_get_key
        CONTROL_A CONTROL_B CONTROL_D CONTROL_E CONTROL_F CONTROL_H CONTROL_K CONTROL_U KEY_BTAB KEY_TAB
        KEY_ENTER KEY_ESC KEY_BSPACE
        VK_CODE_END VK_CODE_HOME VK_CODE_LEFT VK_CODE_UP VK_CODE_RIGHT VK_CODE_DELETE
        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
        CLEAR_TO_END_OF_SCREEN SAVE_CURSOR_POSITION RESTORE_CURSOR_POSITION
);

our %EXPORT_TAGS = (
    rl => [ qw(
        NEXT_get_key
        CONTROL_A CONTROL_B CONTROL_D CONTROL_E CONTROL_F CONTROL_H CONTROL_K CONTROL_U KEY_BTAB KEY_TAB
        KEY_ENTER KEY_ESC KEY_BSPACE
        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
    ) ],
    linux  => [ qw(
        NEXT_get_key
        KEY_BTAB KEY_ESC
        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
        CLEAR_TO_END_OF_SCREEN SAVE_CURSOR_POSITION RESTORE_CURSOR_POSITION
    ) ],
    win32  => [ qw(
        NEXT_get_key
        VK_CODE_END VK_CODE_HOME VK_CODE_LEFT VK_CODE_UP VK_CODE_RIGHT VK_CODE_DELETE
        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
    ) ]
);


use constant {
    CLEAR_TO_END_OF_SCREEN => "\e[0J",

    SAVE_CURSOR_POSITION    => "\e[s",
    RESTORE_CURSOR_POSITION => "\e[u",


    NEXT_get_key => -1,

    CONTROL_A  => 0x01,
    CONTROL_B  => 0x02,
    CONTROL_D  => 0x04,
    CONTROL_E  => 0x05,
    CONTROL_F  => 0x06,
    CONTROL_H  => 0x08,
    KEY_BTAB   => 0x08,
    KEY_TAB    => 0x09,
    CONTROL_K  => 0x0b,
    KEY_ENTER  => 0x0d,
    CONTROL_U  => 0x15,
    KEY_ESC    => 0x1b,
    KEY_BSPACE => 0x7f,

    VK_END    => 335,
    VK_HOME   => 336,
    VK_LEFT   => 337,
    VK_UP     => 338,
    VK_RIGHT  => 339,
    VK_DELETE => 346,

    VK_CODE_END    => 35,
    VK_CODE_HOME   => 36,
    VK_CODE_LEFT   => 37,
    VK_CODE_UP     => 38,
    VK_CODE_RIGHT  => 39,
    VK_CODE_DELETE => 46,
};



1;

__END__
