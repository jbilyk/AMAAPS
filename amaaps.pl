#!/usr/bin/perl -w

# Author: Jeff Bilyk
# Date: January 18, 2011
# Purpose:        To take entries from the database used by OpenAudit and
#                 insert them into the database used by NagioSQL so that
#                 new hosts will be monitored automatically by Nagios.
#                 Once new hosts are in the database, trigger a file write
#                 so that config files for Nagios will be updated and the
#                 service is ready to be reloaded.
# Implementation: Two MySQL databases are accessed: OpenAudit and 
#                 db_nagiosql_v3.  First, servers that are running Microsoft
#                 Windows Server operating systems are selected and added
#                 to the tbl_host table.  Then they're added to the windowsservers
#		  hostgroup in Nagios.  Then, the following
#                 software is detected and added to a hostgroup for each:
#                 Exchange, SQL Server, Lotus Domino.

use DBI;
use DBD::mysql;

my $database = "openaudit";
my $host = "localhost";
my $port = "3306";
my $tablename = "tbl_host";
my $user = "jeff";
my $password = "testing";

my @tempresult;
my @exchangeservers;
my @sqlservers;
my @dominoservers;

my $dsn = "dbi:mysql:$database:$host:$port";

my $DBIconnect = DBI->connect($dsn,$user,$password);



######################################################
# Windows Servers
######################################################


# Get all Microsoft Windows Server OS
$myquery = "select distinct system.system_name,system.net_ip_address from system where system_os_name like '%icrosoft%erver%'";

$runit = $DBIconnect->prepare($myquery);
$runit->execute();

while (@results = $runit->fetchrow_array()) {

	#OpenAudit 0 pad's the IP addresses - strip the leading 0's
	$results[1] =~ s/^0//;
	$results[1] =~ s/\.0/\./;
	$results[1] =~ s/\.0/\./;
	$results[1] =~ s/\.0/\./;

	# Insert hostname, alias, address, template - the rest of the info will be null or 0 and will be filled in via template
	$myquery = "insert into db_nagiosql_v3.tbl_host (host_name, alias, address, use_template) VALUES ('$results[0]', '$results[0]', '$results[1]', '1')";
	$runit1 = $DBIconnect->prepare($myquery);
	$runit1->execute();
}

######################################################
# Exchange servers
######################################################


my $myquery = "select distinct system.system_name from system,software where software_name like '%icrosoft%xchange' and software.software_uuid = system.system_uuid;";

$runit = $DBIconnect->prepare($myquery);
$runit->execute();

# Get id for the hostgroup
$myquery = "select id from db_nagiosql_v3.tbl_hostgroup where hostgroup_name = 'exchangeservers'";
$runit1 = $DBIconnect->prepare($myquery);
$runit1->execute();
@hostgroupid = $runit1->fetchrow_array();

while (@results = $runit->fetchrow_array()) {
	# Get id for the host
	$myquery = "select id from db_nagiosql_v3.tbl_host where tbl_host.host_name = '$results[0]'";
	$runit1 = $DBIconnect->prepare($myquery);
	$runit1->execute();
	@hostid = $runit1->fetchrow_array();

	# link the host to the hostgroup
	$myquery = "insert into db_nagiosql_v3.tbl_lnkHostgroupToHost (idMaster,idSlave) VALUES ('$hostid[0]', '$hostgroupid[0]')";
	$runit1 = $DBIconnect->prepare($myquery);
	$runit1->execute();
}


###########################################################
# SQL Servers
###########################################################


$myquery = "select distinct system.system_name,system.net_ip_address from system,software where software_name like '%icrosoft%SQL%erver%20%' and software.software_uuid = system.system_uuid;";

$runit = $DBIconnect->prepare($myquery);
$runit->execute();

# Get id for the hostgroup
$myquery = "select id from db_nagiosql_v3.tbl_hostgroup where hostgroup_name = 'sqlservers'";
$runit1 = $DBIconnect->prepare($myquery);
$runit1->execute();
@hostgroupid = $runit1->fetchrow_array();

while (@results = $runit->fetchrow_array()) {
        # Get id for the host
        $myquery = "select id from db_nagiosql_v3.tbl_host where tbl_host.host_name = '$results[0]'";
        $runit1 = $DBIconnect->prepare($myquery);
        $runit1->execute();
        @hostid = $runit1->fetchrow_array();
        # link the host to the hostgroup
        $myquery = "insert into db_nagiosql_v3.tbl_lnkHostgroupToHost (idMaster,idSlave) VALUES ('$hostid[0]', '$hostgroupid[0]')";
        $runit1 = $DBIconnect->prepare($myquery);
	$runit1->execute();
}


############################################################
# Lotus Domino servers
############################################################


$myquery = "select distinct system.system_name,system.net_ip_address from system,software where software_name like '%otus%omino%' and software.software_uuid = system.system_uuid;";
$runit = $DBIconnect->prepare($myquery);
$runit->execute();

# Get id for the hostgroup
$myquery = "select id from db_nagiosql_v3.tbl_hostgroup where hostgroup_name = 'lotusnotesservers'";
$runit1 = $DBIconnect->prepare($myquery);
$runit1->execute();
@hostgroupid = $runit1->fetchrow_array();

while (@results = $runit->fetchrow_array()) {
        # Get id for the host
        $myquery = "select id from db_nagiosql_v3.tbl_host where tbl_host.host_name = '$results[0]'";
        $runit1 = $DBIconnect->prepare($myquery);
        $runit1->execute();
        @hostid = $runit1->fetchrow_array();
        # link the host to the hostgroup
        $myquery = "insert into db_nagiosql_v3.tbl_lnkHostgroupToHost (idMaster,idSlave) VALUES ('$hostid[0]', '$hostgroupid[0]')";
        $runit1 = $DBIconnect->prepare($myquery);
	$runit1->execute();
}

##  ADD MORE HOSTGROUPS HERE BY COPYING ABOVE LINES AND MODIFYING HOSTGROUP QUERY

exit 0
