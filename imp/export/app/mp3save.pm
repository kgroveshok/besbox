#!/usr/bin/perl -w

my $LIBS_DIR = "/home/httpd/cgi-bin/libs";
require "$LIBS_DIR/utils.pm";
use CGI ':standard';
#use strict;
use MP3::Tag;
use Net::MySQL;
use File::Temp;

require "/home/httpd/cgi-bin/kcp_utils/kcp_udf.pm";

my ($mp3, $count, $v1, $v2)=(undef,0,0,0);

#die "usage: mp3save.pl filename(s)" if $#ARGV == -1;

print "<table>";

print Tr(
th( "Song" ),
th( "Artist" ),
th( "Album"),
th("Year"),
th( "Genre"),
th("Track"),
th("Play Time")
);


my $t = time;

for my $filename (@ARGV) {
  next until -f $filename;
  #print " --  $filename:\n";

  $mp3 = MP3::Tag->new($filename);
  $mp3->get_tags;
  $count++;
  if (exists $mp3->{ID3v1}) {
    $v1++;

    print Tr(
    	td($mp3->{ID3v1}->song),
    	td( $mp3->{ID3v1}->artist ),
    	td( $mp3->{ID3v1}->album ),
    	td( $mp3->{ID3v1}->year ),
    	td( $mp3->{ID3v1}->genre ),
    	td( $mp3->{ID3v1}->track),
	td( $mp3->time_mm_ss())
	),
	Tr (
	td( {-colspan=>2} ),
	td( {-colspan=>5},i(  $mp3->{ID3v1}->comment) )
	)
	;

	# read the file

	#my $bin="";
	$fname = mktemp("/opt/extra/mp3/mp3XXXXXXXXXX");


	open(MP3DATA, $filename );
	$f=">".$fname;
	open(OUT, $f ) ;

	while ($bytesread=read(MP3DATA,$buffer,8192)) {
		print OUT $buffer;
	}

	close(MP3DATA);
	close(OUT);



	$encoded = $fname;

	#print $encoded;
	#$encoded = $bin;

# INSERT tags
  $q= "INSERT INTO mp3_catalogue (song, artist, album, comment, year, genre, track, mp3data, play_time,ext) VALUES (\'".cleanString($mp3->{ID3v1}->song)."\', \'".cleanString($mp3->{ID3v1}->artist)."\', \'".cleanString($mp3->{ID3v1}->album)."\',\'".cleanString($mp3->{ID3v1}->comment)."\',\'".$mp3->{ID3v1}->year."\',\'".$mp3->{ID3v1}->genre.".\',\'".$mp3->{ID3v1}->track."\',\'".$encoded."\',\'".$mp3->time_mm_ss()."\','MP3'); ";

  $mysql->query($q);
#  system( "mv ".$filename." ".$fname);

unlink( $filename) ;
  }

    }

    print Tr(

th( {colspan=>7}, "$count Files | $v1 ID3v1 Tags | $v2 ID3v2 Tags | ". (time-$t) . "s" )

	) ;
print "</table>";




