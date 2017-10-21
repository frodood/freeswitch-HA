freeswitch-HA

how to HA freeswitch

Configuration Requirements
Track Calls
In the SIP profiles you must have track-calls enabled.
<param name="track-calls" value="true"/>
Failover to a Second Server
If you want to recover calls a second server, then you must have some way of sharing the call recovery data. ODBC or PostgreSQL are possible methods, and to do so, you must specify a DSN for all involved sip profiles (like you needed track-calls on all involved profiles).
<param name="odbc-dsn" value="odbc://dsn:username:password"/>
And also in switch.conf.xml like:
<param name="core-recovery-db-dsn" value="odbc://dsn:username:password"/>
switch name value both machines needs to be the same
<param name="switchname" value="1"/>

Allow FreeSWITCH to bind to non local IP
Add the following line to /etc/sysctl.conf
echo 'net.ipv4.ip_nonlocal_bind=1' >> /etc/sysctl.conf 
Run:
sysctl -p



Setup primary FreeSWITCH server
Make sure that the SIP profiles are set to listen on your virtual IP
<param name="rtp-ip" value="10.10.10.11"/>
<param name="sip-ip" value="10.10.10.11"/>
<param name="presence-hosts" value="10.10.10.11"/>
<param name="ext-rtp-ip" value="10.10.10.11"/>
<param name="ext-sip-ip" value="10.10.10.11"/>
Setup secondary FreeSWITCH server
Make sure that the SIP profiles are set to listen on your virtual IP
<param name="rtp-ip" value="10.10.10.11"/>
<param name="sip-ip" value="10.10.10.11"/>
<param name="presence-hosts" value="10.10.10.11"/>
<param name="ext-rtp-ip" value="10.10.10.11"/>
<param name="ext-sip-ip" value="10.10.10.11"/>




keepalived configurations
Master Node
global_defs {
   notification_email {
   }
   router_id FS_1
}
vrrp_script chk_fs {
	 script "/usr/src/ka-status.pl"
    interval 30
}
vrrp_instance VI_10 {
    state EQUAL
    interface eth0
    garp_master_delay 10
    virtual_router_id 10
    nopreempt
    priority 150
    advert_int 4
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.3.203/21
    }
    track_script {
        chk_fs
    }
	notify "/usr/src/ka-notify.pl"
}

BACKUP Node
global_defs {
   notification_email {
   }
   router_id FS_2
}
vrrp_script chk_fs {
    script "/usr/src/ka-status.pl"

    interval 30
}
vrrp_instance VI_10 {
    state EQUAL
    interface eth0
    garp_master_delay 10
    virtual_router_id 10
    nopreempt
    priority 150
    advert_int 4
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
	192.168.3.203/21
    }
    track_script {
        chk_fs
    }
	 notify "/usr/src/ka-notify.pl"
}

Start the Freeswitch Servers
service freeswitch start
start keepalived servers
service keepalived start


