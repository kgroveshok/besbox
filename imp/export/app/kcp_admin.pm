#!/usr/bin/perl
# kcp admin application
# (c)2005 ksoft creative projects
#
#
#
# Date		Description
# ------------------------------
#
# 18/10/05      Timesync support
#
#
# todo:
# workgroup setup:
#    set /etc/HOSTNAME and hosts entry on computer name
# storage
#    detect extra storage only and mount to /storage
#
# fill in text help for all settings
# power up and down sceudule
# select graphical or text front sceen ie mozilla or lynx (if graphical warn about heat and cooling required)
# switch off dhcp client if not on network (replace network configure)
# start freevo?

#use strict;

#print "hello";

##my $LIBS_DIR = "/home/httpd/cgi-bin/libs";
#require "$LIBS_DIR/utils.pm";

#use CGI ':standard';

@mount_point ="";

sub Storage( $ ) {
	my ($device ) = @_;
	my $scantype;

	# Report details on the chosen storage device

	my $ret;

	 $ret = "<p class=selected>";

 	if( ( substr($query->param("deviceinfo"), -1, 1)+0.0 ) eq 0 ) {
	 	$ret = $ret .  "Partitions available on " ;
		$scantype=1;
	}
	else {
		$ret = $ret . "This Partition ";
		$scantype=2;
	}

	$ret = $ret . $device . ":</p>" ;

	#
	#$ret = $ret . $scantype;



	if( $scantype eq 1 ) {
		# scan partitions and (dis)mount parts (but not root!)
		# display current mount point
		# set into fstab


	}
	else {
		# list if mounted
		# display current useage
		# detect if this is mysql storage ie /opt/extra
		# offer mysql storage if nothing mounted

		$ret = $ret . "Mounted on: " . $mount_point{"/dev/$device"} . "<br>" ;

		# offer unmount if not root

#		if( $mount_point{"/dev/$device"} ne "/" ) {
			$ret = $ret . "<a href=\"/cgi-bin/kcp_index.cgi?hdddeact=$device\">[Deactivate]</a>";
		#}

		# offer as switch to active data storage

		if( $mount_point{"/dev/$device"} eq "/" ) {
			$ret = $ret . "<a href=\"/cgi-bin/kcp_index.cgi?hddact=System\">[Use System Storage]</a>";
		} else {
			$ret = $ret . "<a href=\"/cgi-bin/kcp_index.cgi?hddact=$device\">[Use As Storage]</a>";
		}
	}



return $ret;
}


@kcp_menu = (
	{
		menu_option => 0,
		menu_name => "dum",
	},
	{
		menu_option => 1,
		menu_name => "Storage Devices",
	},
#	{
#		menu_option => 2,
#		menu_name => "Scanners",
#	},
	{
		menu_option => 3,
		menu_name => "Workgroups",
	},
#	{
#		menu_option => 4,
#		menu_name => "NFS",
#	},
	{
		menu_option => 5,
		menu_name => "Applications",
	},
	{
		menu_option => 6,
		menu_name => "Site Style",
	},
	{
		menu_option => 9,
		menu_name => "System Time",
	},
	{
		menu_option => 7,
		menu_name => "Email",
	},
	{
		menu_option => 8,
		menu_name => "Backup",
	},
	{
		menu_option => -1,
		menu_name => "",
	},
		{
		menu_option => 20,
		menu_name => "Reboot",
	},

			{
		menu_option => 21,
		menu_name => "Shutdown",
	},
			{
		menu_option => 22,
		menu_name => "Power Schedule",
	},

) ;


# Main Function

# find out if a new application has been selected

#$query = new CGI ;

# detect called as a menu or main body

sub menu() {

	# Menu options

	for (my $i=1; $kcp_menu[$i]; $i++) {
#		print div({-class=>"menuitem"}, a( {-href=>"/cgi-bin/kcp_index.cgi?kcp_menu=$kcp_menu[$i]{menu_option}"}, $kcp_menu[$i]{menu_name}));

menuItem( "/cgi-bin/kcp_index.cgi?kcp_menu=$kcp_menu[$i]{menu_option}", $kcp_menu[$i]{menu_name});

	}

	# Media Box Confings
	print hr();
	menuItem( "/cgi-bin/admin/admin_network.cgi", "Change Network Settings" ) ;
	menuItem( "/cgi-bin/admin/admin_log.cgi", "View System and Applications Logs" ) ;
	menuItem( "/cgi-bin/admin/admin_stats.cgi", "View Current System Stats" ) ;
	menuItem( "/cgi-bin/admin/admin_ppp.cgi" , "Configure modem" ) ;
	#menuItem( "/cgi-bin/admin/admin_users.cgi" , "Change passwords for users" ) ;
	#menuItem( "/cgi-bin/admin/admin_httpd_users.cgi" , "Change passwords for http admin access" ) ;
	menuItem( "/cgi-bin/admin/admin_volctrl.cgi" , "Volume Control" ) ;
 

}

sub main() {

	# main body

	#print "This is the main application body";

	#print "Currently using menu option:";
	#print $this_menu;
	for (my $i=1; $kcp_menu[$i]; $i++) {
	if( $kcp_menu[$i]{menu_option} eq $this_menu ) {
		print p( {-class=>"selected"},$kcp_menu[$i]{menu_name});
	}
	}


	# device management

	if( $this_menu eq 1 ) {


		if( $query->param('hddact') ) {
			print $query->param('hddact')." now used for storge.";
			# shutdown mysql OK
			# mount device
			# create directory structure
			# restart mysql OK

			if( $query->param('hddact') eq "System" ) {
				# if using the system storage then point back to root
				#$hddmysql="\/opt\/mysql\/var";
				#$hddstorage="/opt/storage";
				$hddstorage="hdb1";
				print h2( "You should only deciding to use the internal storage drive under instruction or if you are certain you know what you are doing!" ) ;
			}
			else {
				# now want to use external (to system) storage so point to common mount point
				#$hddmysql="\/opt\/extra\/kcp\/mysql";
				#$hddstorage="/opt/extra/kcp/storage";
				$hddstorage=$query->param('hddact');

#				system( "mount /dev/".$query->param('hddact')." /opt/extra");
#				system( "mkdir /opt/extra/kcp");
#				system( "mkdir /opt/extra/kcp/mysql /opt/extra/kcp/storage");
			}

			#open( MYSQLRC, $mysqlrco);
			#print MYSQLRC $hddmysql  ;
			#close( MYSQLRC ) ;

			open( STORAGERC, $storagerco);
			print STORAGERC $hddstorage  ;
			close( STORAGERC ) ;

			#open( MOUNTRC, $mountrco);
			#print MOUNTRC $hddmount ;
			#close( MOUNTRC ) ;

			print "<pre>";
			#system("/opt/mysql/share/mysql/mysql.server stop");
			print "Restart";
			#print $hddmysql;
			#	print $hddstorage;
			#	print $hddmount;

			#system("/opt/mysql/share/mysql/mysql.server start");
			#system("/opt/mysql/bin/mysql_install_db --force");
			print "</pre>";


		}
		if( $query->param('hdddeact') ) {
			print "Device ". $query->param('hdddeact')." unmounted and nolonger on storage.";
			# shutdown mysql
			print "<pre>";
			#system("/opt/mysql/share/mysql/mysql.server stop");

			# unmount device
			# flag all apps as non useable and display message to select storage

			unlink($storagerc);
			#unlink($mysqlrc);
			#unlink($mountrc);
			print "</pre>";

		}

		#print GetAllDevices( "/home/httpd/cgi-bin/settings/dev" ) ;
		#print GetFreeDevices( "/home/httpd/cgi-bin/settings/dev" ) ;
		#print DeclareDeviceAsUsed( "/home/httpd/cgi-bin/settings/dev", "/dev/hda1" ) ;
		#print DeclareDeviceAsFree( "/home/httpd/cgi-bin/settings/dev", "/dev/hdb1" ) ;

		print "<table border=0><TR><td>";

		print "<table border=1>";
		print Tr( th( "Device" ), th( "Capacity<br>(Bytes)" )) ;
		open( PARTS, "/proc/partitions");
  		while( <PARTS>) {
			( $major, $minor, $blocks, $device) = split( " ", $_) ;

			print Tr( td( $device, a( {-href=>"/cgi-bin/kcp_index.cgi?deviceinfo=$device"}, "[Info]" ) ),td( $blocks )) if /sd|hd/;
#		print Tr( td( $_ ) ) ;
		}
		close( PARTS) ;
		print "</table>";

		print "<table border=1>";
		print Tr( th( "Device" ), th( "Mounted" ) ) ;
		open( MOUNTS, "/etc/mtab");
		while( <MOUNTS>) {
			( $device, $mounted) = split( " ", $_) ;
			print Tr( td( $device ), td( $mounted ) ) ;
			# device has of mount points
			$mount_point{$device}=$mounted;
#		print Tr( td( $_ ) ) ;
		}
		close( MOUNTS) ;
		print "</table>";
		print "</TD><td valign=top><table class=panels>";

		if( $query->param('deviceinfo' ) ) {
			print Tr( td( Storage( $query->param("deviceinfo") ) ) ) ;
		}

		print "</table></td></TR></table>";
	}

	# work groups

	if( $this_menu eq 3 ) {

	if( $query->param('setsamba') ) {

		print h1("Please reset the device for this change to take effect");

		open( SAMBARC, ">/home/httpd/cgi-bin/settings/samba.rc");
		print SAMBARC $query->param('sambaworkgroup').' '.$query->param('sambaname');
		close( SAMBARC );


		open( SAMBA, ">/etc/samba/smb.conf");
print SAMBA "[global]\n";
print SAMBA "\n   workgroup = ".$query->param('sambaworkgroup');
print SAMBA "\n   server string = ".$query->param('sambaname');
print SAMBA "\n   security = user";
print SAMBA "\n   load printers = no";
print SAMBA "\n   log file = /dev/null";
print SAMBA "\n   max log size = 50";
print SAMBA "\n   socket options = TCP_NODELAY SO_RCVBUF=8192 SO_SNDBUF=8192";
print SAMBA "\n   local master  = yes";
print SAMBA "\n   domain master = yes";
print SAMBA "\n   preferred master = yes";
print SAMBA "\n   wins support = no";
 print SAMBA "\nunix extensions = Yes";

print SAMBA "\n[external]";
print SAMBA "\ncomment = External File Storage";
print SAMBA "\n       path = /storage";
print SAMBA "\n        browseable = yes";
print SAMBA "\n        writeable = yes";
print SAMBA "\n[internal]";
print SAMBA "\ncomment = Internal File Storage";
print SAMBA "\n       path = /opt/extra";
print SAMBA "\n        browseable = yes";
print SAMBA "\n        writeable = yes";
print SAMBA "\n[incoming]";
print SAMBA "\ncomment = Incoming files";
print SAMBA "\n       path = /opt/extra/incoming";
print SAMBA "\n        browseable = yes";
print SAMBA "\n        writeable = yes";
print SAMBA "\n[homes]";
   print SAMBA "\ncomment = Home Directories";
   print SAMBA "\nvalid users = %S";
   print SAMBA "\nbrowseable = no";
   print SAMBA "\nread only = No";
   print SAMBA "\ncreate mask = 0640";
   print SAMBA "\ndirectory mask = 0750";
   print SAMBA "\nguest ok = no";
   print SAMBA "\nprintable = no";

close( SAMBA );
}

		open( SAMBARC, "/home/httpd/cgi-bin/settings/samba.rc");
		($sambaworkgroup, $sambaname ) = split( " ",<SAMBARC>);
		close( SAMBARC );



	print start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;

	print div( {-class=>"label"}, "Workgroup Name : ",
		textfield( "sambaworkgroup", $sambaworkgroup )
		) ;
	print div( {-class=>"label"}, "Computer Name : ",
		textfield( "sambaname", $sambaname )
		) ;

	print div( submit(  -name=>"setsamba", -value=>"Set" ),
		) ;
	print end_form;


	}

	# application management

	if( $this_menu eq 5 ) {

		if( $query->param('setapps') ) {
			# save selected style
			open( APPS, ">/home/httpd/cgi-bin/settings/kcp_mods.rc");

print APPS 'my @kcp_modules = (';

	print APPS '{';
	print APPS '    module_path		=> "/home/httpd/cgi-bin/kcp_admin.cgi",';
	print APPS '    module_name,        => "admin",';
	print APPS '    module_action	=> "Settings",';
print APPS '	    module_description	=> "Maintain users, devices, services and applications on this box",';
print APPS '	    module_deps		=> "/home/httpd/cgi-bin/kcp_admin.cgi",';
print APPS '	    module_hasmenu	=> 1,';
print APPS '	},';

print APPS '	{';
print APPS '	    module_path		=> "/home/httpd/cgi-bin/kcp_fileserver.cgi",';
print APPS '	    module_action	=> "Documents",';
print APPS '	    module_name,        => "documents",';
print APPS '	    module_description	=> "Document Delivery",';
print APPS '	    module_deps		=> "/home/httpd/cgi-bin/kcp_docs.cgi",';
print APPS '		module_hasmenu	=> 1,';
print APPS '	}';

		if( $query->param('app_docs') ) {

print APPS '	,{';
print APPS '	    module_path		=> "/home/httpd/cgi-bin/kcp_docs.cgi",';
print APPS '	    module_action	=> "Documents",';
print APPS '	    module_name,        => "documents",';
print APPS '	    module_description	=> "Document Delivery",';
print APPS '	    module_deps		=> "/home/httpd/cgi-bin/kcp_docs.cgi",';
print APPS '		module_hasmenu	=> 1,';
print APPS '	}';

		 }

		 if( $query->param('app_crm') ) {
print APPS '	,{';
print APPS '	    module_path		=> "/home/httpd/cgi-bin/kcp_crm.cgi",';
print APPS '	    module_action	=> "Customer Database",';
print APPS '	    module_name,        => "crm",';
print APPS '	    module_description	=> "Customer contacts and actions",';
print APPS '	    module_deps		=> "/home/httpd/cgi-bin/kcp_crm.cgi",';
print APPS '		module_hasmenu	=> 1,';
print APPS '	}';


		 }

	   	if( $query->param('app_wf') ) {
print APPS '	,{';
print APPS '	    module_path		=> "/home/httpd/cgi-bin/kcp_wf.cgi",';
print APPS '	    module_action	=> "Work Flow",';
print APPS '	    module_name,        => "workflow",';
print APPS '	    module_description	=> "Business processes",';
print APPS '	    module_deps		=> "/home/httpd/cgi-bin/kcp_wf.cgi",';
print APPS '		module_hasmenu	=> 1,';
print APPS '	}';



		 }

		 if( $query->param('app_mp3') ) {
print APPS '	,{';
print APPS '	    module_path		=> "/home/httpd/cgi-bin/kcp_mp3.cgi",';
print APPS '	    module_action	=> "Media Juke Box",';
print APPS '	    module_name,        => "jukebox",';
print APPS '	    module_description	=> "Media juke box",';
print APPS '	    module_deps		=> "/home/httpd/cgi-bin/kcp_mp3.cgi",';
print APPS '		module_hasmenu	=> 1,';
print APPS '	}';

		 }


		 print APPS '	);';



			close( APPS );

		}


		# create form to provide application selection

		print start_form( -method=>'POST', -action=>"/cgi-bin/kcp_index.cgi" ) ;

		print h1( "Business" ) ;
		print checkbox(-name=>'app_fileserver',
                          -checked=>$app_filesever,
                          -value=>'ON',
                           -label=>'General Filesever',
			   -class=>"label"
		   );

		print checkbox(-name=>'app_docs',
                          -checked=>$app_docs,
                          -value=>'ON',
                           -label=>'Document Storage',
			   -class=>"label"
		   );

	   	print checkbox(-name=>'app_crm',
                          -checked=>$app_crm,
                          -value=>'ON',
                           -label=>'Customer Database',
			   -class=>"label"
		   );

		print checkbox(-name=>'app_wf',
                          -checked=>$app_wf,
                          -value=>'ON',
                           -label=>'Work Flow',
			   -class=>"label"
		   );


		print h1( "Fun" ) ;
		print checkbox(-name=>'app_mp3',
                           -checked=>$app_mp3,
                           -value=>'ON',
                           -label=>'MP3 Juke Box',
			   -class=>"label"
			   );


		print "<br>";
		print submit( -name=> 'setapps',-value=> 'Set');
		print end_form;
	}

	# style managment

	if( $this_menu eq 6 ) {

		if( $query->param('setstyle') ) {
			# save selected style
			$style_def = putSession( 'site', "sitestyle", $query->param('style') ) ;

			#open( STYLERC, ">/home/httpd/cgi-bin/settings/style.rc");
			#print STYLERC $query->param('style');
			#close( STYLERC );

		}

		# set chosen style sheet

		#open( STYLERC, "/home/httpd/cgi-bin/settings/style.rc");
		#$style_def=<STYLERC>;
		#close( STYLERC );

		$style_def = getSession( 'site', "sitestyle" ) ;

		if( !$style_def) {
			$style_def="std";
		}

		# create form to provide change of style

		print start_form( -method=>'POST', -action=>"/cgi-bin/kcp_index.cgi" ) ;

#		print textfield( -name=>"style1" ) ;

		print span({-class=>'label'}, "Select site style" ) ;
		print popup_menu( -name=>'style',
				-values=>['std','forest','ocean'],
				-default=>$style_def
				);
		print submit(  -name=> 'setstyle',-value=> 'Set');
		print end_form;
	}


	# email

	if( $this_menu eq 7 ) {

	if( $query->param("setemail") ) {
		#open( EMAILRC, ">/home/httpd/cgi-bin/settings/email.rc" ) ;
		#print EMAILRC $query->param("popactive").',';
		#print EMAILRC $query->param("popserver").',';
		#print EMAILRC $query->param("popuser").',';
		#print EMAILRC $query->param("poppassword").',';
		#print EMAILRC $query->param("smtpactive").',';
		#print EMAILRC $query->param("smtpserver").',';
		#print EMAILRC $query->param("smtpfrom").',';
		#print EMAILRC $query->param("smtpuser").',';
		#print EMAILRC $query->param("smtppassword").',';
		#print EMAILRC $query->param("smtpadminemail").',';
		#print EMAILRC $query->param("smtpauser1").',';
		#print EMAILRC $query->param("smtpauser2").',';
		#print EMAILRC $query->param("smtpauser3").',';
		#print EMAILRC $query->param("smtpauser4").',';
		#close( EMAILRC ) ;
		$popactive=putSession('site',"popactive", $query->param("popactive"));
		$popserver=putSession('site',"popserver", $query->param("popserver"));
		$popuser=putSession('site',"popuser", $query->param("popuser"));
		$poppassword=putSession('site',"poppassword", $query->param("poppassword"));
		$smtpactive=putSession('site',"smtpactive", $query->param("smtpactive"));
		$smtpserver=putSession('site',"smtpserver", $query->param("smtpserver"));
		$smtpfrom=putSession('site',"smtpfrom", $query->param("smtpfrom"));
		$smtpuser=putSession('site',"smtpuser",$query->param("smtpuser"));
		$smtppassword=putSession('site',"smtppassword",$query->param("smtppassword"));
		$smtpadminemail=putSession('site',"smtpadminemail", $query->param("smtpadminemail"));
		$smtpauser1=putSession('site',"smtpauser1", $query->param("smtpauser1"));
		$smtpauser2=putSession('site',"smtpauser2", $query->param("smtpauser2"));
		$smtpauser3=putSession('site',"smtpauser3", $query->param("smtpauser3"));
		$smtpauser4=putSession('site',"smtpauser4", $query->param("smtpauser4"));
	}

		$popactive=getSession('site',"popactive");
		$popserver=getSession('site',"popserver");
		$popuser=getSession('site',"popuser");
		$poppassword=getSession('site',"poppassword");
		$smtpactive=getSession('site',"smtpactive");
		$smtpserver=getSession('site',"smtpserver");
		$smtpfrom=getSession('site',"smtpfrom");
		$smtpuser=getSession('site',"smtpuser");
		$smtppassword=getSession('site',"smtppassword");
		$smtpadminemail=getSession('site',"smtpadminemail");
		$smtpauser1=getSession('site',"smtpauser1");
		$smtpauser2=getSession('site',"smtpauser2");
		$smtpauser3=getSession('site',"smtpauser3");
		$smtpauser4=getSession('site',"smtpauser4");

	print start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;
	print h1("General Use POP3 Account");

	print checkbox(-name=>'popactive',
                           -checked=>$popactive,
                           -value=>'ON',
                           -label=>'POP3 Active',
			   -class=>"label", -onClick=>"document.getElementById(\"popdiv\").style.display=(this.checked)?\"\":\"none\";");

	print "<div id=\"popdiv\">";
	print div( {-class=>"label"}, "Server for mail collection : ",
		textfield( "popserver", $popserver )
		) ;
	print div( {-class=>"label"}, "Account name : ",
		textfield( "popuser", $popuser )
		);
	print div( {-class=>"label"}, "Password : ",
		password_field( "poppassword", $poppassword )
		) ;
		print "</div>";
	print h1("General Use SMTP Account");

	print checkbox(-name=>'smtpactive',
			-class=>"label",
                           -checked=>$smtpactive,
                           -value=>'ON',
                           -label=>'SMTP Active', -onClick=>"document.getElementById(\"smtpdiv\").style.display=(this.checked)?\"\":\"none\";");

	print "<div id=\"smtpdiv\">";
	print div( {-class=>"label"}, "Server for sending mail : ",
		textfield( "smtpserver", $smtpserver )
		) ;
	print div( {-class=>"label"}, "Sent from address : ",
		textfield( "smtpfrom", $smtpfrom )
		) ;
	print div( {-class=>"label"}, "SMTP Account name ", i( "(Optional)"), " : ",
		textfield( "smtpuser", $smtpuser )
		) ;
	print div( {-class=>"label"}, i("SMTP Password"), " : " ,
		password_field( "smtppassword", $smtppassword )
		) ;
	print br();
	print h1("Addresses To Send To");
	print div( {-class=>"label"}, "Admin Email Address : ",
		textfield( "smtpadminemail", $smtpadminemail )
		) ;

	print div( {-class=>"label"}, "User 1 Email Address : ",
		textfield( "smtpuser1", $smtpuser1 )
		) ;
	print div( {-class=>"label"}, "User 2 Email Address : ",
		textfield( "smtpuser2", $smtpuser2 )
		) ;
	print div( {-class=>"label"}, "User 3 Email Address : ",
		textfield( "smtpuser3", $smtpuser3 )
		) ;
	print div( {-class=>"label"}, "User 4 Email Address : ",
		textfield( "smtpuser4", $smtpuser4 )
		) ;

	print "</div>";
	print br();
	print div( submit(  -name=>"setemail", -value=>"Set" ),
		submit(  -name=>"testpop", -value=>"Test POP3" ),
		submit(  -name=>"testsmtp", -value=>"Test SMTP" ),
			span( {-class=>"label"}, "Send To" ,
				textfield( "smtptestto" )
			)
		) ;
	print end_form;

	# hide/show divs if active
	print "<script type=\"text/javascript\" language=\"JavaScript1.3\">";
	if( $popactive eq "") {
		print "document.getElementById(\"popactive\").style.display='none';";
	}
	if( $smtpactive eq "") {
		print "document.getElementById(\"smtpactive\").style.display='none';";
	}
	print "</script>";


	if( $query->param('testpop' ) ) {
		use Net::POP3;

		$pop=Net::POP3->new($popserver);
		if( $pop->login( $popuser, $poppassword ) > 0 ) {
			my $msgnums = $pop->list; # hashref of msgnum => size
		      foreach my $msgnum (keys %$msgnums) {
        		my $msg = $pop->get($msgnum);
        		print "<pre>";
			print @$msg;
			print "</pre>";
		      }
		}
	}

	if( $query->param('testsmtp' ) ) {
		use Net::SMTP;

		$smtp = Net::SMTP->new($smtpserver);

		$smtp->mail($smtpfrom);
		$smtp->to($query->param('smtptestto'));

		$smtp->data();
		$smtp->datasend("To: testuser\n");
		$smtp->datasend("\n");
		$smtp->datasend("A simple test message\n");
		$smtp->dataend();

		$smtp->quit;
	}


	}

	if( $this_menu eq 9 ) {
		if( $query->param('timesync') ) {
			open( NTPRC, ">/home/httpd/cgi-bin/settings/ntp.rc");
			print NTPRC $query->param('timeserver');
			close( NTPRC );
			system( "sudo /usr/sbin/ntpclient -c 3 -h `/bin/cat /home/httpd/cgi-bin/settings/ntp.rc` -i 5 -s");
		}

		open( NTPRC, "/home/httpd/cgi-bin/settings/ntp.rc");
		($timeserver ) = <NTPRC>;
		close( NTPRC );

		print start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;

		print a( { -href=>"http://ntp.isc.org/bin/view/Servers/WebHome"}, "Public Servers" );

	print div( {-class=>"label"}, "Time Server : ",
			textfield( "timeserver", $timeserver ),
		 submit(  -name=>"timesync", -value=>"Set" ),
		) ;
	print end_form;

	}

	if( $this_menu eq 20 ) {
	if( $query->param('rebootyn') ) {
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$min %= 10;
		$min = 10-$min;
		if( $query->param( 'rebootyn') eq "Yes" ) {
			system( "/bin/touch /tmp/reboot" ) ;
			print h1("Reboot scheduled in ",$min,"min...");
			putSession('site','kcp_menu','-1');
		} else {
			system( "rm /tmp/reboot" ) ;
			print h1("Any scheduled reboot cancelled...");
		}
		}


		print start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;

	print div( {-class=>"label"}, "Reboot this machine? : ",
		radio_group('rebootyn',['Yes','No'],'No' ),
		 submit(  -name=>"reboot", -value=>"Set" ),
		) ;
	print end_form;

	}

	if( $this_menu eq 21 ) {
	if( $query->param( 'shutyn') ) {
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$min %= 10;
		$min = 10-$min;
		if( $query->param( 'shutyn') eq "Yes" ) {
			system( "/bin/touch /tmp/shutdown" ) ;
			print h1("Shutdown scheduled in ",
				$min,
				"min...");
			putSession('site','kcp_menu','-1');
		}else {
			system( "rm /tmp/shutdown" ) ;
			print h1("Any scheduled shutdown cancelled...");
		}
		}

			print start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;

	print div( {-class=>"label"}, "Shutdown this machine? : ",
		radio_group('shutyn',['Yes','No'], 'No' ),
		submit( -name=>"reboot", -value=>"Set" ),
		) ;
	print end_form;

	}

}

1;

#eof
