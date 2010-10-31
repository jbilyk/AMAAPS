#!perl -w

# Author: Jeff Bilyk
# Date: October 31, 2010
# Purpose:        To take entries from the database used by OpenAudit and
#                 insert them into the database used by NagioSQL so that
#                 new hosts will be monitored automatically by Nagios.
#                 Once new hosts are in the database, trigger a file write
#                 so that config files for Nagios will be updated and the
#                 service is ready to be reloaded.
# Implementation: Two MySQL databases are accessed: OpenAudit and 
#                 db_nagiosql_v3.  First, servers that are running Microsoft
#                 Windows Server operating systems are selected and added
#                 to the windowsservers hostgroup in Nagios.  Then, the following
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

my $dsn = "dbi:mysql:$database:$host:$port";

my $DBIconnect = DBI->connect($dsn,$user,$password);

# Exchange servers

my $myquery = "select distinct system.system_name,system.net_ip_address from system,software where software_name like '%icrosoft%xchange' and software.software_uuid = system.system_uuid;";

my $runit = $DBIconnect->prepare($myquery);

$runit->execute();

printf "Exchange servers:\n";

while (my @results = $runit->fetchrow_array()) {
	printf $results[0];
	printf "  ";
	printf $results[1];
	printf "\n";
}

# SQL Servers

printf "\nSQL Servers\n\n";

$myquery = "select distinct system.system_name,system.net_ip_address from system,software where software_name like '%icrosoft%SQL%erver%20%' and software.software_uuid = system.system_uuid;";

$runit = $DBIconnect->prepare($myquery);

$runit->execute();

while (@results = $runit->fetchrow_array()) {
	printf $results[0];
	printf "  ";
	printf $results[1];
	printf "\n";
}

# Lotus Domino servers

printf "\nDomino Servers\n\n";

$myquery = "select distinct system.system_name,system.net_ip_address from system,software where software_name like '%otus%omino%' and software.software_uuid = system.system_uuid;";

$runit = $DBIconnect->prepare($myquery);

$runit->execute();

while (@results = $runit->fetchrow_array()) {
	printf $results[0];
	printf "  ";
	printf $results[1];
	printf "\n";
}


# Windows Servers

printf "\nWindows Servers\n\n";

$myquery = "select distinct system.system_name,system.net_ip_address from system where system_os_name like '%icrosoft%erver%'";

$runit = $DBIconnect->prepare($myquery);

$runit->execute();

while (@results = $runit->fetchrow_array()) {
        printf $results[0];
        printf "  ";
	printf $results[1];
	printf "\n";
}


exit 0
