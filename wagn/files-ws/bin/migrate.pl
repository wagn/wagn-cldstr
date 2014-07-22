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
my $hostname = $varMap->{appconfig}->{site}->{hostname};
my $appconfigdir = "/var/cldstr/wagn.org/wagn/ws/$appconfigid";
my $logfile = "/var/log/cldstr+wagn.org+wagn+ws/$hostname-$appconfigid.log";


$log->debug( "Wagn postappconfiginst called for AppConfig: $appconfigid" );


my $tmpdir = "$appconfigdir/tmp";
my $tmpcleancommand = "rm -rf $tmpdir/*";
my $tmpcleanresult = cldstr::runtime::Utils::myexec( $tmpcleancommand );
if( $tmpcleanresult ) {
  my $msg = "Wagn error cleaning tmp directory $tmpcleanresult";
  $log->error( $msg );
}


if ( $operation eq 'install' ) {
  my $cmd = "env LOGFILE=$logfile APPCONFIGID=$appconfigid $wsdir/bin/migrate.rb";
  my $result = cldstr::runtime::Utils::myexec( $cmd );
  
  if ($result) {
    my $msg = "Wagn Migration FAILURE. For details see $logfile\ncmd = $cmd";
    $log->error( $msg );
  } else {
    my $msg = "Wagn Migration SUCCESS. For details see $logfile";
    $log->debug( $msg );
  }
}      


my $restartcommand = "touch $tmpdir/restart.txt";
my $restartresult = cldstr::runtime::Utils::myexec( $restartcommand );
if( $restartresult ) {
  my $msg = "Wagn Restart Failure: $restartresult";
  $log->error( $msg );
  
}
# restarts Passenger.



1;
