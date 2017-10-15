# kcp (c) 2005
# common functions and global vars

 $mysql= Net::MySQL->new(
	# hostname => 'mysql.example.jp',   # Default use UNIX socket
	database => 'kcp',
	user     => 'root',
	password => ''
	);

# return session string for key on user

sub getSession( $$ ) {
	my ($user, $key ) = @_;

	# load into workspace the saved

	$mysql->query( "SELECT data FROM user_state where user='".$user."' and tag = '".$key."'");
	my $record_set = $mysql->create_record_iterator;

	my $record = $record_set->each ;
	my $string = $record->[0];
	#$mysql->close;

	return $string;
}

# set session var for user and key

sub putSession( $$$ ) {
my ($user, $key, $string ) = @_;

	# load into workspace the saved

	$mysql->query( "insert into user_state ( user, tag, data ) values ( \'".$user."\',\'".$key."\',\'   \')");

	$mysql->query( "update user_state set data =\'".cleanString($string)."\' where user=\'".$user."\' and tag=\'".$key."\'");

	return $string ;
}

# clean string of single quote to stop mysql inserts from failling.

sub cleanString($) {
	 my ( $string ) = @_;

	$string =~ s/'/\\'/g ;

	return $string;
}

# channel io

%channelI = (
	"1" => "Play List",
	"2" => "Microphone (Inprogress)",
	"3" => "Webcam (Todo)",
	"4" => "Icecast Source (Todo)",
	"5" => "Line In (Inprogess)",
	"6" => "CD (Todo)",
	"7" => "Podcast Feed (Todo)",
	"8" => "Skype (Todo)"
) ;

%channelO = (
	"1" => "Line Out",
	"2" => "Icecast/Shoutcast Channel",
	"3" => "Podcast Feed (Todo)",
	"4" => "FTP (Todo)",
	"5" => "Email Attachments (Inprogress)",
	"6" => "Dump To Storage Device (Todo)",
	"7" => "Publish To Web Page",
	"8" => "CD Burning (Todo)",
	"9" => "Skype (Todo)"
) ;

sub format_time {
  my $frame = shift;
  my ($pf,$rf,$ps,$rs) = split ',', $frame;
  return (gimme_time($ps).'/'.gimme_time($ps+$rs));
}

sub gimme_time {
  my $time = shift;
  my $mins = int($time/60);
  return $mins.':'.sprintf("%02.2f", $time - ($mins*60));
}

sub channelControls() {

}

sub thisHost() {
	$interface="eth0";
	# path to ifconfig
	$ifconfig="/sbin/ifconfig";
	@lines=qx|$ifconfig $interface| or die("Can't get info from ifconfig: ".$!);
	foreach(@lines){
        if(/inet addr:([\d.]+)/){
                $ip=$1;
        }
}

	return $ip;
}




1;

# eof


