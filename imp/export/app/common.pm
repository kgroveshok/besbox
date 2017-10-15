 my $mysql_jukebox = Net::MySQL->new(
      # hostname => 'mysql.example.jp',   # Default use UNIX socket
      database => 'jukebox',
      user     => 'root',
      password => ''
  );