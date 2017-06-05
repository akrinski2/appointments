#!/usr/bin/perl 
use strict;
use CGI;

use Data::Dumper;

use appointments;



my $cgi     = new CGI;

my $appt    = new appointments;

my @params = $cgi->param();

my $msg;

#print $cgi->header();
    
if(@params > 0)
{
    my $date    = $cgi->param("date");
    my $time    = $cgi->param("time");
    my $desc    = $cgi->param("desc");
    my $ajax    = $cgi->param("ajax");
    my $search  = $cgi->param("search");
    
    
    if($date && $time && $desc) ## ADDING AN APPOINTMENT
        {$msg = $appt->add_appointment(date => $date, time => $time, desc => $desc);}
    
    if($ajax == 1)
    {
        print $cgi->header('Content-Type: application/json');
        
        print STDERR "\n\nSEARCH $search\n\n";
        print $appt->get_appointments($search);
        exit;
    }
    
    ## IF WE GET HERE, SOMETHING IS WRONG
}



    ## BUILD THE PAGE
    my $html = $appt->build_page($msg);
    
    print $cgi->header();

    print $$html;















