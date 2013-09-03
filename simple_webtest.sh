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
size:\\t%{size_download};"
persistentdir="/tmp/censorship-performance"
input_file="/home/ben/Development/webperf/simple_webtest/test1/china.txt" #the location of the url list to be tested
min_wait=1 #the minimum time to wait between web tests
max_wait=30 #the maximum time to wait between web tests
max_curl_filesize=$((2* 1024 * 1024))

#FUNCTIONS
#setup: this function will prepare the environment for the test
# expected syntax: setup
setup()
{
    echo "Setting up"
    timestamp=`date +%s`
    #first, setup a tmp directory for files like the downloaded html
    tempdir=${persistentdir}/tempdir_${timestamp}
    mkdir -p $tempdir; cd $tempdir || exit 1
    
    # no saved device_id
    if [ "$DEVICE_ID" = "" ]; then
	# read DEVICE_ID (linux-dbus):
	[ -e /var/lib/dbus/machine-id ] && DEVICE_ID=`cat /var/lib/dbus/machine-id`

	# read DEVICE_ID (bismark):
	[ -e /etc/bismark/bismark.conf ] && . /etc/bismark/bismark.conf


	if [ "$DEVICE_ID" = "" ]; then
		DEVICE_ID=`uuidgen`;
		echo "DEVICE_ID=$DEVICE_ID" >> $configfile
	fi
    fi
    DEVICE_ID=${DEVICE_ID}-${clientnotes}

    #now setup files which will be deleted later
    htmloutput=${tempdir}/htmloutput.html

    #and persistent files (eventually deleted after uploads)
    output_file=${persistentdir}/http_results_${timestamp}.txt
    upload_file=/censorship-performance/http_results_${DEVICE_ID}_${timestamp}


}

#cleanup: this function will delete all temporary files and do cleanup before the script exits
cleanup()
{
    echo "Cleaning up"
    rm -r $tempdir
}

#pick_elem: this function will randomly select n elements from a list. If all elements are selected, the list order will be randomized
# The expected syntax is echo list | pick_elem $n and the list is piped to the function
#Note: this function is copied from Giuseppe's measurement script because it seems to be an efficient way to randomize lists
pick_elem()
{
    if [ $# -eq '1' ]; then
	n=$1
    else n="NR" #if the list length is not given, then use the number of lines read in as the length
    fi

    #seed the random number generator
    rnd_seed=$(($timestamp + `cut -d" " -f1 /proc/self/stat` ))

    #use awk to read the list in, then sort it or return a random element
    awk 'BEGIN {srand('$rnd_seed')}
               {l[NR]=$0;}
         END   {if (FNR==0){exit};
                 for (i=1;(i<='$n' && i<=NR);i++){
                     n=int(rand()*(NR-i+1))+i;
                     print l[n];l[n]=l[i];
                 }
               }'
}

#upload_data: upload the data to the BISmark servers
upload_data()
{
    mv $output_file $output_dir
}

#measure_site: this function will perform the actual measurements.
# expected syntax: measure_site url
measure_site()
{
    printf "site:\t%s;time:\t%s\n" "$1" `date +%s`>> $output_file
    curl $1 --max-filesize $max_curl_filesize -L --max-redirs $num_redirects -A "$user_agent" -w $output_format -o $htmloutput >> $output_file
    printf "return_code:\t%s\n" "$?" >> $output_file
}

#run_measurements: will run the measurements for this test.
# syntax: run_measurements
run_measurements()
{
    echo "Measuring"
    #randomize the order of the urls, then test all of them
    for url in `cat $input_file | pick_elem`; do
	measure_site $url
	rm $htmloutput
	#do a random wait between each element
	sleep `seq $min_wait $max_wait | pick_elem 1`
    done
}


#MAIN- START- here is where the code is actually executed
setup
run_measurements
upload_data
cleanup