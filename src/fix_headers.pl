
#!/usr/bin/env perl

# Quick script to modify the headers of a fasta file 
open(I,$ARGV[0]) || die ("could not read $ARGV[0]") ; 


 while (my $line= <I>){
   chomp($line); 
   if ($line=~/\>/){
     my @h=split/\s+/,$line;  
     $h[4]=~s/transcript://;
     print ">".$h[4]."\n"
   } else{
      print "$line\n";
   }
}
close(I);

