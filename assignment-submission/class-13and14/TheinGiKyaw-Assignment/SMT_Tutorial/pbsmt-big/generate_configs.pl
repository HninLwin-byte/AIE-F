#!/usr/bin/perl

# Preparing configuration files for PBSMT experiments
# Output: one configuration file for baseline or PBSMT
# *** Before you run this script, you should prepare training, development and test parallel-data in advance!!!

# Written by Finch-san and Ye
# We used this script for running our NAACL paper:
# Ye Kyaw Thu, Andrew Finch and Eiichiro Sumita, 
# "Interlocking Phrases in Phrase-based Statistical Machine Translation",
# In Proceedings of the NAACL-HLT 2016, June 12-17, San Diego, US, pp. 1076-1081.

# Last updated 9 Oct 2019, @Machine Translation Research Summer School, YTU, Myanmar

use strict;

my @langs;

# you have to update the PBSMT experiment path!!!
#my $smtpath = "/home/lar/experiment/kachin-myanmar/demo-mykc-smt";
my $smtpath = "/mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/assignment-submission/class-13and14/TheinGiKyaw-Assignment/pbsmt-big";
my $datapath = "/mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/assignment-submission/class-13and14/TheinGiKyaw-Assignment/clean-data/normalize";
#my $smtpath = "/home/gi/smt-work/SMT_Tutorial/pbsmt";
#my $datapath = "/mnt/d/Job_Requirements/PracticalProjectsFromDrYe/AIE-F/assignment-submission/class-13and14/TheinGiKyaw-Assignment/clean-data/normalize";

# you have to update the data path for running PBSMT experiment!!!

#foreach my $trainFile ( </panfs/panltg2/users/finch/expt/multibtec/corpus/train.[a-z][a-z]> )
#foreach my $trainFile ( </panfs/panmt/users/ye/cluster/corpus/train.[a-z][a-z]>)
#foreach my $trainFile ( </home/tha/experiment/my-rk/data/train.[a-z][a-z]>)
#foreach my $trainFile ( </home/lar/experiment/kachin-myanmar/demo-mykc-smt/4demo/train.[a-z][a-z]>)
foreach my $trainFile ( <$datapath/train.[a-z][a-z]>)
{                        
        $trainFile =~ m/train.([a-z][a-z])/;
        
        push @langs, $1;
}

foreach my $expt (qw/baseline/)
{

die("$smtpath/$expt") if (-d "$smtpath/$expt");
`mkdir -p $smtpath/$expt`;
    foreach my $src (@langs)
    {
    	foreach my $trg (@langs)
    	{
    		next if $src eq $trg;
            #next if $src ne "my" and $trg ne "my";
    
    		my $pair = "${src}-${trg}";
    		my $configFile = "$smtpath/$expt/$pair/config.${expt}.$pair";

            	`mkdir -p $smtpath/$expt/$pair`;

    		open FILE, ">$configFile" or die;
    
    		print FILE "# Config file for $pair ($expt)\n";
    		print FILE "\n[GENERAL]\n";
    		print FILE "working-dir = $smtpath/$expt/$pair\n";
    		print FILE "input-extension = ${src}\n";
    		print FILE "output-extension = ${trg}\n";
    		print FILE "pair-extension = ${pair}\n";
    		print FILE "\n";
    		close FILE;
     	
     	    `cat $configFile config.$expt > tmp`;
    	    `mv tmp $configFile`;
   	    }
    }
}
