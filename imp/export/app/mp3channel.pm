#!/usr/bin/perl

use Net::MySQL;
require "/home/httpd/cgi-bin/kcp_utils/kcp_udf.pm";
#use Audio::Daemon::Shout;
use Audio::Daemon::MPG123;

sub log {
  # this could use some cleaning up, but make it whatever you like.
  my $type = shift;
  my $msg = shift;
  my ($line, $function) = (@_)[2,3];
  $function = (split '::', $function)[-1];
  printf("%6s:%12s %7s:%s\n", $type, $function, '['.$line.']', $msg);
}


# scan and build icecast channels

$mysql->query( "select * from mp3_channel where active>0 and transmission_type=2");
my $record_set = $mysql->create_record_iterator;

$isiceon=0;

$host=thisHost();

while (my $record = $record_set->each ) {

	if( !$isiceon ) {
		# start icecast server seeing we have some channels to start

		system("/usr/local/bin/icecast -c /usr/local/etc/iceccast.xml -b");
		$isiceon=1;
	}

	$randompl=0;
	if( $record->[8] eq "Yes" ) {
		$randompl=1;
	}

open( IC, ">/tmp/ices.conf.".$record->[1]);

print IC <<EOF;
<?xml version="1.0"?>
<ices:Configuration xmlns:ices="http://www.icecast.org/projects/ices">
EOF


	if( $record->[4] eq "1" ) {
	print IC <<EOF1;
	 <Playlist>
    <File>/tmp/playlist.$record->[1]</File>
      <Randomize>$randompl</Randomize>
    <Type>builtin</Type>
     <Module>ices</Module>
  </Playlist>
EOF1


  }


print IC <<EOF3;
  <Execution>
    <Background>0</Background>
    <Verbose>0</Verbose>
    <BaseDirectory>/tmp</BaseDirectory>
  </Execution>

  <Stream>
    <Server>
      <Hostname>localhost</Hostname>
      <Port>8000</Port>
      <Password>password</Password>
      <Protocol>http</Protocol>
    </Server>

EOF3


if( $record->[4] eq "2" ) {

	print IC <<EOF2;

<input>
<module>oss</module>
	<param name="rate">44100</param>
	<param name="channels">2</param>
	<param name="device">/dev/dsp</param>
	<param name="metadata">1</param>
	<param name="metadatafilename">/home/ices/metadata</param>
</input>
EOF2


}

print IC <<EOF4;
    <Mountpoint>/$record->[1]</Mountpoint>
    <Name>$record->[5]</Name>
    <Genre>$record->[6]</Genre>
    <Description>$record->[7]</Description>
    <URL>http://$host:8000/$record->[1].m3u</URL>
    <Bitrate>128</Bitrate>
    <Reencode>0</Reencode>
    <Channels>2</Channels>
  </Stream>
</ices:Configuration>
EOF4

close(IC);



# build playlist

$mysql->query( "select mp3data from mp3_queue where cid='".$record->[0]."' order by qid");

	my $record_set2 = $mysql->create_record_iterator;

	open( PL, ">/tmp/playlist.".$record->[1]);
	while (my $record2 = $record_set2->each ) {
		print PL $record2->[0]."\n";
	}
	close( PL ) ;
# fork ices stream

		system("/usr/local/bin/ices -c /tmp/ices.conf.".$record->[1]." -B");


}





# scan for any audio channels

$mysql->query( "select * from mp3_channel where  active>0 and transmission_type=1");
my $record_set = $mysql->create_record_iterator;

while (my $record = $record_set->each ) {
		# audio channel

		#$port = 9100+$record->[0];
		$mysql->close;
		print "Starting channel ".$record->[1];

		setpriority 0,0,20;

		my $daemon = new Audio::Daemon::MPG123( Port => 9100, Log => \&log );

		$daemon->mainloop;
}

