package # hide from PAUSE
Term::ReadLine::Simple::Constants;

use warnings;
use strict;
use 5.008000;

our $VERSION = '0.011';

use Exporter qw( import );

our @EXPORT_OK = qw(
        NEXT_get_key
        CONTROL_A CONTROL_B CONTROL_D CONTROL_E CONTROL_F CONTROL_H CONTROL_K CONTROL_U KEY_BTAB KEY_TAB
        KEY_ENTER KEY_ESC KEY_BSPACE
        VK_CODE_END VK_CODE_HOME VK_CODE_LEFT VK_CODE_UP VK_CODE_RIGHT VK_CODE_DELETE
        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
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
    ) ],
    win32  => [ qw(
        NEXT_get_key
        VK_CODE_END VK_CODE_HOME VK_CODE_LEFT VK_CODE_UP VK_CODE_RIGHT VK_CODE_DELETE
        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
    ) ]
);



#sub UP                     () { "\e[A" }
#sub RIGHT                  () { "\e[C" }
#sub LEFT                   () { "\e[D" }
#sub LF                     () { "\n" } #
#sub CR                     () { "\r" } #

#sub BEEP                   () { "\a" }
#sub CLEAR_SCREEN           () { "\e[2J\e[1;1H" }
#sub CLEAR_TO_END_OF_SCREEN () { "\e[0J" }

#sub SAVE_CURSOR_POSITION    () { "\e[s" }
#sub RESTORE_CURSOR_POSITION () { "\e[u" }

#sub GET_CURSOR_POSITION     () { "\e[6n" }


sub NEXT_get_key  () { -1 }


sub CONTROL_A  () { 0x01 }
sub CONTROL_B  () { 0x02 }
sub CONTROL_D  () { 0x04 }
sub CONTROL_E  () { 0x05 }
sub CONTROL_F  () { 0x06 }
sub CONTROL_H  () { 0x08 }
sub KEY_BTAB   () { 0x08 }
sub KEY_TAB    () { 0x09 }
sub CONTROL_K  () { 0x0b }
sub KEY_ENTER  () { 0x0d }
sub CONTROL_U  () { 0x15 }
sub KEY_ESC    () { 0x1b }
sub KEY_BSPACE () { 0x7f }


sub VK_END    () { 335 }
sub VK_HOME   () { 336 }
sub VK_LEFT   () { 337 }
sub VK_UP     () { 338 }
sub VK_RIGHT  () { 339 }
sub VK_DELETE () { 346 }


sub VK_CODE_END    () { 35 }
sub VK_CODE_HOME   () { 36 }
sub VK_CODE_LEFT   () { 37 }
sub VK_CODE_UP     () { 38 }
sub VK_CODE_RIGHT  () { 39 }
sub VK_CODE_DELETE () { 46 }

1;

__END__
