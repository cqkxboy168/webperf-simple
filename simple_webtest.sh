#!/bin/bash
#simple_webtest.sh
#Ben Jones
#Sep 2013
#simple_webtest.sh: this script is designed to run on the bismark platform. The script will fetch a number of urls and determine the
# the performance of these webpages. The performance data will allow us to see performance difference inside and outside of countries

#configuration parameters
user_agent='Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)'
num_redirects=5
output_format="actual_url:\\t%{url_effective};speed:\\t%{speed_download};code:\\t%{http_code}\\n\
lookup_time:\\t%{time_namelookup};connect_time:\\t%{time_connect};total_time:\\t%{time_total};\\n\
size:\\t%{size_download}"
persistentdir="/tmp/simplehttp"

max_curl_filesize=$((2* 1024 * 1024))

#FUNCTIONS
#setup: this function will prepare the environment for the test
# expected syntax: setup
setup()
{
    timestamp=`date +%s`
    #first, setup a tmp directory for files like the downloaded html
    tempdir=${persistentdir}/tempdir_${timestamp}
    mkdir -p $tempdir; cd $tempdir || exit 1
    
    #now setup files which will be deleted later
    $htmloutput = ${tempdir}/htmloutput.html

    #and persistent storage
    output_file=${persistentdir}/results_${timestamp}
}

#cleanup: this function will delete all temporary files and do cleanup before the script exits
cleanup()
{
    rm -r $tempdir
}

#pick_elem: this function will randomly select n elements from a list. If all elements are selected, the list order will be randomized
# The expected syntax is echo list | pick_elem $n and the list is piped to the function
#Note: this function is copied from Giuseppe's measurement script because it seems to be an efficient way to randomize lists
pick_elem()
{
    if [$# -eq 1]; then n=$1
    else return 1; fi

    #seed the random number generator
    rnd_seed = $((`date`))

    #use awk to read the list in, then sort it or return a random element
    awk 'BEGIN{srand'$rnd_seed'}
         {l[NR] = $0}
         END {if (FNR==0){exit};
              for (i=1; *i <="$pick" && i <=NR); i++){
                   n=int(rand()*(NR-i+1))+i
                   print l[n];l[n]=l[i];
              }
         }'
}

#measure_site: this function will perform the actual measurements.
# expected syntax: measure_site url
measure_site()
{
    curl $1 --max-filesize $max_curl_filesize -L --max-redirs $num_redirects -A "$user_agent" -w $output_format -o $htmloutput >> $output_file
}

#run_measurements: will run the measurements for this test.
# syntax: run_measurements
run_measurements()
{
    for $url in `cat $input_file | pick_elem 100`; do
	measure_site $url
	rm $htmloutput
    done
}


#MAIN- START- here is where the code is actually executed
setup
run_measurements
cleanup





