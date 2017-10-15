#!/usr/bin/perl
# kcp password/user maint
# (c)2005 ksoft creative projects
#
#
#
# Date		Description
# ------------------------------
#

@kcp_menu = (
	{
		menu_option => 0,
		menu_name => "dum",
	},
	{
		menu_option => 1,
		menu_name => "Change Password",
	},
	{
		menu_option => 2,
		menu_name => "Add/Del User",
	}

) ;


# Main Function

# find out if a new application has been selected

#$query = new CGI ;

# detect called as a menu or main body

sub menu() {

	# Menu options

#	for (my $i=1; $kcp_menu[$i]; $i++) {
#		print div({-class=>"menuitem"}, a( {-href=>"/cgi-bin/kcp_index.cgi?kcp_menu=$kcp_menu[$i]{menu_option}"}, $kcp_menu[$i]{menu_name}));

#menuItem( "/cgi-bin/kcp_index.cgi?kcp_menu=$kcp_menu[$i]{menu_option}", $kcp_menu[$i]{menu_name});

#	}


}

sub main() {

	# main body

	#print "This is the main application body";

	#print "Currently using menu option:";
	#print $this_menu;
#	for (my $i=1; $kcp_menu[$i]; $i++) {
#	if( $kcp_menu[$i]{menu_option} eq $this_menu ) {
#		print p( {-class=>"selected"},$kcp_menu[$i]{menu_name});
#	}
#	}

	if( $this_user eq "admin" ) {
	print p( {-class=>"selected"},"User Account List");
	} else {
	print p( {-class=>"selected"},"Change Password");
	}

	# user main password

#	if( $this_menu eq 2 ) {


my @USERSPW = ();
my @USERSHT = ();


	@USERSPW = system::GetUsersTree();


	if( $query->param('usrupd') ) {



		for ($i=0;$USERSPW[$i]{uid} ne $query->param('usruid');$i++){
		}

		if( $query->param('usrpass1') ne "" )  {
			if( $query->param('usrpass1') eq $query->param('usrpass2') ) {
				$USERSPW[$i]{passwd}=system::EncodePasswd($query->param('usrpass1'));

				system( "/usr/bin/htpasswd -b  /etc/httpd/access/.htpasswd ".$USERSPW[$i]{login}." ".$query->param('usrpass1'));
				
				system( "sudo smbpasswd -La ".$USERSPW[$i]{login}." ".$query->param('usrpass1'));

					print h2("Password changed.");
			}
			else {
				print h2("Passwords dont match.");
			}
		} else {
			print h2( "No password to change." ) ;
		}


		$USERSPW[$i]{name}=$query->param('usrname');
		system::SaveUsersTree(\@USERSPW);

		print h2("Account changed");


print div("need to change samba and htaccess password");



	}


	if( $query->param('usrchg') || $this_user ne "admin") {

		if( $this_user ne "admin") {
			for ($i=0;$USERSPW[$i]{login} ne $this_user;$i++){
			}
		}
		else {
		for ($i=0;$USERSPW[$i]{uid} ne $query->param('usruid');$i++){
			}
		}

		print h1( "Change Account Details");

		print start_form( -action=>'/cgi-bin/kcp_index.cgi', -method=>POST ),
		hidden( -name=>'usruid', -value=>$USERSPW[$i]{uid});

		print div( span( { -class=>'label'}, "Login: " ), $USERSPW[$i]{login} );

		print div( span( { -class=>'label'}, "Name: " ),
		textfield( -name=>'usrname', -size=>50 , -value=>$USERSPW[$i]{name} ) );

		print div( span( { -class=>'label'}, "Password (Leave empty for no password change): " ),
		password_field( -name=>'usrpass1', -size=>20 ) );

		print div( span( { -class=>'label'}, "Re-Type Password: " ),
		password_field( -name=>'usrpass2', -size=>20  ) );

		print  submit( -name=>'usrupd',-value=>'Set');

		print end_form ;

	} else {

	if( $this_user eq "admin" ) {
		print start_form( -action=>'/cgi-bin/kcp_index.cgi', -method=>POST );

		print div( span( { -class=>'label'}, "Login: " ),textfield( -name=>'usrname', -size=>50 ) );

		print div( span( { -class=>'label'}, "Name: " ),
		textfield( -name=>'usrname', -size=>50  ));

		print div( span( { -class=>'label'}, "Password: " ),
		password_field( -name=>'usrpass1', -size=>20 ) );

		print div( span( { -class=>'label'}, "Re-Type Password: " ),
		password_field( -name=>'usrpass2', -size=>20  ) );

		print  submit( -name=>'usradd',-value=>'Add');

		print end_form ;
	}


	print "<table>";
print Tr(
	th( "Login" ),
	th( "Name" ) ,
	th( "Home" ),
	th( "UID"),
	th( "GID" )
) ;

	for ($i=0;$USERSPW[$i];$i++){


	print start_form( -action=>'/cgi-bin/kcp_index.cgi', -method=>POST ),
		hidden( -name=>'usruid', -value=>$USERSPW[$i]{uid});
	print Tr;

	print td( $USERSPW[$i]{login} ),
	td( $USERSPW[$i]{name} ) ,
	td( $USERSPW[$i]{home} ),
	td( $USERSPW[$i]{uid}),
	td( $USERSPW[$i]{gid} );

	    if ( $USERSPW[$i]{hidden}  == 1 ) {
			next;
		}

		if( $USERSPW[$i]{system} == 1 and $USERSPW[$i]{gid} eq 0) {
			print td( submit( -name=>'usrchg',-value=>'Change Password'));
		}

		if($USERSPW[$i]{gid} eq 100 ) {
			print td( submit( -name=>'usrchg',-value=>'Change Password'),
 			submit( -name=>'usrdel',-value=>'Delete'));
		}

	print end_form;
	}

print "</table>";
}


#	}

}

1;

#eof
