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

#my $appconfigid = 'a0005';
#my $operation = 'install';
my $appconfigid = $varMap->{appconfig}->{appconfigid};
my $appconfigDir = "/var/cldstr/wagn.org/wagn/ws/$appconfigid";

$log->debug( "Wagn postappconfiginst called for AppConfig: $appconfigid" );      


exit 1 unless ( $appconfigid eq 'a0005' );

chdir('../web'); # get us into the web directory, from which the migrate command (and the restart) must be run


if ( $operation eq 'install' ) {

  open DBVERSION, "../version.txt"; # this is the "current" version and must be set manually to trigger the migration
  my $dbversion = <DBVERSION>;
  
  open APPCONFIGVERSION, "$appconfigDir/version.txt";
  my $appconfigVersion = <APPCONFIGVERSION>;

  print "dbversion = $dbversion; appconfigVersion = $appconfigVersion\n";

  if (!$appconfigVersion || ($appconfigVersion < $dbversion)) {
    #my $result = cldstr::runtime::Utils::myexec( $cmd );
    my $cmd = "bundle exec env RAILS_ENV=production WAGN_CONFIG_FILE=$appconfigDir/wagn.yml rake db:migrate_and_stamp --trace";
    my $result = `$cmd`;
    
    close APPCONFIGVERSION;
    open NEWAPPCONFIGVERSION, "$appconfigDir/version.txt";
    $appconfigVersion = <NEWAPPCONFIGVERSION>;
    
    if (!$appconfigVersion || ($appconfigVersion < $dbversion)) {
      $log->error( "Wagn Migration failed for AppConfig $appconfigid:\n  $cmd\n  $result");
    } elsif ($result) {
      $log->debug( "Migrated Wagn for AppConfig $appconfigid:\n $result" );      
    }
  }

}

`touch tmp/restart.txt`;  # restarts Passenger.  this has been moved here from the cldstr-manifest because it produced errors there.



1;