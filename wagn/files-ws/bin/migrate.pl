#!/usr/bin/perl
#
# This runs after a Wagn AppConfig installation (including accessories).
# Note that Ruby on Rails migrations require the application code, so this is run from
# the ws role (not the ctrl role).  However, this optimizes the process by copying the 
# authoritative version stamp from the db (in the schema_migrations table) into a version.txt
# stamp in the appconfig data dir.  So that even if this is run in multiple ws servers, the
# migrations themselves will not be re-run

use strict;
use cldstr::runtime::Utils;

my $wsdir = "/usr/cldstr/wagn.org/wagn/ws";
my $appconfigid = $varMap->{appconfig}->{appconfigid};

$log->debug( "Wagn postappconfiginst called for AppConfig: $appconfigid" );      

if ( $operation eq 'install' ) {
  my $cmd = "env APPCONFIGID=$appconfigid $wsdir/bin/migrate.rb";
  my $result = cldstr::runtime::Utils::myexec( $cmd );
  
  if ($result) {
    $log->error("Wagn Migration FAILURE. For details see /var/log/cldstr+wagn.org+wagn+ws/$appconfigid.log\ncmd = $cmd");
  } else {
    $log->debug("Wagn Migration SUCCESS. For details see /var/log/cldstr+wagn.org+wagn+ws/$appconfigid.log");
  }
}      


my $restartcmd = "$wsdir/web/tmp/restart.txt"; 
my $restartresult = cldstr::runtime::Utils::myexec( $restartcmd );
if( $restartresult ) {
    $log->error( "Wagn Restart Failure: $restartresult" );
}
# restarts Passenger.



1;