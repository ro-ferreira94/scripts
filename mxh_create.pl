#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Std;
use DBI;
use String::Random;


# main conf.
my $cluster_mta_in = 'mta-in.u.inova.com.br';
my $notify_email = 'suporte.inova@inova.net';

# db conf.
my $db_name = 'mxhero';
my $db_host = 'localhost';
my $db_user = 'mxhero';
my $db_pass = 'mxhero';
my $db_port = '3306';

# ldap sync conf. prod
my $ldap_url = 'ldap.u.inova.com.br';
my $ldap_port = '389';
my $ldap_user = 'uid=zimbra,cn=admins,cn=zimbra';
my $ldap_pass = 'GPqZe2MCx';
my $dir_type = 'zimbra';

# ldap sync conf. lab
#my $ldap_url = '192.168.3.66';
#my $ldap_port = '389';
#my $ldap_user = 'uid=bruno,ou=people,dc=zimbra,dc=mxhero,dc=com';
#my $ldap_pass = 'sta+his';
#my $dir_type = 'zimbra';



my %opts = ();
getopts('b:w:g:m:d:l:',\%opts);

my $domain = $opts{d} if $opts{d};
my $list_file = $opts{l} if $opts{l};
my $white_list_file = $opts{w} if $opts{w};
my $black_list_file = $opts{b} if $opts{b};
my $members_list_file = $opts{m} if $opts{m};
my $group_name = $opts{g} if $opts{g};

if ( ! $domain && ! $list_file ){
        print "Please tell me a domain or a list of domains.\n";
        &usage;
        exit 1;
}
elsif ( $domain && $list_file ){
	print "Only one option is available.\n";
	&usage;
	exit 1;
}
elsif ( $white_list_file && $domain && ( ! $black_list_file && ! $members_list_file && ! $group_name && ! $list_file ) ){
	&addWhiteList($white_list_file,$domain,$db_name,$db_host,$db_port,$db_user,$db_pass);
	exit 0;
}
elsif ( $black_list_file && $domain && ( ! $white_list_file && ! $members_list_file && ! $group_name && ! $list_file ) ){
	&addBlackList($black_list_file,$domain,$db_name,$db_host,$db_port,$db_user,$db_pass);
	exit 0;
}
elsif ( $domain && $group_name && $members_list_file && ( ! $white_list_file && ! $black_list_file && ! $list_file ) ){
	&addMemberToGroup($domain,$members_list_file,$group_name,$db_name,$db_host,$db_port,$db_user,$db_pass);
	exit 0;
}


if ( $list_file ){
	open(LIST,"<$list_file") or die "$!";
	my @domain_list = <LIST>;
	close LIST;

	for my $domain(@domain_list){
		my @exist_domain;
		chomp($domain);
		next if ( $domain =~ m/^#/ || $domain =~ m/^$/ );

		@exist_domain = &validate($domain,$db_name,$db_host,$db_port,$db_user,$db_pass);

		if ( ! @exist_domain ){
			chomp($domain);
			&insert($domain,$db_name,$db_host,$db_port,$db_user,$db_pass);
		}
		else{
			print "Domain: @exist_domain already in mxhero's database please check this domain and run the script again!\n";
			exit 1;
		}
	}

}

if ( $domain ){
	my $exist_domain = &validate($domain,$db_name,$db_host,$db_port,$db_user,$db_pass);

	my @exist_domain;
        chomp($domain);
        @exist_domain = &validate($domain,$db_name,$db_host,$db_port,$db_user,$db_pass);


        if ( ! @exist_domain ){
        	chomp($domain);
                &insert($domain,$db_name,$db_host,$db_port,$db_user,$db_pass);
        }
        else{
                print "Domain: @exist_domain already in mxhero's database please check those domains and run the script again!\n";
        }
}



######
# sub
sub usage {
        print "INOVA - Creates domains on mxhero's database.
               Param:   -d : domain to create.
                        -l : file containing a domain list to create.
			-w : file containing a mail list to whitelist.
			-b : file containing a mail list to blacklist.
			-g : group name to create.
			-m : file containing a member list to add to a group.

               Usage:
               create single domain:			mxh-create.pl -d inova.com.br
	       create domains from a list:		mxh-create.pl -l domainList.txt
	       create whitelist to antispam rule:	mxh-create.pl -d inova.com.br -w whiteList.txt
	       create blacklist rule:			mxh-create.pl -d inova.com.br -b blackList.txt
	       create group with member list		mxh-create.pl -d inova.com.br -g groupname -m memberList.txt\n";


}


sub validate{
	my $domain = shift; my $db_name = shift; my $db_host = shift; my $db_port = shift; my $db_user = shift; my $db_pass = shift;

	if ( $domain =~ m/\*/ ){
	        print "wild card not allowed!\n";
	        exit 1;
	}

	$domain =~ s| ||g;

	my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=$db_port";
	my $dbh = DBI->connect($dsn, $db_user, $db_pass);

	my $query = $dbh->prepare("SELECT * FROM domain WHERE domain = '$domain'");
	$query->execute;

	my @exist_domain;
	if ( $query->rows > 0 ){

		while ( my $row = $query->fetchrow_hashref() ) {
			push(@exist_domain,"$domain ");
		}
	}

	$query->finish;
	return @exist_domain;
}


sub insert{
        my $domain = shift; my $db_name = shift; my $db_host = shift; my $db_port = shift; my $db_user = shift; my $db_pass = shift;

	$domain =~ s| ||g;

        my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=$db_port";
        my $dbh = DBI->connect($dsn, $db_user, $db_pass);
	my $query;

	#insert domain
	$dbh->do("INSERT INTO domain(domain, creation, server, updated) VALUES ('$domain', NOW(), '$cluster_mta_in', NOW())");

	$dbh->do("INSERT INTO domains_aliases(alias, created, domain) VALUES ('$domain', NOW(), '$domain')");

	#insert ldap sync
	my $ldap_base = $domain;
	$ldap_base =~ s|\.|,dc=|g;

	$dbh->do("INSERT INTO domain_adldap(domain, address, base, override_flag, password, port, user, directory_type, next_update) VALUES('$domain', '$ldap_url', 'dc=$ldap_base', 1, '$ldap_pass', '$ldap_port', '$ldap_user', '$dir_type', NOW() + INTERVAL 1 MINUTE)");

	# random user password
	my $random = new String::Random;
	my $adm_user_pass = $random->randpattern("ccCCnn");

	#granting acess to admin panel
	$dbh->do("INSERT INTO app_users(creation,enabled,last_name,locale,name,notify_email,password,user_name,domain) VALUES (NOW(), 1, '$domain', 'pt_BR', '$domain', '$notify_email', MD5('$adm_user_pass'), '$domain', '$domain')");

	print "domain: $domain | pass: $adm_user_pass\n";

	#get admin id
	$query = $dbh->prepare("SELECT id FROM app_users WHERE domain = '$domain'");
        $query->execute;
        my $app_user_id = $query->fetchrow_hashref();
        $query->finish;

	$dbh->do("INSERT INTO app_users_authorities (app_users_id, authorities_id) VALUES ($app_user_id->{'id'}, (SELECT id FROM authorities WHERE authority = 'ROLE_DOMAIN_ADMIN'))");

	#anti-spam rule
	$dbh->do("INSERT INTO features_rules (created, enabled, label, updated, domain_id, feature_id) VALUES (NOW(), 1, 'Antispam', NOW(), '$domain', (SELECT id FROM features WHERE component = 'org.mxhero.feature.externalantispam'))");

	#get antispam rule_id.
	$query = $dbh->prepare("SELECT id FROM features_rules WHERE domain_id = '$domain' AND label = 'Antispam'");
	$query->execute;
	my $rule_id = $query->fetchrow_hashref();
        $query->finish;


	$dbh->do("INSERT INTO features_rules_properties (property_key, property_value, rule_id) VALUES ('header.key', 'X-CMAE-Score', $rule_id->{'id'}), ('header.value', '(9[6-9]|100).*', $rule_id->{'id'}), ('header.managed', 'true', $rule_id->{'id'}),('header.id', '2', $rule_id->{'id'}), ('action.selection', 'receive', $rule_id->{'id'}), ('prefix.value', '[SPAM]', $rule_id->{'id'}) ,('add.header.key', 'X-Spam-Flag', $rule_id->{'id'}) ,('add.header.value', 'YES', $rule_id->{'id'})");


	$dbh->do("INSERT INTO features_rules_directions (directiom_type, free_value, rule_id) VALUES ('anyone', 'anyone', $rule_id->{'id'})");

	$dbh->do("INSERT INTO features_rules_directions (directiom_type, domain, free_value, rule_id) VALUES ('domain', '$domain', '$domain', $rule_id->{'id'})");


	#get from_direction_id and to_direction_id.
	$query=$dbh->prepare("SELECT id FROM features_rules_directions WHERE directiom_type='anyone' AND free_value = 'anyone' AND rule_id = $rule_id->{'id'}");
	$query->execute;
	my $from_direction_id = $query->fetchrow_hashref();
        $query->finish;

	#
	$query=$dbh->prepare("SELECT id FROM features_rules_directions WHERE directiom_type='domain' AND domain = '$domain' AND free_value = '$domain' AND rule_id = $rule_id->{'id'}");
        $query->execute;
        my $to_direction_id = $query->fetchrow_hashref();
        $query->finish;


	$dbh->do("UPDATE features_rules SET from_direction_id = $from_direction_id->{'id'} WHERE id = $rule_id->{'id'}");

	$dbh->do("UPDATE features_rules SET to_direction_id = $to_direction_id->{'id'} WHERE id = $rule_id->{'id'}");



	#hero attach rule
	$dbh->do("INSERT INTO features_rules (created, enabled, label, updated, domain_id, feature_id) VALUES (NOW(), 1, 'Hero Attach', NOW(), '$domain', (SELECT id FROM features WHERE component = 'org.mxhero.feature.attachmentlink'))");

	#get attach rule_id.
	$query = $dbh->prepare("SELECT id FROM features_rules WHERE domain_id = '$domain' AND label = 'Hero Attach'");
	$query->execute;
	$rule_id = $query->fetchrow_hashref();
	$query->finish;

	$dbh->do("INSERT INTO features_rules_properties (property_key, property_value, rule_id) VALUES ('max.size', '10', $rule_id->{'id'}), ('action.selection', 'return', $rule_id->{'id'}), ('return.message', 'O arquivo \${file-name} foi accessado por \${mxrecipient}.', $rule_id->{'id'}),('locale', 'pt_BR', $rule_id->{'id'})");


	$dbh->do("INSERT INTO features_rules_directions (directiom_type, domain, free_value, rule_id) VALUES ('domain', '$domain', '$domain', $rule_id->{'id'})");

	$dbh->do("INSERT INTO features_rules_directions (directiom_type, free_value, rule_id) VALUES ('anyone', 'anyone', $rule_id->{'id'})");

	#get from_direction_id and to_direction_id.
	$query=$dbh->prepare("SELECT id FROM features_rules_directions WHERE directiom_type='anyone' AND free_value = 'anyone' AND rule_id = $rule_id->{'id'}");
	$query->execute;
	$to_direction_id = $query->fetchrow_hashref();
	$query->finish;

	#
	$query=$dbh->prepare("SELECT id FROM features_rules_directions WHERE directiom_type='domain' AND domain = '$domain' AND free_value = '$domain' AND rule_id = $rule_id->{'id'}");
	$query->execute;
	$from_direction_id = $query->fetchrow_hashref();
	$query->finish;

	#
        $dbh->do("UPDATE features_rules SET from_direction_id = $from_direction_id->{'id'} WHERE id = $rule_id->{'id'}");

        $dbh->do("UPDATE features_rules SET to_direction_id = $to_direction_id->{'id'} WHERE id = $rule_id->{'id'}");

}

sub addWhiteList{
	my $white_list_file = shift; my $domain = shift; my $db_name = shift; my $db_host = shift; my $db_port = shift; my $db_user = shift; my $db_pass = shift;

        my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=$db_port";
        my $dbh = DBI->connect($dsn, $db_user, $db_pass);

	#check if antispam rule exists
        my $query = $dbh->prepare("SELECT id FROM features_rules WHERE domain_id = '$domain' AND feature_id = (SELECT id FROM features WHERE component = 'org.mxhero.feature.externalantispam')");
        $query->execute;

        if ( $query->rows == 0 ){
		print "Antispam rule not found on $domain\n";
		exit 1;
        }
        $query->finish;


        #get antispam rule_id.
        $query = $dbh->prepare("SELECT * FROM features_rules WHERE domain_id = '$domain' AND feature_id = (SELECT id FROM features WHERE component = 'org.mxhero.feature.externalantispam')");
        $query->execute;

	my @rules_ids;
	while ( my $row = $query->fetchrow_hashref() ) {
		print "id: $row->{'id'}\ndominio: $row->{'domain_id'}\nlabel: $row->{'label'}\n______________________________________\n";
		push(@rules_ids,"$row->{'id'}");
	}
        $query->finish;

	print "Insert rule id which you wish create white list:\n";
	my $rule_id = <STDIN>;
	chomp $rule_id;

	while ( ! grep(/^$rule_id$/, @rules_ids) ){
		print "rule_id $rule_id invalid, please insert a valid id: " . join(",", @rules_ids) . "\n";
		$rule_id = <STDIN>;
		chomp $rule_id;
	}

	open(WHITELST,"<$white_list_file") or die "$!";
	my @white_list = <WHITELST>;

	#insert white list on antispam rule
	foreach (@white_list){
		chomp $_;

		$_ =~ s| ||g;

		next if ( $_ =~ m/^$/ || $_ =~ m/^#/ );

		if ( $_ =~ m/\@/ ){
		        $dbh->do("INSERT INTO features_rules_properties (property_key, property_value, rule_id) VALUES ('email.list', '$_', $rule_id)");
			print "adding $_ on Antispam's white list (rule_id: $rule_id)\n";
		}
		else{
			$dbh->do("INSERT INTO features_rules_properties (property_key, property_value, rule_id) VALUES ('email.list', '\@$_', $rule_id)");
                        print "adding \@$_ on Antispam's white list (rule_id: $rule_id)\n";
		}

	}


}

sub addBlackList{
	my $black_list_file = shift; my $domain = shift; my $db_name = shift; my $db_host = shift; my $db_port = shift; my $db_user = shift; my $db_pass = shift;

        my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=$db_port";
        my $dbh = DBI->connect($dsn, $db_user, $db_pass);

        #check if blacklist rule exists
        my $query = $dbh->prepare("SELECT id FROM features_rules WHERE domain_id = '$domain' AND feature_id = (SELECT id FROM features WHERE component = 'org.mxhero.feature.blocklist')");
        $query->execute;

        if ( $query->rows == 0 ){
                print "Any blacklist rule found on $domain\n";
                exit 1;
        }
        $query->finish;



        #get blacklist rule_id.
        $query = $dbh->prepare("SELECT * FROM features_rules WHERE domain_id = '$domain' AND feature_id = (SELECT id FROM features WHERE component = 'org.mxhero.feature.blocklist')");
        $query->execute;

        my @rules_ids;
        while ( my $row = $query->fetchrow_hashref() ) {
                print "id: $row->{'id'}\ndominio: $row->{'domain_id'}\nlabel: $row->{'label'}\n______________________________________\n";
                push(@rules_ids,"$row->{'id'}");
        }
        $query->finish;

        print "Insert rule id which you wish create white list:\n";
        my $rule_id = <STDIN>;
	chomp $rule_id;

        while ( ! grep(/^$rule_id$/, @rules_ids) ){
                print "rule_id $rule_id invalid, please insert a valid id: " . join(",", @rules_ids) . "\n";
                $rule_id = <STDIN>;
                chomp $rule_id;
        }

	#insert black list emails
	open(BLACKLST,"<$black_list_file") or die "$!";
	my @black_list = <BLACKLST>;

	#insert white list on antispam rule
	foreach (@black_list){
		chomp $_;
		if ( $_ =~ m/\@/ ){
			$dbh->do("INSERT INTO features_rules_properties (property_key, property_value, rule_id) VALUES ('email.list', '$_', $rule_id)");
			print "adding $_ on Blacklist rule (rule_id: $rule_id)\n";
		}
		else{
			$dbh->do("INSERT INTO features_rules_properties (property_key, property_value, rule_id) VALUES ('email.list', '\@$_', $rule_id)");
                        print "adding \@$_ on Blacklist rule (rule_id: $rule_id)\n";
		}

	}

}

sub addMemberToGroup{

	my $domain = shift ; my $members_list_file = shift ; my $group_name = shift ; my $db_name = shift; my $db_host = shift; my $db_port = shift; my $db_user = shift; my $db_pass = shift;

	if ( $group_name =~ m/\*/ ){
		print "wild card not allowed!\n";
		exit 1;
	}


	my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=$db_port";
        my $dbh = DBI->connect($dsn, $db_user, $db_pass);

	my $query = $dbh->prepare("SELECT * FROM groups WHERE domain_id = '$domain' AND name = '$group_name'");
	$query->execute;

	if ( $query->rows == 0 ){
		$dbh->do("INSERT INTO groups (domain_id, name, created, description, updated) VALUES ('$domain', '$group_name', NOW(),'$group_name',NOW() )");
	}


	open(MEMBERLST,"<$members_list_file") or die "$!";
	my @members_list = <MEMBERLST>;

	foreach (@members_list){
		chomp $_;
		if ( $_ =~ m/\@/ ){
			$_ =~ /^(.+?)\@/;
			my $account = $1;
			next if $account =~ m/\*/;

			#check if antispam rule exists
			$query = $dbh->prepare("SELECT * FROM email_accounts WHERE account = '$account' AND domain_id = '$domain'");
			$query->execute;

			if ( $query->rows == 0 ){
				print "account $account\@$domain do not exist\n";
				next;
			}
			$query->finish;

			$dbh->do("UPDATE email_accounts SET group_name = '$group_name' WHERE account = '$account' AND domain_id = '$domain'")
		}
	}
}



