#!/usr/bin/perl 
use strict;
use DBI;



##  CREATE TABLE appointment (app_date datetime not null, description varchar(256) not null)
##  ALTER TABLE appointment ADD FULLTEXT ft_index_name(description);

package appointments;
{
    use Data::Dumper;
    use JSON;
    
    sub new
    {
        my $class   = shift;
        my $self    = {};
        
        bless $self, $class;
        
        $self->{dbh} = DBI->connect("DBI:mysql:database=appointments", "root", "root") or die "Couldn't connect to database: " . DBI->errstr;
        
        return $self;
    }
    
    
    sub build_page
    {
        my $self    = shift;
        my $msg     = shift;
        
        my $file    = 'appointments.html';
        
        open my $fh, '<', $file or die;
        $/ = undef;
        my $html = <$fh>;
        close $fh;

        $html =~ s/__ERR_MESSAGE__/$msg/s;
                    
        return \$html;
    }
    
    
    sub add_appointment  ## VALUES HAVE ALREADY BEEN CHECKED COMING IN
    {
        my $self    = shift;
        my %args    = @_;
        
        my $date_time = $args{date}.' '.$args{time};
        
        ##  12-01-2014 00:00:00','%m-%d-%Y %H:%i:%s'
        my $sql = "INSERT INTO appointment (app_date, description) VALUES (STR_TO_DATE(?,'%m/%d/%Y %h:%i %p'),?)";
        
        my $sth = $self->{dbh}->prepare($sql);
        
        my $result = $sth->execute($date_time, $args{desc});
        
        if($result != 1)
            {return "Something went wront, please contact me";}
            
        return;
    }
    
    sub get_appointments
    {
        my $self    = shift;
        my $search  = shift;
        
        
        my $sql = "SELECT DATE_FORMAT(app_date, '%M %e') AS app_date, DATE_FORMAT(app_date, '%l:%i %p') AS app_time, description FROM appointment";
        
        if($search)
            {$sql .= " WHERE description LIKE ?";}
        
        my $sth = $self->{dbh}->prepare($sql);
        
        if($search)
            {$sth->execute('%'.$search.'%');}
        else
            {$sth->execute();}
        
        my $results = $sth->fetchall_arrayref();
        
        
        return encode_json $results;
    }
}

1;