#!/usr/bin/perl
#
# Run after an AppConfig of this app is installed including all accessories.

use strict;
use cldstr::runtime::Utils;

my $appconfigid = $varMap->{appconfig}->{appconfigid};

my $appconfigDir = "/var/cldstr/wagn.org/wagn/ws/$appconfigid";
#my $confDDir     = "$appconfigDir/conf.d";
#my $confIni      = "$appconfigDir/conf/trac.ini";

$log->debug( "operation = $operation" );


if( $operation eq 'install' ) {
  
  $log->debug( "appconfigid = $appconfigid; appconfigDir = $appconfigDir" );
#
#    cldstr::runtime::Utils::saveFile( $confIni, <<CONTENT );
##
## Auto-generated from $confDDir, do not modify.
##
#CONTENT
#
#    if( <$confDDir/*> ) {
#        my $cmd = "cat $confDDir/* >> $confIni";
#
#        my $result = cldstr::runtime::Utils::myexec( $cmd );
#        if( $result ) {
#            
#        }
#    }
#
#    foreach my $cmd ( "upgrade", "wiki upgrade" ) {
#        my $result = cldstr::runtime::Utils::myexec( "sudo -u www-data trac-admin '$appconfigDir' $cmd" );
#        if( $result ) {
#            $log->error( "Failed to trac-admin '$appconfigDir' $cmd" );
#        }
#    }
}

1;