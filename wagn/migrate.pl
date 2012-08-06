#!/usr/bin/perl
#


use strict;
use cldstr::runtime::Utils;


my $appconfigid = $varMap->{appconfig}->{appconfigid};
my $projectName = $varMap->{thisitem}->{customizationpoints}->{projectname}->{value};
my $projectLogo = $varMap->{thisitem}->{customizationpoints}->{projectlogo}->{filename};


#etc etc


if( $operation eq 'install' ) {
  
   $appdir = "/var/cldstr/wagn.org/wagn/ws/$appconfigid";
   if (file_equal("$appdir/version.txt", "$appdir/web/db/version.txt") {

     # run the migration
     my $cmd = "bundle exec env RAILS_ENV=production WAGN_CONFIG_FILE=$appdir/wagn.yml rake db:migrate_and_stamp_file";

     my $err;
     my $result = cldstr::runtime::Utils::myexec( $cmd, undef, undef, \$err );
     if $result { print "Error from $cmd\n$err"; }
   } # else db version is current, skip migration


   }

if( $operation eq 'remove' ) {
}


1;



                
