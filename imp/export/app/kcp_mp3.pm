#!/usr/bin/perl
# kcp media station application
# (c)2005 ksoft creative projects
#
#
# Date		Description
# ------------------------------
#
# 15/10/05	Search filter and artist/album/genre filters
# 16/10/05	view tracks on play lists
# 		delete tracks from play lists
# 20/10/05      add all in filter to play list
# 23/10/05      Tidy track list management and tie into audio daemon
#
# todo:
#
# web pub todo:
#    skip files already published but still include in html
#    mark files as transfereed
# in browser show summary of filtered tracks
# "sort by" columns
# add to play list if no list added then add to 'default'
# rename play lists
#
# assign number (for keypad selection) to field def and play list props
#
# listen
#   add play list to play queue
#   add track to play queue
#   monitor keyboard. if number typed then lookup index in play lists
#   icecast/shout cast
#   shuffle, repeat all
#
# export play list to external storage/workgroups/email, item list and/or mp3 files
#
# settings
#   extracted file name format
#   display comments if not then double track listing
#   volume

#use strict;

#print "hello";

##my $LIBS_DIR = "/home/httpd/cgi-bin/libs";
#require "$LIBS_DIR/system.pm";

#use CGI ':standard';

#use Net::MySQL;
#use MP3::Tag;
#use Net::MySQL;
#use File::Temp;

 #my $mysql= Net::MySQL->new(
 #     # hostname => 'mysql.example.jp',   # Default use UNIX socket
 #     database => 'kcp',
 #     user     => 'root',
 #     password => ''
 # );


##!/usr/bin/perl

#setpriority 0, 0, 20;

#use Audio::Daemon::Shout;
#use Audio::Daemon::MPG123;
# or use Audio::Daemon::Xmms;
#my $daemon = new Audio::Daemon::MPG123( Port => 9101
 #                               );

#$daemon->mainloop;


#eof

use Audio::Daemon::Client;


@kcp_menu = (
	{
		menu_option => 0,
		menu_name => "dum",
	},
	{
		menu_option => 1,
		menu_name => "Currently Playing",
	},
	{
		menu_option => 2,
		menu_name => "Tracks/Lists",
	},
	{
		menu_option => 3,
		menu_name => "Add To Collection",
	},

	{
		menu_option => -1,
		menu_name => "",
	},
{		# settings
		menu_option => 100,
		menu_name => "Broadcasting",
	},
{		# settings
		menu_option => 101,
		menu_name => "Controls",
	},
{		# settings
		menu_option => 102,
		menu_name => "Feedback",
	},

) ;

 $TopRow=0;
$PageLength=10;

sub playlistSelect($) {
	my ( $mainButs ) = @_;

	$mp3list = getSession($this_user, 'mp3list');

	if( $query->param('mp3listselect') ) {
		$mp3list = putSession($this_user, 'mp3list',$query->param('mp3playlist'));
		$mp3browsetype=putSession($this_user, 'mp3browsetype',"tracks");
	}

	if( $query->param('mp3listedit') ) {
		$mp3browsetype=putSession($this_user, 'mp3browsetype',"list");
		$qf=putSession($this_user,'mp3wheref',"");
		$qv=putSession($this_user,'mp3wherev',"");
		$mp3searchtext=putSession($this_user,'mp3search',"");
		$TopRow=putSession($this_user,'mp3browse',0);
	}

	$mysql->query( "select PL.playlistid,PL.description, count(PI.mp3data) as ct from mp3_playlist PL left join mp3_playlisti PI on (PL.playlistid=PI.playlistid) group by PL.playlistid, PL.description");
	my $record_set = $mysql->create_record_iterator;

	print '<select name="mp3playlist">';
	while (my $record = $record_set->each ) {
		print '<option ';
		if($record->[0] eq $mp3list ) {
			$mp3listname=$record->[1];
			$mp3listname = putSession($this_user, 'mp3listname',$mp3listname);
			print " selected ";
		}
		print 'value="'.$record->[0].'">'.$record->[1]." - ".$record->[0]." (".$record->[2].")";
	}
	print '</select> ';

	if( $mainButs ) {
		print submit(  -name=>"mp3listselect", -value=>"Select" ), " ",
		 submit(  -name=>"mp3listedit", -value=>"Edit" );
	}

	print submit(  -name=>"mp3queuelist", -value=>"Add To Playback Queue" ),"&nbsp;&nbsp;";




}


sub TrackDrill() {

print span (
	a( { -class=>"applistit", -href=>"/cgi-bin/kcp_index.cgi?mp3drill=artist"}, "By Artist" ),
	a( { -class=>"applistit", -href=>"/cgi-bin/kcp_index.cgi?mp3drill=album"}, "By Album"),
	a( { -class=>"applistit", -href=>"/cgi-bin/kcp_index.cgi?mp3drill=genre"}, "By Genre" )

	) ;
	#a( { -class=>"applistit", -href=>"/cgi-bin/kcp_index.cgi?mp3drill=year"},"By Year")

	print br();
	$mp3d=getSession($this_user,'mp3drill');


	if( $query->param('mp3drill') ) {
		$mp3d=putSession($this_user,'mp3drill',$query->param('mp3drill'));
	}

	if( $mp3d eq "" ) { $mp3d="__";}

		if( $mp3d ne "__" ) {
		print a( { -class=>"applistit", -href=>"/cgi-bin/kcp_index.cgi?mp3drill=__"},"^Rollup^");
	#print h1($mp3d);

	$mysql->query( "select ".$mp3d." from mp3_catalogue group by ".$mp3d);

	my $record_set = $mysql->create_record_iterator;

	while (my $record = $record_set->each ) {
		print span({ -class=>"applistit"},"&nbsp;",a( { -href=>"/cgi-bin/kcp_index.cgi?mp3".$mp3d."=".$record->[0]},$record->[0]),"&nbsp; ");
	}
	}
}

sub TrackBrowser($) {
	my ( $browseType ) = @_;
	my $l=0;

	$TopRow=getSession($this_user,'mp3browse');
	$mp3searchtext=getSession($this_user,'mp3search');

	if( $query->param('mp3clear' ) ) {
		$qf=putSession($this_user,'mp3wheref',"");
		$qv=putSession($this_user,'mp3wherev',"");
		$mp3searchtext=putSession($this_user,'mp3search',"");
		print "Clear...";
	}

	if( $TopRow eq "") {
		$TopRow=putSession($this_user,'mp3browse',0);
	}

	if( $query->param('mp3search') ) {
		$mp3searchtext=putSession($this_user,'mp3search',$query->param('mp3searcht'));
		$mp3browsetype=putSession($this_user, 'mp3browsetype',"tracks");
	}

	if( $query->param('mp3artist' ) ) {
		$TopRow=putSession($this_user,'mp3browse',0);
		$qv=putSession($this_user,'mp3wherev',$query->param('mp3artist' )) ;
		$qf=putSession($this_user,'mp3wheref',"artist") ;
		$mp3browsetype=putSession($this_user, 'mp3browsetype',"tracks");
	}
	if( $query->param('mp3album' ) ) { $TopRow=putSession($this_user,'mp3browse',0);
		$qf=putSession($this_user,'mp3wheref',"album" );
		$qv=putSession($this_user,'mp3wherev',$query->param('mp3album' ));
		$mp3browsetype=putSession($this_user, 'mp3browsetype',"tracks");
	}
	if( $query->param('mp3genre' ) ) { $TopRow=putSession($this_user,'mp3browse',0);
		$qf=putSession($this_user,'mp3wheref',"genre" );
		$qv=putSession($this_user,'mp3wherev',$query->param('mp3genre' ));
		$mp3browsetype=putSession($this_user, 'mp3browsetype',"tracks");
	 }

	 $q="";

	if( getSession($this_user,'mp3wheref') ) {
		$q=" where ".getSession($this_user,'mp3wheref')." = \'".getSession($this_user,'mp3wherev')."\'";
	}

	if( $mp3searchtext ) {
		if( $q ) {
			$q = $q . " and	( upper(concat(song,artist,album,comment,genre)) like \'%".uc($mp3searchtext)."%\')";
		}
		else {
			$q = " where ( upper(concat(song,artist,album,comment,genre)) like \'%".uc($mp3searchtext)."%\')";
		}
		#+artist+album+comment+genre
	}

	if( $query->param('mp3addallpl') ) {


			$q= "INSERT INTO mp3_playlisti (playlistid, mp3data ) select ".$mp3list.", mp3data from mp3_catalogue ".$q;

			$mysql->query($q);

		#putSession( $this_user, 'listtag',$query->param('listtag' ));
	}

	# if using a where clause then do a quick summary of artist and album that falls in this filter


	print h2($qf,$qv);

	if( $browseType eq "tracks" ) {
		$mysql->query( "select * from mp3_catalogue ".$q);
	} else {
		$mysql->query( "select * from mp3_catalogue CT join mp3_playlisti PL on (CT.mp3data=PL.mp3data and PL.playlistid=".$mp3list.") ".$q);
	}

	my $record_set = $mysql->create_record_iterator;


	#if( $browseType ne "tracks" ) {
#		while (my $record = $record_set->each ) {
#			print $record->[1]," ";

#		}
#	}



	# main file list

	print start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;
	print "<table>";

	# Nav bar

	print '<tr class="mp3browsernav"><TD colspan="6">';


	print textfield( "mp3searcht", $mp3searchtext ), " ",
		submit( -name=>"mp3search", -value=>"Search" ),
		submit( -name=>"mp3clear", -value=>"Clear" ),
		"&nbsp;&nbsp;&nbsp;&nbsp;";

	if( $browseType eq "tracks" ) {
		print submit( -name=>"mp3addpl", -value=>"Add To Play List" ),
		submit( -name=>"mp3addallpl", -value=>"Add All To Play List" ),
		submit(  -name=>"mp3queuetrack", -value=>"Add To Playback Queue" );


	} else  {
		print submit( -name=>"mp3delpl", -value=>"Remove From Play List" );
		print submit( -name=>"mp3delallpl", -value=>"Remove All From Play List" );
	}

	print "&nbsp;&nbsp;&nbsp;&nbsp;",
		submit( -name=>"mp3pgup", -value=>"Up" ),
		submit(  -name=>"mp3pgdn", -value=>"Down" );

#		"Showing ",$TopRow," to ",$TopRow+$PageLength,
#		" of ", $mysql->get_affected_rows_length,
#		"tracks";


	print Tr( {-class=>"mp3browserth"},
		th( ""),
		th( "Title" ),
		th( "Artist" ),
		th( "Album" ),

		th( "Year" ),
		th( "Genre" ),
		th("Track"),
		th( "Play Time")
	) ;





	$l=$TopRow;
	while( --$l >=0 ) { my $recorddump = $record_set->each ; }
	$l=0;
	while (my $record = $record_set->each ) {
		if( ++$l > $PageLength ) {
			last ;
		}
		print Tr({-class=>"mp3browsertd"},
		td(checkbox(-name=>"listtag",
                           -checked=>1,
                           -value=>$record->[0],
			   -label=>"",
                             -class=>"label" ), $l),
			td($record->[1]),   # `song`
			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3artist=".cleanString($record->[2]) }, $record->[2] ) ),   # artist
			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3album=".cleanString($record->[3]) }, $record->[3] ) ),	# `album`

			td($record->[5]),	# `year`
			td(a( { -href=>"/cgi-bin/kcp_index.cgi?mp3genre=".cleanString($record->[6]) }, $record->[6] )),	# `genre`
			td($record->[7]),	# `track`
			td(  $record->[8] )	# `playtime`

		),
		Tr(
			td( { -colspan=>3 }),
			td( { -colspan=> 5},i( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3comment=".cleanString($record->[4]) }, $record->[4] )),	# `comment`;
				)
				)
	}
	print "</table>";


	#td(a( { -href=>"/cgi-bin/kcp_index.cgi?mp3user=".cleanString($record->[9]) }, $record->[9] ))	# `user`
	#$mysql->close;
	print end_form;
}

#
# view playing track list mp3 stream
#

sub playingMP3() {

	my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9100);

#if( $query->param('mp3qlistdel') ) {
		#	$mysql->query( "delete from mp3_queue where playlistid=".$query->param('mp3qlistdel'));
		#}



		if( $query->param('mp3qtrackdel') ) {
			#			$mysql->query( "delete from mp3_queue where qid=".$query->param('mp3qtrackdel'));
			$player->del($query->param('mp3qtrackdel'));
		}


		if( $query->param('mp3qartistdel') or $query->param('mp3qalbumdel') ) {
	$player->list;
	#$player->info;
	$status = $player->status;

	$status = $player->{status};
	if (ref $status->{list}) {

	$id2del="";

	foreach my $i (0..$#{$status->{list}}) {
		$mysql->query( "select * from mp3_catalogue where mp3data='".$status->{list}[$i]."'");
		$record_set = $mysql->create_record_iterator;
		$record = $record_set->each ;

		if( $query->param('mp3qartistdel') ) {
			if($query->param('mp3qartistdel') eq $record->[2] ) {
				push( @id2del, $i ) ;
			}
		}
		if( $query->param('mp3qalbumdel') ) {
		if($query->param('mp3qalbumdel') eq $record->[3] ) {
				push( @id2del, $i ) ;
			}
		}

	}

	$player->del(@id2del);

	}

}


		#if( $query->param('mp3qtrackdel2') ) {
		#	@a=$query->param('qtag' ) ;

		#	while( @a ) {

		#		$q= "DELETE FROM mp3_queue WHERE qid=".pop(@a);

		#		$mysql->query($q);


		#	}

		#}

		# jump to track

		if( $query->param("mp3qplay") ) {


			$player->info;
			$status = $player->status;

			$ranwas = $status->{'random'};

			$player->random(0);

			$player->stop;

			if(  $status->{id} > $query->param("mp3qplay") ) {
				for( $i =$status->{id} ; $i != $query->param("mp3qplay") ; $i-- ) {
					$player->prev;
				}
			} else {
				for( $i =$status->{id} ; $i != $query->param("mp3qplay") ; $i++ ) {
					$player->next;
				}
			}

			$player->play;

			if( $ranwas ) {
				$player->random(1);
			}

		}

		if( $query->param("mp3qstop" ) ) {
			$player->stop;
		}

		if( $query->param("mp3qstart" ) ) {
			$player->play;
		}
		if( $query->param("mp3qpause" ) ) {
			$player->pause;
		}
		if( $query->param("mp3qnext" ) ) {
			$player->next;
		}
		if( $query->param("mp3qprev" ) ) {
			$player->prev;
		}
		if( $query->param("mp3qrandomon" ) ) {
			$player->random(1);
		}
		if( $query->param("mp3qrandomoff" ) ) {
			$player->random(0);
		}

		if( $query->param("mp3qrepeaton" ) ) {
			$player->repeat(1);
		}

		if( $query->param("mp3qrepeatoff" ) ) {
			$player->repeat(0);
		}

		#if( $query->param("mp3qload" ) ) {
		#	$player->del("all");
		#	$mysql->query( "select mp3data from mp3_queue");

		#	my $record_set = $mysql->create_record_iterator;
		#	while (my $record = $record_set->each ) {
		#		#print "<br>".$record->[0];
		#		$player->add($record->[0]);
		#	}

		#}

		if( $query->param("mp3qclearall" ) ) {
			$player->del("all");
		}


		$player->list;
		$player->info;
		$status = $player->status;

		print  start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;

		print submit(  -name=>"mp3qprev", -value=>"&#060;&#124;" );
		if( $status->{'state'} ne "2" ) {
			print submit(  -name=>"mp3qstart", -value=>"&#062;" );
		}
		if( $status->{'state'} eq "2" ) {
			print submit(  -name=>"mp3qpause", -value=>"&#124;&#124;" );
		}
		if( $status->{'state'} ne "0" ) {
			print submit(  -name=>"mp3qstop", -value=>"&#8226;" );
		}
		print submit(  -name=>"mp3qnext", -value=>"&#124;&#062;" );

		print "&nbsp;&nbsp;";

		if( $status->{'random'} eq "1" ) {
			print submit(  -name=>"mp3qrandomoff", -value=>"Random Off" );
		} else {
			print submit(  -name=>"mp3qrandomon", -value=>"Random On" );
		}
		print "&nbsp;&nbsp;";
		if( $status->{'repeat'} eq "1" ) {
			print submit(  -name=>"mp3qrepeatoff", -value=>"Repeat Off" );
		} else {
			print submit(  -name=>"mp3qrepeaton", -value=>"Repeat On" );
		}
		print "&nbsp;&nbsp;";
		print submit(  -name=>"mp3qclearall", -value=>"Clear List" );
		#print submit(  -name=>"mp3qload", -value=>"Load List" );
		print "&nbsp;&nbsp;";


		#print "controls: stop, start, next, prev, random on/off, pause, announce track on/off<br>";

		playlistSelect(0) ;
	#	print submit(  -name=>"mp3qtrackdel2", -value=>"Delete From Queue" );

		print '<pre class="panels">';

  if (0) {
    foreach my $k (keys %{$status}) {
      print "$k => ".$status->{$k}."\n";
    }
  }

  # print "Sending ".($status->{frame})."\n";

  my $tdisplay = format_time($status->{frame});
  my @state = ('Stopped', 'Paused', 'Playing');
  print "   ".$state[$status->{state}]." $tdisplay\n";
  print "   \"".$status->{title}.", ".$status->{album}.'" by '.$status->{artist}."\n";

		#open( PLAYING, "/tmp/mp3track");
		#while( <PLAYING>) {
		#	print  ;
		#}
		#close( PLAYING) ;

		#$player->list;


		print "</pre>";



	$player->list;
	#$player->info;
	$status = $player->status;


	$status = $player->{status};
	if (ref $status->{list}) {

	print "<table>";
	print Tr(th(""),
			th("Sequence<br>(Delete)"),
			th("Song"),
			th("Artist<br>(Delete All By...)"),
			th("Album<br>(Delete All On...)") ) ;

	foreach my $i (0..$#{$status->{list}}) {
		$mysql->query( "select * from mp3_catalogue where mp3data='".$status->{list}[$i]."'");
		$record_set = $mysql->create_record_iterator;
		$record = $record_set->each ;

		print Tr;

		if( $status->{id} eq $i ) {
			print td( img( { -src=>"/images/017b.gif"}) );
		}
		else {
			#print td("");
#			print td(a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qplay=".$record->[0] }, img( { -src=>"/images/043.gif", -border=>0 })));
			print td(a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qplay=".$i }, img( { -src=>"/images/017.gif", -border=>0 })));
		}
		print td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qtrackdel=".$i }, $i+1)),
			td( $record->[1] ),
			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qartistdel=".$record->[2]}, $record->[2]) ),
			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qalbumdel=".$record->[3]}, $record->[3] ))
			;
	}


	print "</table>";
	}

#		$mysql->query( "select * from mp3_queue Q left join mp3_catalogue C on (Q.mp3data=C.mp3data) order by qid");

	#my $record_set = $mysql->create_record_iterator;

	#print "<table>";
	#print Tr(th(""),
	#		th( "Channel"),
#			th("Sequence"),
#			th("Play List"),
#			th("Play List Item"),
#
#			th("Song"),
#			th("Artist"),
#			th("Album") ) ;

#	while (my $record = $record_set->each ) {
#		print Tr(td(checkbox(-name=>"qtag",
#                           -checked=>1,
#                           -value=>$record->[1],
#			   -label=>"",
#                             -class=>"label" ), $l),
#			td( $record->[0]),
#			td($record->[1]),
#			td(a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qlistdel=".$record->[3]}, $record->[3])),
#			td($record->[4]),
##
#			td($record->[6]),
#			td($record->[7]),
#			td($record->[8]),
#			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qtrackdel=".$record->[1]},"[Del From Queue]"))
#
#		);
#	}


#	print "</table>";
print end_form;

}



#
# view playing track list icecast stream
#

sub playingIce() {



		if( $query->param('mp3qtrackdel') ) {
			$mysql->query( "delete from mp3_queue where qid=".$query->param('mp3qtrackdel')." and cid='".$mp3channel."'");
		}


		if( $query->param('mp3qartistdel') or $query->param('mp3qalbumdel') ) {
#	$player->list;
	#$player->info;
#	$status = $player->status;

#	$status = $player->{status};
#	if (ref $status->{list}) {

#	$id2del="";

#	foreach my $i (0..$#{$status->{list}}) {
#		$mysql->query( "select * from mp3_catalogue where mp3data='".$status->{list}[$i]."'");
#		$record_set = $mysql->create_record_iterator;
#		$record = $record_set->each ;

#		if( $query->param('mp3qartistdel') ) {
#			if($query->param('mp3qartistdel') eq $record->[2] ) {
#				push( @id2del, $i ) ;
#			}
#		}
#		if( $query->param('mp3qalbumdel') ) {
#		if($query->param('mp3qalbumdel') eq $record->[3] ) {
#				push( @id2del, $i ) ;
#			}
#		}

#	}

#	$player->del(@id2del);

#	}

}


		#if( $query->param('mp3qtrackdel2') ) {
		#	@a=$query->param('qtag' ) ;

		#	while( @a ) {

		#		$q= "DELETE FROM mp3_queue WHERE qid=".pop(@a);

		#		$mysql->query($q);


		#	}

		#}


#		if( $query->param("mp3qstop" ) ) {
#			$player->stop;
#		}

#		if( $query->param("mp3qstart" ) ) {
#			#$player->play;
#		}
#		if( $query->param("mp3qrandomon" ) ) {
#			$player->random(1);
#		}
#		if( $query->param("mp3qrandomoff" ) ) {
#			$player->random(0);
#		}

		if( $query->param("mp3qclearall" ) ) {
			$mysql->query( "delete from mp3_queue where cid=".$mp3channel);

#			$player->del("all");
		}



		print  start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;

			print a( { -href=>"http://".thisHost().":8000/admin/"}, "[Icecast Admin]") ;
			print a( { -href=>"http://".thisHost().":8000/".$mp3channelname.".m3u"}, "[Listen In]") ;
#			print submit(  -name=>"mp3qstart", -value=>"&#062;" );
#			print submit(  -name=>"mp3qstop", -value=>"&#8226;" );

#		print "&nbsp;&nbsp;";

#			print submit(  -name=>"mp3qrandomoff", -value=>"Random Off" );
#			print submit(  -name=>"mp3qrandomon", -value=>"Random On" );

		print submit(  -name=>"mp3qclearall", -value=>"Clear List" );
		#print submit(  -name=>"mp3qload", -value=>"Load List" );
		print "&nbsp;&nbsp;";


		#print "controls: stop, start, next, prev, random on/off, pause, announce track on/off<br>";

		playlistSelect(0) ;
	#	print submit(  -name=>"mp3qtrackdel2", -value=>"Delete From Queue" );

	print "<table>";
	print Tr(
			th("Sequence<br>(Delete)"),
			th("Song"),
			th("Artist<br>(Delete All By...)"),
			th("Album<br>(Delete All On...)") ) ;

	$mysql->query( "select * from mp3_queue Q left join mp3_catalogue C on (Q.mp3data=C.mp3data) where cid='".$mp3channel."' order by qid");

	my $record_set = $mysql->create_record_iterator;

	$ct=1;


	while (my $record = $record_set->each ) {
		print Tr(td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qqtrackdel=".$record->[1] }, $ct++)),
			td( $record->[6]),
			#td(a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qlistdel=".$record->[3]}, $record->[3])),
			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qqartistdel=".$record->[9]}, $record->[9]) ),
			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qqalbumdel=".$record->[10]}, $record->[10] )));
   	}


	print "</table>";


#		$mysql->query( "select * from mp3_queue Q left join mp3_catalogue C on (Q.mp3data=C.mp3data) order by qid");

	#my $record_set = $mysql->create_record_iterator;

	#print "<table>";
	#print Tr(th(""),
	#		th( "Channel"),
#			th("Sequence"),
#			th("Play List"),
#			th("Play List Item"),
#
#			th("Song"),
#			th("Artist"),
#			th("Album") ) ;

#	while (my $record = $record_set->each ) {
#		print Tr(td(checkbox(-name=>"qtag",
#                           -checked=>1,
#                           -value=>$record->[1],
#			   -label=>"",
#                             -class=>"label" ), $l),
#			td( $record->[0]),
#			td($record->[1]),
#			td(a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qlistdel=".$record->[3]}, $record->[3])),
#			td($record->[4]),
##
#			td($record->[6]),
#			td($record->[7]),
#			td($record->[8]),
#			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qtrackdel=".$record->[1]},"[Del From Queue]"))
#
#		);
#	}


#	print "</table>";
print end_form;

}

#
# view playing track list web publisher
#

sub playingWeb() {


		# publish play back queue

		if( $query->param('mp3qwebpub') ) {

			print p( "Publishing playback queue..." ) ;

			$mysql->query( "select * from mp3_channel where cid=".$mp3channel);

			my $record_set = $mysql->create_record_iterator;

			my $ch_record = $record_set->each;

			use Net::FTP;
			use File::Basename;

			print p( "Connecting with web server..." ) ;

			$ftp = Net::FTP->new($ch_record->[5], Debug => 0)
			     or die "Cannot connect to some.host.name: $@";

			print p( "Logging in..." ) ;
			$ftp->login($ch_record->[6],$ch_record->[7])
      				or die "Cannot login ", $ftp->message;

			print p( "Locating target directory..." ) ;
			    $ftp->cwd( $ch_record->[8])
			      or die "Cannot change working directory ", $ftp->message;

			print p( "Publishing new files..." ) ;

			$ftp->binary;

			$mysql->query( "select * from mp3_queue Q left join mp3_catalogue C on (Q.mp3data=C.mp3data) where  cid='".$mp3channel."' order by qid");

			my $record_set = $mysql->create_record_iterator;

			$ct=1;

			$fname = mktemp("/tmp/index.htmlXXXXX");
			open( INDEX, ">".$fname ) ;
			print INDEX <<INDEXEOF;
<html>
<body>

<table><TR><Th>Track</Th><th>Artist</th><th>Album</th><th>When<br>Published</th></TR>
INDEXEOF


			while (my $record = $record_set->each ) {

				if( $record->[5] eq "") {
					$ftp->put( $record->[2],basename($record->[2]).".mp3");
					print p($record->[2]);
				}

				print INDEX Tr(
			td( {-class=>"bestrack"}, a( { -class=>"beslink", -href=>basename($record->[2]).".mp3" }, $record->[8])),

			td( {-class=>"besartist"}, $record->[9]) ,
			td( {-class=>"besalbum"}, $record->[11]));

			}

						print INDEX <<INDEXEOF2;
</table>
</body>
</html>

INDEXEOF2

			close( INDEX ) ;

			if( $ch_record->[9] eq "Yes" ) {
				print p( "Publishing index.html..." ) ;

				$ftp->ascii;
				$ftp->put( $fname, "index.html") ;
			}

			print p( "Finishing off.." ) ;
			print p( "Done." ) ;

			$ftp->quit;
		}




		if( $query->param('mp3qtrackdel') ) {
			$mysql->query( "delete from mp3_queue where qid=".$query->param('mp3qtrackdel')." and cid='".$mp3channel."'");
		}


		if( $query->param('mp3qartistdel') or $query->param('mp3qalbumdel') ) {
#	$player->list;
	#$player->info;
#	$status = $player->status;

#	$status = $player->{status};
#	if (ref $status->{list}) {

#	$id2del="";

#	foreach my $i (0..$#{$status->{list}}) {
#		$mysql->query( "select * from mp3_catalogue where mp3data='".$status->{list}[$i]."'");
#		$record_set = $mysql->create_record_iterator;
#		$record = $record_set->each ;

#		if( $query->param('mp3qartistdel') ) {
#			if($query->param('mp3qartistdel') eq $record->[2] ) {
#				push( @id2del, $i ) ;
#			}
#		}
#		if( $query->param('mp3qalbumdel') ) {
#		if($query->param('mp3qalbumdel') eq $record->[3] ) {
#				push( @id2del, $i ) ;
#			}
#		}

#	}

#	$player->del(@id2del);

#	}

}


		#if( $query->param('mp3qtrackdel2') ) {
		#	@a=$query->param('qtag' ) ;

		#	while( @a ) {

		#		$q= "DELETE FROM mp3_queue WHERE qid=".pop(@a);

		#		$mysql->query($q);


		#	}

		#}


#		if( $query->param("mp3qstop" ) ) {
#			$player->stop;
#		}

#		if( $query->param("mp3qstart" ) ) {
#			#$player->play;
#		}
#		if( $query->param("mp3qrandomon" ) ) {
#			$player->random(1);
#		}
#		if( $query->param("mp3qrandomoff" ) ) {
#			$player->random(0);
#		}

		if( $query->param("mp3qclearall" ) ) {
			$mysql->query( "delete from mp3_queue where cid=".$mp3channel);

#			$player->del("all");
		}



		print  start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;


			print submit(  -name=>"mp3qwebpub", -value=>"Publish" );
#			print submit(  -name=>"mp3qstop", -value=>"&#8226;" );

#		print "&nbsp;&nbsp;";

#			print submit(  -name=>"mp3qrandomoff", -value=>"Random Off" );
#			print submit(  -name=>"mp3qrandomon", -value=>"Random On" );

		print submit(  -name=>"mp3qclearall", -value=>"Clear List" );
		#print submit(  -name=>"mp3qload", -value=>"Load List" );
		print "&nbsp;&nbsp;";


		#print "controls: stop, start, next, prev, random on/off, pause, announce track on/off<br>";

		playlistSelect(0) ;
	#	print submit(  -name=>"mp3qtrackdel2", -value=>"Delete From Queue" );

	print "<table>";
	print Tr(
			th("Sequence<br>(Delete)"),
			th("Song"),
			th("Artist<br>(Delete All By...)"),
			th("Album<br>(Delete All On...)"),
			th( "Published<br>On") ) ;

	$mysql->query( "select * from mp3_queue Q left join mp3_catalogue C on (Q.mp3data=C.mp3data) where cid='".$mp3channel."' order by qid");

	my $record_set = $mysql->create_record_iterator;

	$ct=1;


	while (my $record = $record_set->each ) {
		print Tr(td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qqtrackdel=".$record->[1] }, $ct++)),
			td( $record->[6]),
			#td(a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qlistdel=".$record->[3]}, $record->[3])),
			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qqartistdel=".$record->[9]}, $record->[9]) ),
			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qqalbumdel=".$record->[10]}, $record->[10] )));
   	}


	print "</table>";


#		$mysql->query( "select * from mp3_queue Q left join mp3_catalogue C on (Q.mp3data=C.mp3data) order by qid");

	#my $record_set = $mysql->create_record_iterator;

	#print "<table>";
	#print Tr(th(""),
	#		th( "Channel"),
#			th("Sequence"),
#			th("Play List"),
#			th("Play List Item"),
#
#			th("Song"),
#			th("Artist"),
#			th("Album") ) ;

#	while (my $record = $record_set->each ) {
#		print Tr(td(checkbox(-name=>"qtag",
#                           -checked=>1,
#                           -value=>$record->[1],
#			   -label=>"",
#                             -class=>"label" ), $l),
#			td( $record->[0]),
#			td($record->[1]),
#			td(a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qlistdel=".$record->[3]}, $record->[3])),
#			td($record->[4]),
##
#			td($record->[6]),
#			td($record->[7]),
#			td($record->[8]),
#			td( a( { -href=>"/cgi-bin/kcp_index.cgi?mp3qtrackdel=".$record->[1]},"[Del From Queue]"))
#
#		);
#	}


#	print "</table>";
print end_form;

}




# Main Function

# find out if a new application has been selected

#$query = new CGI ;

# detect called as a menu or main body

sub menu () {

	$mp3channel = getSession($this_user, 'mp3channel');
	#$mp3channeltype = getSession($this_user, 'mp3channeltype');
	#$mp3channelsource = getSession($this_user, 'mp3channelsource');

	if( $query->param('mp3channelselect') ) {
		$mp3channel = putSession($this_user, 'mp3channel',$query->param('mp3channel'));
	}

	print  start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST, -class=>'panels' ) ;

	$mysql->query( "select cid, channel, transmission_type,source_type from mp3_channel where active>0");

	my $record_set = $mysql->create_record_iterator;

	print '<select name="mp3channel">';
	while (my $record = $record_set->each ) {
		print '<option ';
		if($record->[0] eq $mp3channel ) {
			$mp3channel = putSession($this_user, 'mp3channel',$record->[0]);
			$mp3channelname = putSession($this_user, 'mp3channelname',$record->[1]);
			$mp3channeltype = putSession($this_user, 'mp3channeltype',$record->[2]);
			$mp3channelsource = putSession($this_user, 'mp3channelsource',$record->[3]);
			print " selected ";
		}
		print 'value="'.$record->[0].'">'.$record->[1];
	}
	print '</select> ';

	print submit(  -name=>"mp3channelselect", -value=>"Select Channel" );

	print end_form;

	# Menu options

	for (my $i=1; $kcp_menu[$i]; $i++) {
#		print div({-class=>"menuitem"}, a( {-href=>"/cgi-bin/kcp_index.cgi?kcp_menu=$kcp_menu[$i]{menu_option}"}, $kcp_menu[$i]{menu_name}));

menuItem( "/cgi-bin/kcp_index.cgi?kcp_menu=$kcp_menu[$i]{menu_option}", $kcp_menu[$i]{menu_name});

	}

}
sub main () {

	# main body

	#BUG this needs to go elsewhere for channel selection to work!

	my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9100);

	# save uploaded file

	if( $query->param('uploaded_file') ) {
		# Copy a binary file to somewhere safe
		$filename = $query->param('uploaded_file');
		open (OUTFILE,">/tmp/new.mp3");
		while ($bytesread=read($filename,$buffer,1024)) {
			print OUTFILE $buffer;
		}

		system( "/home/httpd/cgi-bin/kcp_utils/mp3save.pm /tmp/*.mp3");

     	}

	# load media from /opt/extra/incoming

	if( $query->param( 'updir' ) ) {
		system( "/home/httpd/cgi-bin/kcp_utils/mp3save.pm /opt/extra/incoming/*.mp3");
	}

	# load media from my home incoming

	if( $query->param( 'updir' ) ) {
		system( "/home/httpd/cgi-bin/kcp_utils/mp3save.pm /home/".$query->remote_user()."/incoming/*.mp3");
	}

	# load media attached to /storage

	if( $query->param( 'updevice' ) ) {
		system( "/home/httpd/cgi-bin/kcp_utils/mp3save.pm /storage/*.mp3");
	}


	#print "This is the main application body";

	#print "Currently using menu option:";
	#print $this_menu;
	for (my $i=1; $kcp_menu[$i]; $i++) {
	if( $kcp_menu[$i]{menu_option} eq $this_menu ) {
		print p( {-class=>"selected"},$kcp_menu[$i]{menu_name});
	}
	}

	#### manage track browser

	$mp3list = getSession($this_user, 'mp3list');

	# tag for playlist
	if( $query->param('mp3addpl') ) {


		@a=$query->param('listtag' ) ;
		while( @a ) {

			$b=pop(@a);

			$q= "INSERT INTO mp3_playlisti (playlistid, mp3data ) VALUES (".$mp3list.",\'".$b."\'); ";

			$mysql->query($q);

		}

		#putSession( $this_user, 'listtag',$query->param('listtag' ));
	}




	# del from play list

	if( $query->param('mp3delpl') ) {

		@a=$query->param('listtag' ) ;
		while( @a ) {

			$q= "DELETE FROM mp3_playlisti WHERE playlistid=".$mp3list." and mp3data=\'".pop(@a)."\'; ";

			$mysql->query($q);

		}

		#putSession( $this_user, 'listtag',$query->param('listtag' ));
	}


	# add playlist to playback queue

	if( $query->param('mp3queuelist') ) {
	#($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	 #my @abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
	#$now=$mday."-".$abbr[$mon]."-".$hour.":".$min;

	if( $mp3channeltype eq 1 ) {

		$q= "select mp3data from mp3_playlisti WHERE playlistid=".$query->param('mp3playlist');

		putSession('monitor','playlist',$query->param('mp3playlist') );

		$mysql->query($q);

		my $record_set = $mysql->create_record_iterator;
		while (my $record = $record_set->each ) {
			#	print "<br>".$record->[0];


				$player->add($record->[0]);
		}
	} else {

		$q= "insert into mp3_queue ( cid, mp3data) select ".$mp3channel.", mp3data from mp3_playlisti WHERE playlistid=".$query->param('mp3playlist');

		$mysql->query($q);

	}

	}

		# add playlist to playback queue

	if( $query->param('mp3queuetrack') ) {
		@a=$query->param('listtag' ) ;
		while( @a ) {
			if( $mp3channeltype eq 1 ) {
			$player->add(pop(@a));
			} else {
			$q= "INSERT INTO mp3_queue (cid, mp3data )
			select ".$mp3channel.",mp3data from mp3_catalogue WHERE mp3data='".pop(@a)."';";

			$mysql->query($q);
			}
		}
	}

	# page up

	$TopRow=getSession($this_user,'mp3browse');

	if( $query->param('mp3pgup' ) ) {
		$TopRow-=$PageLength ;

	}

	# page down

	if( $query->param('mp3pgdn' ) ) {
		$TopRow+=$PageLength ;
	}

	$TopRow=putSession($this_user,'mp3browse',$TopRow);

	# playback queue mangement

	if( $this_menu eq 1 ) {

		SWITCH: {
			$mp3channeltype eq 1 	&& do {
							playingMP3();
							last SWITCH;
						};

			$mp3channeltype eq 2 	&& do {
							#%host=LoadNetworkSettings();




							playingIce();
							last SWITCH;
						} ;
			$mp3channeltype eq 7 	&& do {
							#%host=LoadNetworkSettings();




							playingWeb();
							last SWITCH;
						} ;
			print h2("Not available for this transmission type");
		}


	}

	# play list management

	if( $this_menu eq 2 ) {

		if( $query->param('mp3newlist') ) {
			$q= "INSERT INTO mp3_playlist (user, description ) VALUES (\'".$query->remote_user()."\', \'".cleanString($query->param('mp3newlistname'))."\'); ";

			$mysql->query($q);

			$mp3list = putSession($this_user, 'mp3list',$query->param('mp3newlistname'));
		}

		if( $query->param('mp3chglist') ) {
			$q= "update mp3_playlist set description='".cleanString($query->param('mp3chglistname'))."' where playlistid=".$mp3list;

			$mysql->query($q);

			$mp3list = putSession($this_user, 'mp3list',$query->param('mp3chglistname'));
		}

		if( $query->param('mp3clearpl') ) {
			$q= "delete from mp3_playlisti where playlistid=".$mp3list;

			$mysql->query($q);


		}

  		print  start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;
		playlistSelect(1) ;
		my $mp3browsetype=getSession($this_user, 'mp3browsetype');
		if( $mp3browsetype eq "tracks" ) {
			print textfield( "mp3newlistname" );
			print submit(  -name=>"mp3newlist", -value=>"New Play List" );
		} else {
			print submit(  -name=>"mp3chgdeldup", -value=>"Remove Duplicates" );
			print submit(  -name=>"mp3clearpl", -value=>"Clear List" );
			print "&nbsp;&nbsp;&nbsp;";
			$mp3listname = getSession($this_user, 'mp3listname');
			print textfield( "mp3chglistname", $mp3listname );
			print submit(  -name=>"mp3chglist", -value=>"Rename" );
			print submit(  -name=>"mp3chgcopyto", -value=>"Copy To" );
		}

		if( $mp3browsetype eq "tracks" ) {
			TrackDrill();
		}
		print end_form;
		TrackBrowser($mp3browsetype);

	}

	# add files to the mp3 collection

	if( $this_menu eq 3 ) {



		print  start_multipart_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;
		print div( span({-class=>'label'}, "Upload a single file : " ),
				filefield(-name=>'uploaded_file',
                            -default=>'starting value',
                            -size=>50,
                            -maxlength=>80),
			   submit(  -name=>"upsong", -value=>"Upload" )
			  ) ;

 		print div( span({-class=>'label'}, "Add all media files in the general Incoming directory : " ),

			   submit(  -name=>"updir", -value=>"Incoming" )
			  ) ;

		print div( span({-class=>'label'}, "Add all media files in my Incoming directory : " ),

			   submit(  -name=>"uphome", -value=>"Home" )
			  ) ;

		print div( span({-class=>'label'}, "Add all the media files found on attached device : " ),

			   submit(  -name=>"updevice", -value=>"Device" )
			  ) ;


#	  print div( span({-class=>'label'}, "Upload the files on this computer : " ),
#	  textfield( "onserver" ),

#			   submit( -class=>"but", -name=>"upserver", -value=>"Computer" )
#			  ) ;

		print end_form;
	}


	# broadcasting settings

	if( $this_menu eq 100 ) {

		if( $query->param('mp3channew') ) {
			$q= "INSERT INTO mp3_channel (channel ) VALUES (\'".$query->param('mp3newchanname')."\'); ";

			$mysql->query($q);

		}

		if( $query->param('mp3chandel') ) {
			$q= "delete from mp3_channel  where cid=".$query->param('mp3chancid');

			$mysql->query($q);

		}

		if( $query->param('mp3chanchg') ) {
			$q= "update mp3_channel set transmission_type=".$query->param('mp3chano').", source_type=".$query->param('mp3chani').", channel='".$query->param('mp3channame')."'";

			if( $query->param('mp3chndata1') ) {
				$q=$q.", data1='".$query->param('mp3chndata1')."'";
			}

			if( $query->param('mp3chndata2') ) {
				$q=$q.", data2='".$query->param('mp3chndata2')."'";
			}
			if( $query->param('mp3chndata3') ) {
				$q=$q.", data3='".$query->param('mp3chndata3')."'";
			}
			if( $query->param('mp3chndata4') ) {
				$q=$q.", data4='".$query->param('mp3chndata4')."'";
			}
			if( $query->param('mp3chndata5') ) {
				$q=$q.", data5='".$query->param('mp3chndata5')."'";
			}
			if( $query->param('mp3chndata6') ) {
				$q=$q.", data6='".$query->param('mp3chndata6')."'";
			}
			if( $query->param('mp3chndata7') ) {
				$q=$q.", data7='".$query->param('mp3chndata7')."'";
			}
			if( $query->param('mp3chndata8') ) {
				$q=$q.", data8='".$query->param('mp3chndata8')."'";
			}

			if( $query->param('mp3chanact') ) {
				$q = $q.", active=1";
			}
			else {
				$q = $q.", active=0";
			}


			 $q=$q." where cid=".$query->param('mp3chancid');

			$mysql->query($q);

		}

		print  start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;
		print textfield( "mp3newchanname" );
		print submit(  -name=>"mp3channew", -value=>"New Channel" );
		print end_form ;


		#print "<table><tr>";
		#print "<td>";

		$mysql->query( "select * from mp3_channel order by channel");
		my $record_set = $mysql->create_record_iterator;

		print "<table width='100%'>";
		print Tr(th( "Channel"),
			th("Channel<br>Status"),
			th("Transmission<br>Method"),
			th("Source<br>Method")
			);

		while ( my $record = $record_set->each ) {
			if( $query->param('mp3chanedit') && $query->param('mp3chanedit') eq $record->[0] ) {
				print  start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ) ;
				 print hidden('mp3chancid',$query->param('mp3chanedit'));
				print Tr(
					td(textfield( "mp3channame", $record->[1])),
					td(
checkbox(-name=>"mp3chanact",
                           -checked=>$record->[2],
                           -value=>"Yes",
			   -label=>"",
                             -class=>"label" ))

					,
					td(
						#$channelO{$record->[3]},
						popup_menu(-name=>'mp3chano',
							-values=>\%channelO,
							-default=>$record->[3]
						)
					),
					td(
						#$channelI{$record->[4]},

						popup_menu(-name=>'mp3chani',
							-values=>\%channelI,
							-default=>$record->[4]
						)
					),
					td(
						submit(  -name=>"mp3chanchg", -value=>"Set" )
					)
					);


					# Icecast requirements

				if( $record->[3] eq 2 ) {

					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "Published Stream Name" ),
						td( textfield( "mp3chndata1", $record->[5] )
					) );
					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "Stream Genre" ),
						td( textfield( "mp3chndata2", $record->[6] )
					) );
					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "Stream Description" ),
						td( textfield( "mp3chndata3", $record->[7] )
					) );
					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "Random Play" ),
						td(  radio_group('mp3chndata4',['Yes','No'], $record->[8]) )
					 );
				}

				# web pub requirements

				if( $record->[3] eq 7 ) {

					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "Site FTP Address" ),
						td( textfield( "mp3chndata1", $record->[5] )
					) );
					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "User" ),
						td( textfield( "mp3chndata2", $record->[6] )
					) );
					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "Password" ),
						td( textfield( "mp3chndata3", $record->[7] )
					) );
					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "Directory" ),
						td( textfield( "mp3chndata4", $record->[8], 30 )
					) );
					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "Create index.html Web Page?" ),
						td(  radio_group('mp3chndata5',['Yes','No'], $record->[9]) )
					 );
					print Tr( td( { -colspan=>"2" } ),
						td( {-class=>"label" }, "File Naming Convention" ),
						td( textfield( "mp3chndata6", $record->[10], 30 )
					) );
				}

				print end_form ;
			}
			else {
				print Tr(
					td(  a( { href=>"/cgi-bin/kcp_index.cgi?mp3chanedit=".$record->[0]}, $record->[1])),
					td(   ( $record->[2] ? "Active" : "Inactive")   ),
					td(  $channelO{$record->[3]}),
					td($channelI{$record->[4]}),
td(

  start_form(-action=>'/cgi-bin/kcp_index.cgi', -method=>POST ),
hidden('mp3chancid',$record->[0]),
submit(  -name=>"mp3chandel", -value=>"Delete" ),
				end_form
				)
				);
			}
		}

		print "</table>";

#		print "</td><td>";

#		if( $query->param('mp3chanedit') ) {
#$mysql->query( "select * from mp3_channel where cid=".$query->param('mp3chanedit'));
		#my $record_set = $mysql->create_record_iterator;
		#my $record = $record_set->each



		#}

		#print "</td>";

#		print "</tr></table>";


		#print "Channel settings";
		#print "for each channel options for various transmission methods";
		#print "<br>audio out";
		#print "<br>email (multiple addresses. upload a list or have a database), subject line, message body";
		#print "<br>ftp (server/account info, dest dir, write html page)";
		#print "<br>podcast ( server/account, details, rss feed, peer)";
		#print "<br>dump to directory on workgroup";
		#print "<br>http push (url of html file to use)";
		#print "<br>icecast out (data)";

		#print "<br><br>each channel as an input source";
		#print "<br>play list + ( random playlist selection (ie jingles, ads )";
		#print "<br>webcam stream";
		#print "<br>icecast in (data) ie peered broadcasting stream, mediastation channel to mediastation channel!";
		#print "<br>audio recording (auto add to playlist?)";
		#print "<br>line in";
		#print "<br>cdrom";

		print "<br>for streamed data (icecast, audio) then playlist is rollowing, for packaged channels, email, ftp, podcast then data is broadcast once added and timed release is possible";



	}

	if( $this_menu eq 101 ) {
		print "controls for playback by channel or entire system";
		print "<br>channel switch to audio ";
		print "<br>stop,play,next etc";
		print "<br>record a session";
		print "<br><br>control device";
		print "<br>keypad (buttons)";
		print "<br>ir (buttons)";
		print "<br>web cam (calibrate movement triggers)";
		print "<br>sound (calibrate sound level triggers and response triggers)";
		print "<br><br>text of graphical front screen (warn on graphical about cpu load and cooling)";
		print "<br>start freevo";

	}

	if( $this_menu eq 102 ) {
		print "feedback by channel or entire syste,";
		print "<br>track speach announcement options";
		print "<br>system prompts (text-to-speach input replace with uploaded mp3 or mp3 from catalogue)";
		print "<br>no feedbacks";
		print "<br>simple ping/bong response";

	}

}

1;
#eof
