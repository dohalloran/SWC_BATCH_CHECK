#
# module for SWC_BATCH_CHECK
#
# Copyright Damien O'Halloran
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code

=head1 NAME

SWC_BATCH_CHECK

=head1 DESCRIPTION

Provides methods for batch validating data in SWC neuron morphology files

=head1 FEEDBACK

damienoh@gwu.edu

=head2 Mailing Lists

User feedback is an integral part of the evolution of this module. Send your comments and suggestions preferably to one of the mailing lists. Your participation is much appreciated.

=head2 Support

Please direct usage questions or support issues to:
<damienoh@gwu.edu>
Please include a thorough description of the problem with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the GitHub bug tracking system to help keep track of the bugs and their resolution.  Bug reports can be submitted via the GitHub page:

 https://github.com/dohalloran/SWC_BATCH_CHECK/issues

=head1 AUTHORS - Damien OHalloran

Email: damienoh@gwu.edu

=head1 APPENDIX

The rest of the documentation details each method

=cut

# Let the code begin...

package SWC_BATCH_CHECK;

use Moose;
with 'MooseX::Getopt', 'MooseX::Getopt::Usage::Role::Man';
use Modern::Perl;
use if ( $^O eq 'MSWin32' ), 'Win32::Console::ANSI';
use Term::ANSIColor qw(:constants);
use List::MoreUtils qw( uniq );
use Sys::Hostname;
use File::Basename;
use List::Util qw( min max sum);
no if $] >= 5.017011, warnings => 'experimental::smartmatch';
use autodie;

##################################
our $VERSION = '1.0';
##################################

=head2 SWC_BATCH_CHECK->new_with_options()

 Function: Populates the user data into $self 
 Returns : nothing returned
 Args    :
  --d, input swc file (required)
  --soma, provide corrections to soma that are not connected to other soma
  --apic, ensures apical dendrites are connected to apical dendrite or soma   
  --basal, same as --apic flag except for basal dendrite
  --rad, converts radius = 0 entries to that of its parent's radius
  --help, Print this help

=cut

##################################

has 'd'     => ( is => 'rw', isa => 'Str',  required => 1 );
has 'soma'  => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'apic'  => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'basal' => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'rad'   => ( is => 'rw', isa => 'Bool', default  => 0 );
has 'start' => ( is => 'ro', isa => 'Int',  default  => time );

has help => (
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
    documentation => qq{view driver script for input flag details}
);

##################################

=head2 run_SWC_BATCH_CHECK()

 Title   : run_SWC_BATCH_CHECK()
 Usage   : $self->run_SWC_BATCH_CHECK(%arg)
 Function: parses and checks swc file
 Returns : corrected swc file and error log
 Args    : $self, %arg

=cut

##################################

sub run_SWC_BATCH_CHECK {
    my ( $self, %arg ) = @_;

    my $dir = $self->{d};

    my $out_dir = './NEW_SWC';
    my $error_log;
    my $commandline = join " ", $0, @ARGV;

    print BOLD GREEN, "\nPerl Version: \t\t" . $^V;
    print BOLD GREEN, "\nCommand-line: \t\t" . $commandline;
    print "\nOperating system: \t" . $^O;
    print "\nHostname: \t\t" . hostname;
    print "\nSWC_BATCH_CHECK version: \t" . $VERSION;

    foreach my $files ( glob("$dir/*.swc") ) {

        my (
            $fh_out,  @distance, @header,  @arr,    $count, @structure,
            @x_coord, @y_coord,  @z_coord, @radius, @parent
        );

        $count = 1;

        # log data on sys and infile
        my $inSize = -s $files;
        print BOLD CYAN, "\n\n" . "Validating file with SWC_BATCH_CHECK...\n", RESET;
        print "\nInput file name: \t" . basename($files);
        print "\nInput file size: \t" . $inSize . "KB", RESET;

        my $out = "new_" . basename($files);

        open my $fh, '<', $files
          or die "Cannot open $files: $!";

        #error log
        $error_log = "__error_log__.txt";

        open my $el, '>>', $error_log
          or die "Cannot open $error_log: $!";

        while ( my $line = <$fh> ) {
            if ( $line !~ m/^\#/ ) {
                $line =~ s/^\s+//;

                @arr = split /\s+/, $line;
                if ( ( _is_integer( $arr[0] ) ) && ( $arr[0] != $count ) ) {
                #######################################################
                #check if index values are in sequence
                    unshift @arr, " "; #placeholder
                    print $el
                      "[Correction] Error in n+1 sequence on index line: "
                      . $count
                      . " in file "
                      . basename($files) . "\n";
                }
                #######################################################
                #check if values are missing from any line
                if ( scalar @arr != 7 ) {
                    print $el "[Warning] Data entry missing on line "
                      . $count
                      . " in file "
                      . basename($files) . "\n";
                }

                my $index = 0;
                #data type check
                #add to arrays
                if (   ( length( $arr[1] ) )
                    && ( _is_integer( $arr[1] ) )
                    && ( length( $arr[2] ) )
                    && ( _is_float( $arr[2] ) )
                    && ( length( $arr[3] ) )
                    && ( _is_float( $arr[3] ) )
                    && ( length( $arr[4] ) )
                    && ( _is_float( $arr[4] ) )
                    && ( length( $arr[5] ) )
                    && ( _is_float( $arr[5] ) ) )
                {
                    push @structure, $arr[1];
                    push @x_coord,   $arr[2];
                    push @y_coord,   $arr[3];
                    push @z_coord,   $arr[4];
                    push @radius,    $arr[5];
                    #correct empty parent values
                    if ( !$arr[6] ) {
                        push @parent, $parent[-1];
                    }
                    else {
                        push @parent, $arr[6];
                    }

                    my $euclid = sqrt(
                        (
                            abs(
                                ( $x_coord[$index] ) -
                                  ( $x_coord[ $index - 1 ] )
                            )**2
                        ) + (
                            abs(
                                ( $y_coord[$index] ) -
                                  ( $y_coord[ $index - 1 ] )
                            )**2
                        ) + (
                            abs(
                                ( $z_coord[$index] ) -
                                  ( $z_coord[ $index - 1 ] )
                            )**2
                        )
                    );
                    push @distance, $euclid;
                    $count++;
                }

                $index++;
            }
            else {
                $line =~ s/^\s+//;
                push @header, $line;
            }
        }
        #######################################################
        #check that file begins at soma
        unless ( $structure[0] == 1 ) {
            print $el "[Correction] File does not begin with soma on line 1: "
              . " in file "
              . basename($files) . "\n";
            $structure[0] = 1;
        }

        #little hack to stop index
        #going to end of array from 1st
        my $grab_first = shift @parent;
        unshift @parent, 1;

        # connection containers
        my @soma_;
        my @basal_;
        my @apical_;
        my $val;
        #build containers for connections
        for my $j ( 0 .. $#parent ) {
            my $tracker = $j + 1;
            my $refer   = $parent[$j] - 1;

            if ( $structure[$j] == 1 ) {
                my $soma_connect = $structure[$refer];
                push @soma_, $soma_connect;
            }

            if ( $structure[$j] == 3 ) {
                my $basal_connect = $structure[$refer];
                push @basal_, $basal_connect;
            }

            if ( $structure[$j] == 4 ) {
                my $apical_connect = $structure[$refer];
                push @apical_, $apical_connect;
            }
        }
        #######################################################
        #check connections for soma 
        for my $k ( 0 .. $#parent ) {
            my $tracker = $k + 1;
            if ( $self->{soma} eq 1 ) {
                my $look_up = $parent[$k];
                if ( $structure[$k] == 1 ) {
                    my $val = shift @soma_;
                    unless ( $val == 1 ) {
                        $structure[ $look_up - 1 ] = 1;
                        print $el
"[Correction] Soma to non-soma connection on data line: "
                          . $tracker
                          . " in file "
                          . basename($files) . "\n";

                    }

                }

            }
        #######################################################
        #check for radius size = 0 and correct or add warnings
            if ( $self->{rad} eq 1 ) {
                my $look_up = $parent[$k];
                if ( $radius[$k] == 0 ) {
                    print "\n" . $radius[$k];
                    print "\n" . $radius[ $look_up - 1 ];
                    $radius[$k] = $radius[ $look_up - 1 ];
                    print $el
"[Correction] Radius zero changed to parent radius on data line: "
                      . $tracker
                      . " in file "
                      . basename($files) . "\n";
                }
            }
            elsif ( $radius[$k] == 0 ) {
                print $el "[Warning] Radius zero identified on data line: "
                  . $tracker
                  . " in file "
                  . basename($files) . "\n";
            }
        #######################################################
        #check connections for basal dendrites 
            if ( $self->{basal} eq 1 ) {
                my $look_up = $parent[$k];
                if ( $structure[$k] == 3 ) {
                    my $val = shift @basal_;
                    unless ( $val == 1 || $val == 3 ) {
                        if ( @basal_ != 0
                            && ( $basal_[0] == 1 || $basal_[0] == 3 ) )
                        {
                            $structure[ $look_up - 1 ] = $basal_[0];
                            print $el
"[Correction] Basal to non-basal connection on data line: "
                              . $tracker
                              . " in file "
                              . basename($files) . "\n";
                        }
                        else {
                            print $el
"[Warning] Basal to non-basal connection on data line: "
                              . $tracker
                              . " in file "
                              . basename($files) . "\n";
                        }
                    }
                }
            }
        #######################################################
        #check connections for apical dendrites 
            if ( $self->{apic} eq 1 ) {
                my $look_up = $parent[$k];
                if ( $structure[$k] == 4 ) {
                    my $val = shift @apical_;
                    unless ( $val == 1 || $val == 4 ) {
                        if ( @apical_ != 0
                            && ( $apical_[0] == 1 || $apical_[0] == 4 ) )
                        {
                            $structure[ $look_up - 1 ] = $apical_[0];
                            print $el
"[Correction] Apical to non-apical connection on data line: "
                              . $tracker
                              . " in file "
                              . basename($files) . "\n";
                        }
                        else {
                            print $el
"[Warning] Apical to non-apical connection on data line: "
                              . $tracker
                              . " in file "
                              . basename($files) . "\n";
                        }
                    }
                }
            }
        }

        #ensure -1 is first value
        my $grab_first2 = shift @parent;
        unshift @parent, -1;

        # new outfile resulting from filtering
        if ( !-e $out_dir ) {
            print BOLD RED,
              "\n\nOutput directory ($out_dir) does not exist! Creating...";
            mkdir($out_dir)
              or die "Failed to create the output directory ($out_dir): $!\n";
            print "Done\n", RESET;
        }
        open( $fh_out, '>', "$out_dir/$out" )
          or die "Can't open the file ($out_dir/$out): $!\n";

        #new $out file data and header
        print $fh_out "@header";
        for my $i ( 0 .. $#structure ) {
            print $fh_out ( $i + 1 ) . " "
              . ( $structure[$i] ) . " "
              . ( $x_coord[$i] ) . " "
              . ( $y_coord[$i] ) . " "
              . ( $z_coord[$i] ) . " "
              . ( $radius[$i] ) . " "
              . ( $parent[$i] ) . "\n";
        }
        close $fh_out;

        #remove leading space from header
        system('perl -pli -e "s/^\s//" ./NEW_SWC/*.swc');

        #line endings for DOS-type, Unix-type, and Mac-type
        system('perl -pi -e "s!(?:\015\012?|\012)!$/!g" ./NEW_SWC/*.swc');

        close $fh;
        my $count_soma      = grep { $_ == 1 } @structure;
        my $count_axon      = grep { $_ == 2 } @structure;
        my $count_basal     = grep { $_ == 3 } @structure;
        my $count_apical    = grep { $_ == 4 } @structure;
        my $count_custom    = grep { $_ >= 5 } @structure;
        my $count_undefined = grep { $_ == 0 } @structure;

        print BOLD GREEN, "\nNo. of compartments: \t" . ( $count - 1 ), RESET;
        print BOLD GREEN, "\nNumber of segments: \t" . ( max @structure ),
          RESET;
        print BOLD GREEN,
          "\nMax segment frag: \t" . ( ( uniq @parent ) - 1 ), RESET;
        print BOLD GREEN, "\nSoma points: \t\t" . $count_soma,         RESET;
        print BOLD GREEN, "\nAxon points: \t\t" . $count_axon,         RESET;
        print BOLD GREEN, "\nBasal dend points: \t" . $count_basal,    RESET;
        print BOLD GREEN, "\nApical dend points: \t" . $count_apical,  RESET;
        print BOLD GREEN, "\nCustom points: \t\t" . $count_custom,     RESET;
        print BOLD GREEN, "\nUndefined points: \t" . $count_undefined, RESET;
        print BOLD GREEN, "\nAverage diameter: \t"
          . ( ( sum @radius ) / ( scalar @radius ) * 2 ), RESET;
        print BOLD GREEN,
          "\nMinimum diameter: \t" . ( ( min @radius ) * 2 ), RESET;
        print BOLD GREEN,
          "\nMaximum diameter: \t" . ( ( max @radius ) * 2 ), RESET;
        print BOLD GREEN,
          "\nMax. Euclidean dist: \t" . ( max @distance ), RESET;
    }

    # delete error log if empty
    if ( -z $error_log ) {
        unlink $error_log or die "Can't unlink empty file '$error_log': $!";
    }
    # get time after execution and calc duration
    my $duration = time - $self->{start};

    print BOLD MAGENTA,
      "\n\nSWC_BATCH_CHECK is now finished after " . $duration . "secs\n\n", RESET;
}

##################################

=head2 _is_integer()

 Title   : _is_integer()
 Usage   : _is_integer($value);
 Function: checks that $value is +ve integer
 Returns : returns defined 
 Args    : integer

=cut

##################################

sub _is_integer {
    defined $_[0] && $_[0] =~ /^[+]?\d+$/;
}

##################################

=head2 _is_float()

 Title   : _is_float()
 Usage   : _is_float($value);
 Function: checks that $value is floating point
 Returns : returns defined
 Args    : number

=cut

##################################

sub _is_float {
    defined $_[0] && $_[0] =~ /^[+-]?\d+(\.\d+)?$/;
}

##################################

=head1 LICENSE AND COPYRIGHT

 Copyright (C) 2019 Damien M. O'Halloran
 GNU GENERAL PUBLIC LICENSE

=cut

1;
