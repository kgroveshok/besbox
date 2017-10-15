#!/bin/sh

 while true; do

 	if [ -e /tmp/shutdown ] ; then
		echo "Shutting down shortly" | /opt/flite/flite;
	fi

	if [ -e /tmp/cmdhelp ] ; then
		echo "Command Help, * tell the time, + volume up, - volume down, / record audio and backspace to shutdown right now. Thank you." | /opt/flite/flite;
		rm /tmp/cmdhelp;
	fi

	if [ -e /tmp/volup ] ; then
		echo "Command, Volume up." | /opt/flite/flite;

		rm /tmp/volup;
	fi

	if [ -e /tmp/voldown ] ; then
		echo "Command, Volume down." | /opt/flite/flite;
		rm /tmp/voldown;
	fi

	if [ -e /tmp/recordaudio ] ; then
		echo "Command, record audio. Stop recording by leaving 10 second pause." | /opt/flite/flite;
		rm /tmp/recordaudio;
	fi

	if [ -e /tmp/downnow ] ; then
		echo "Command, shutdown right now." | /opt/flite/flite;
		rm /tmp/recordaudio;
		sudo /sbin/shutdown -h now;
	fi

	if [ -e /tmp/playlist ] ; then


		echo "connect kcp;">/tmp/play.isql;
		echo "SELECT mp3data FROM mp3_playlisti where playlistid=`cat /tmp/playlist` ORDER BY RAND(NOW()) LIMIT 1;">>/tmp/play.isql;

	else
		cp /root/play.isql /tmp/play.isql;
 	fi

	export PLAY=`/opt/mysql/bin/mysql -s </tmp/play.isql `;

	if [ -e /tmp/telltime ] ; then
		/opt/flite/flite_time `date +%H:%m`;
		rm /tmp/telltime;
	fi

	if [ -e /tmp/reboot ] ; then
		echo "Rebooting shortly" | /opt/flite/flite;
	fi

	if [ -e /tmp/announce ] ; then
                /usr/bin/perl /usr/lib/perl5/5.8.0/MP3/Tag/examples/tagged.pl $PLAY | /bin/grep Song | /opt/flite/flite
		/usr/bin/perl /usr/lib/perl5/5.8.0/MP3/Tag/examples/tagged.pl $PLAY | /bin/grep Artist | /opt/flite/flite
		/usr/bin/perl /usr/lib/perl5/5.8.0/MP3/Tag/examples/tagged.pl $PLAY | /bin/grep Album | /opt/flite/flite
	fi

	/opt/mp3decoder/mp3decoder $PLAY  >/tmp/mp3track 2>&1;
	rm /tmp/mp3track;
done
