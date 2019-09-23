#!/bin/bash
#

if [[ "$OSTYPE" != "win32" ]]; then
\curl -L http://cpanmin.us | perl - App::cpanminus
else
	cpan App::cpanminus
fi
wait

if [[ "$OSTYPE" == "win32" ]]; then
	cpanm -i Win32::Console::ANSI
fi
wait

cpanm -i Modern::Perl
cpanm -i Moose
cpanm -i MooseX::Getopt
cpanm -i List::MoreUtils
cpanm -i Archive::Zip