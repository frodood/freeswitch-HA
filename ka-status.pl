#!/usr/bin/perl
use Sys::Syslog;
openlog "ka-status", "ndelay,pid", "local0";
my @required = ("internal","external");

my %saw = ();

$pid = system ("pidof freeswitch");

if($pid){
	syslog(LOG_INFO, "Freeswitch not running, marking failure");
	exit(1);

} else {
    	syslog(LOG_INFO, "Freeswitch running, marking success");
        open(my $in, "-|") || exec("/usr/bin/fs_cli", "-x", "sofia xmlstatus");
        while ( defined(my $line = <$in>) )
        {
            if ( $line =~ m|<name>(.*)</name>|o )
            {
                $saw{$1} = 1;
        }
        }
        close($in);
        foreach my $profile ( @required )
        {
            if ( ! $saw{$profile} )
            {
               syslog(LOG_INFO, "sip profile $profile not found, marking failure");
                exit(1);
            }
        }
        syslog(LOG_INFO, "all required sip profiles found, marking success");
        exit(0);

}
