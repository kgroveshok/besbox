#!/usr/bin/perl

# besbox core

# TODO
# start menu system nav
# storage device control
# futher menu features
#
#


my $menu = {
	"Storage" => {
		"Select" => sub { print "Select device"  },
		
	},
	"Music" => {
		"Play" => sub { print "Play" },
		"Next" => sub { print "Next" },
	},
	"Video" => {
	}
};

my $menuItem="Storage";
#while( 1 ) {
	
foreach my $i  ( keys $menu ) {
	print $i;
}


#}




