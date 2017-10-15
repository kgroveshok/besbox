#!/usr/bin/perl

#sleep 20;
use Net::MySQL;
use Term::InKey;
#use Term::ReadKey;
#use POSIX;

require "/home/httpd/cgi-bin/kcp_utils/kcp_udf.pm";
use Audio::Daemon::Client;

my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9100);

sleep 20;

print "Monitor....";

		# load list of playlists

$mysql->query("select PL.playlistid, PL.description, count(PI.itemno) from mp3_playlist PL left join mp3_playlisti PI on (PL.playlistid=PI.playlistid)  group by PL.playlistid, PL.description");
my $record_set = $mysql->create_record_iterator;

%playlists="";

while (my $record = $record_set->each ) {
	$playlist{$record->[0]}=$record->[1].", ".$record->[2]." tracks";
}

$pli=1;



# monitor keyboard for eventsususe Audio::Daemon::MPG123;


setpriority 0,0,20;

$usingplaylist=0;
$announce=0;
$randommode=0;

#$mysql->query( "select mp3data from mp3_queue");

			#my $record_set = $mysql->create_record_iterator;
			#while (my $record = $record_set->each ) {
				#print "<br>".$record->[0];
			#	$player->add($record->[0]);
			#}
#$player->play;

 #$termios = POSIX::Termios->new;
#my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9101);
#$player->stop;
#system( "echo \"Ready\" | /opt/flite/flite");
#$player->play;


$pli=getSession('monitor','playlist')+0;

if( $pli eq "") {
$pli=1;
}

print "Auto loading last playlist ",$pli;
$q= "select mp3data from mp3_playlisti WHERE playlistid=".$pli;

#print $q;

		$mysql->query($q);

		my $record_set = $mysql->create_record_iterator;
		while (my $record = $record_set->each ) {
				print $record->[0];
#				my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9101);
			$player->add($record->[0]);
		}

while( 1 ) {



        $x = &ReadKey;
 #while (not defined ($x = ReadKey(-1))) {
                # No key yet
  #      }

  	if( ord($x) eq 13 ) {
		$player->stop;
		$player->info;
		$status = $player->status;
		 $a= "   \"".$status->{title}.", ".$status->{album}.'" by '.$status->{artist};
		 system( "echo \"".$a."\" | /opt/flite/flite");
		 $player->play;

	}

	if( $x eq "1" ) {
		#$player->vol(10);
		print "Vol 10%";
		system( "/usr/bin/aumix -v 10");
	}
	if( $x eq "2" ) {
		#$player->vol(10);
		print "Vol 20%";
		system( "/usr/bin/aumix -v 20");
	}
	if( $x eq "3" ) {
		#$player->vol(10);
		print "Vol 30%";
		system( "/usr/bin/aumix -v 30");
	}
if( $x eq "4" ) {
		#$player->vol(10);
		print "Vol 40%";
		system( "/usr/bin/aumix -v 40");
	}
	if( $x eq "5" ) {
		#$player->vol(50);
		print "Vol 50%";
		system( "/usr/bin/aumix -v 50");
	}
if( $x eq "6" ) {
		#$player->vol(10);
		print "Vol 60%";
		system( "/usr/bin/aumix -v 60");
	}
if( $x eq "7" ) {
		#$player->vol(10);
		print "Vol 70%";
		system( "/usr/bin/aumix -v 70");
	}
if( $x eq "8" ) {
print "Vol 80%";
		#$player->vol(10);
		system( "/usr/bin/aumix -v 80");
	}
	if( $x eq "9" ) {
		#$player->vol(100);
		print "Vol 100%";
		system( "/usr/bin/aumix -v 100");
	}

	if( $x eq "0" ) {
		print "Time";
#			my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9101);
			$player->stop;
			system( "/opt/flite/flite_time `date +%H:%m`");
			$player->play;
			#system( "/bin/touch /tmp/telltime");
			#unlink( "/tmp/cmdhelp") ;
		}

	if( ord($x) eq 127 ) {
#		my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9101);
		$player->stop;
		system( "echo \"Shutting down now\" | /opt/flite/flite");
		system( "sudo /sbin/shutdown -h now");
		$player->play;
	}
	if( $x eq "+" ) {
		print "Next";
#		my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9101);
		$player->next;
		if( $announce ) {
			$player->stop ;
		 	my $status = $player->status;

			$a="echo \"".$status->{title}.", ".$status->{album}.' by '.$status->{artist}."\" | /opt/flite/flite ";
			system($a);

			$player->play ;
		}

		#system( "sudo /usr/bin/killall mp3decoder");
	}

	if( $x eq "-" ) {
		print "Prev";
#		my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9101);
		$player->prev;
		if( $announce ) {
			$player->stop ;
			my $status = $player->status;
			$a="echo \"".$status->{title}.' by '.$status->{artist}."\" | /opt/flite/flite ";
			system($a);

			$player->play ;
		}

		#system( "sudo /usr/bin/killall mp3decoder");
	}

	if( $x eq "*" ) {
#		my $player = new Audio::Daemon::Client(Server => '127.0.0.1', Port => 9101);
		if( $randommode ) {
			$player->random(0);
			$randommode=0;
			$player->stop ;
			system( "echo \"Random play off\" | /opt/flite/flite");
			$player->play ;
		} else {
			$player->random(1);
			$randommode=1;
			$player->stop ;
			system( "echo \"Random play on\" | /opt/flite/flite");
			$player->play ;
		}



		#system( "sudo /usr/bin/killall mp3decoder");
	}


	if( $x eq "." ) {


		$player->stop ;

		$fl="List called ".$playlist{$pli}.", press dot to select. Any other for next.";
		print $fl;
		system( "echo \"".$fl."\" | /opt/flite/flite");

		$x = &ReadKey;

		if( $x eq "." ) {
			$pli=putSession('monitor','playlist',$pli)+0;
			print "yes";

			$fl = "Loading selected playlist called ".$playlist{$pli};

			print $fl;

			system( "echo \"".$fl."\" | /opt/flite/flite");
			$player->play;

	#print "hjello";
			$q= "select mp3data from mp3_playlisti WHERE playlistid=".$pli;

	#print $q;

			$mysql->query($q);

			my $record_set = $mysql->create_record_iterator;
			while (my $record = $record_set->each ) {
					print $record->[0];
				$player->add($record->[0]);
			}

		#	$player->stop;
		#	system( "echo \"playlist loaded\" | /opt/flite/flite");
		print "playlist loaded";



	}
	else {
		$pli++;
		if( $playlist{$pli} ) {
		}
		else {
			$pli=1;
		}
		system( "echo \"Next List. Press dot.\" | /opt/flite/flite");
		$player->play;
	}

	}
#


#		system( "/bin/touch /tmp/cmdhelp");

#		$a = &ReadKey;
		#if( $a eq "*" ) {
		#	$player->stop;
		#	system( "/opt/flite/flite_time `date +%H:%m`");
		#	$player->start;
			#system( "/bin/touch /tmp/telltime");
			#unlink( "/tmp/cmdhelp") ;
		#}
		#if( $a eq "+" ) {
		#	system( "/bin/touch /tmp/volup");
		#	unlink( "/tmp/cmdhelp") ;
		#}
		#if( $a eq "-" ) {
	#		system( "/bin/touch /tmp/voldown");
	#		unlink( "/tmp/cmdhelp") ;
	#	}
	#	if( $a eq "/" ) {
	#		if( $usingplaylist ) {
	#		print "Playlist off, back to system playlist";
	#		unlink( "/tmp/playlist");
	#		unlink( "/tmp/cmdhelp") ;
	#		$usingplaylist=0;
	#		}
	#		else {
	#		$usingplaylist=1;
	#		print "Enter playlist number:";

#			open( PL, ">/tmp/playlist");
#			print PL $b ;
#			close(PL);
#			#system( "/bin/touch /tmp/recordaudio");
#			}

#			unlink( "/tmp/cmdhelp") ;

#		}
#		if( ord($a) eq 127 ) {
#			system( "/bin/touch /tmp/downnow");
#			unlink( "/tmp/cmdhelp") ;
#		}

#	}

	if( $x eq "/" ) {
		if( $announce ) {
		#unlink( "/tmp/announce");
		$player->stop ;
			system( "echo \"Announce off\" | /opt/flite/flite");
			$player->play ;
		$announce=0;
		}
		else {
		#system( "/bin/touch /tmp/announce");
		$player->stop ;
			system( "echo \"Announce on\" | /opt/flite/flite");
			$player->play ;
		$announce=1;
		}
	}

	}

#eof
