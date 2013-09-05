#!/bin/ash
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
url_file="/home/ben/Development/webperf/simple_webtest/test1/india.txt" #the location of the url list to be tested
urls_to_test=5
min_wait=1 #the minimum time to wait between web tests
max_wait=2 #the maximum time to wait between web tests
max_experiment_time=1 #experiment must be done in 120 seconds
url_timeout=60 #after 60 seconds, timeout the url
max_curl_filesize=$((2* 1024 * 1024))

#FUNCTIONS
#setup: this function will prepare the environment for the test
# expected syntax: setup
setup()
{
    echo "Setting up"
    timestamp=`date +%s`
    test_start_time=$timestamp
    
    #find the device ID, aka the mac address
    DEVICE_ID=`/sbin/ifconfig | awk '{if (NR == 1){ print $5}}'`

    #make the persistent directory if it doesn't exist (used to store the randomized url list)
    if [ ! -e "$persistentdir" ]; then
	#create the directory
	mkdir -p $persistentdir
    fi

    #and persistent files (eventually deleted after uploads)
    output_dir=${persistentdir}/http_${DEVICE_ID}_${timestamp}
    mkdir -p $output_dir; cd $output_dir || exit 1
    output_file=${output_dir}/http_results_${DEVICE_ID}_${timestamp}.txt
    upload_dir=/tmp/bismark-uploads/censorship-performance/
    
    #create a file for the variable index if it does not exist
    index_file=${persistentdir}/index.var
    if [ ! -e $index_file ]; then
	touch $index_file
    fi
}

#cleanup: this function will delete all temporary files and do cleanup before the script exits
cleanup()
{
    echo "Cleaning up"
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

#create_random_url_list: take the url list, put it in random order, and write it out as a new file
#Note: will overwrite input_file if it exists
create_random_url_list()
{
    echo "Randomizing the url order"
    #create a file to hold the url list
    input_file=`mktemp`
    #randomize the url list and write it out
    cat $url_file | pick_elem > $input_file
    echo $input_file
}

#pick_random_urls: will select the $index through $index + $urls_to_test urls and print them to stdout
pick_random_urls()
{
    exec 6<> $input_file
    cur_loc=0
    endoflist=`expr $index + $urls_to_test` 

    while [ "$cur_loc" -lt "$endoflist" ]; do
	    read line <&6
	    if [ "$cur_loc" -ge "$index" ]; then
		echo $line
	    fi
	    cur_loc=`expr $cur_loc + 1`
    done
    
    #export the index variable to disc and the name of the input file
    index=`expr $index + 5`
    echo index="$index" > $index_file
    echo input_file="$input_file" >> $index_file
}

#upload_data: upload the data to the BISmark servers
upload_data()
{
    #compress the directory
    tar -zcf  ${output_dir}.tar.gz  $output_dir
    mv ${output_dir}.tar.gz $upload_dir

    #delete the content
    cd $persistentdir
    rm -rf $output_dir
}

#measure_site: this function will perform the actual measurements.
# expected syntax: measure_site url
measure_site()
{
    #create a filename to store the html and headers in- just the name of the website
    pageoutput=${output_dir}/${1}
    printf "site:\t%s;time:\t%s\n" "$1" `date +%s`>> $output_file
    curl $1 --max-filesize $max_curl_filesize -L --max-redirs $num_redirects -A "$user_agent" -w $output_format -o ${pageoutput}.html -D ${pageoutput}.headers --connect-timeout $url_timeout >> $output_file
    printf "return_code:\t%s\n" "$?" >> $output_file
}

#run_measurements: will run the measurements for this test.
# syntax: run_measurements
run_measurements()
{
    echo "Measuring"
    #we store the variable index to disc so we have persistent data between reboots-> the file just stores the file
    . $index_file

    #randomize the order of the urls if we haven't already
    #we test whether or not to create the new url list by checking if the index exists or if it is >=100
    
    if [ "$index" = "" ] || [ $index -ge 99 ]
    then
	#set index to 0 and create the randomized url list
	index=0
	create_random_url_list
    fi

    for url in `pick_random_urls $index`; do
	echo $url
	measure_site $url
	#if we are over time, then break
	time_elapsed=$((`date +%s` - test_start_time))
	if [ $time_elapsed -gt $max_experiment_time ]; then
	    echo "Overtime. Stopping test"
	    echo "Could not test other urls- experiment is out of time" >>  $output_file
	    break #break out of the loop and cleanup
	fi
    done
}


#MAIN- START- here is where the code is actually 
setup
run_measurements
upload_data
cleanup

