#!/bin/bash

#this script will copy the url file for the appropriate country to the webfile for each country

copy_file()
{
    sudo cp ~/Development/webperf/simple_webtest/test1/$1 /var/www/external/censorship-performance/simple-http/$2
}

update_home_router()
{
    copy_file india.txt OWC43DC7B0AE9F.txt #copy a file for my home router
}
update_tests()
{
    update_home_router #copy a file for my home router
    copy_file india.txt 4c72b94287a1.txt #copy a file for my workstation
    copy_file india.txt OW204E7F4A7478.txt #copy a file for the .6 router attached to beagle
    copy_file indonesia.txt OWC43DC7B0AE63.txt
}

update_hongkong()
{
    copy_file hongkong.txt OW20E52A52DBFD.txt
}

update_india()
{
    copy_file india.txt OW204E7F99924E.txt
    copy_file india.txt OW204E7F9992DE.txt
    copy_file india.txt OW204E7F99933B.txt
    copy_file india.txt OW204E7F999356.txt
    copy_file india.txt OW204E7F99940A.txt
    copy_file india.txt OW204E7F99944C.txt
    copy_file india.txt OW2CB05D9C6485.txt
    copy_file india.txt OW2CB05DA0D720.txt
    copy_file india.txt OW7444019361F5.txt
    copy_file india.txt OW744401936A32.txt
}

update_indonesia()
{
    copy_file indonesia.txt OW204E7F80642F.txt
    copy_file indonesia.txt OW204E7F80649B.txt
    copy_file indonesia.txt OW204E7F80659A.txt
}

update_japan()
{
    copy_file japan.txt OW204E7F740D69.txt
    copy_file japan.txt OW204E7F744102.txt
}

update_mexico()
{
    copy_file mexico.txt OW744401933A9E.txt
    copy_file mexico.txt OWA021B79BA8B4.txt
    copy_file mexico.txt OWC43DC7AD8D8D.txt
    copy_file mexico.txt OWC43DC7B079B9.txt
}

update_pakistan()
{
    copy_file pakistan.txt OW204E7F805E83.txt
    copy_file pakistan.txt OW204E7F858E30.txt
    copy_file pakistan.txt OW204E7F858FB9.txt
    copy_file pakistan.txt OW4C60DEE6AFF5.txt
    copy_file pakistan.txt OW4C60DEE6B0D9.txt
    copy_file pakistan.txt OW4C60DEE6C72F.txt
    copy_file pakistan.txt OW4C60DEE6C732.txt
}

update_singapore()
{
    copy_file singapore.txt OW204E7F805E4D.txt
    copy_file singapore.txt OW204E7F80644D.txt
    copy_file singapore.txt OW204E7F806708.txt
    copy_file singapore.txt OW204E7F80803A.txt
}

update_southafrica()
{
    copy_file southafrica.txt OW2CB05D830284.txt
    copy_file southafrica.txt OW2CB05D830287.txt
    copy_file southafrica.txt OW2CB05D83028A.txt
    copy_file southafrica.txt OW2CB05D830296.txt
    copy_file southafrica.txt OW2CB05D8302A5.txt
    copy_file southafrica.txt OW2CB05D8302AB.txt
    copy_file southafrica.txt OW2CB05D8302C0.txt
    copy_file southafrica.txt OW2CB05D830386.txt
    copy_file southafrica.txt OW2CB05D873B72.txt
    copy_file southafrica.txt OWC43DC7B0AF3B.txt
    copy_file southafrica.txt OWC43DC7B0D242.txt
    copy_file southafrica.txt OW100D7F64C8A3.txt
    copy_file southafrica.txt OW100D7F64C8CD.txt
    copy_file southafrica.txt OW100D7F64CA02.txt
    copy_file southafrica.txt OW100D7F64CB55.txt
}

update_thailand()
{
    copy_file thailand.txt OW204E7F4A7BA1.txt
    copy_file thailand.txt OW204E7F80764A.txt
}

update_initial_deployment()
{
    copy_file china.txt OWC43DC7B0AEDB.txt
    copy_file hongkong.txt OWC43DC78EE081.txt
    copy_file india.txt OWC43DC7B0AE78.txt
    copy_file indonesia.txt OWC43DC7A376D3.txt
    copy_file japan.txt OWC43DC79DE0F7.txt
    copy_file mexico.txt OWC43DC7B0AE54.txt
    copy_file pakistan.txt OWC43DC7A3EE43.txt
    copy_file singapore.txt OWC43DC7A37C01.txt
    copy_file southafrica.txt OWC43DC7A3F0D4.txt
}
#update each category of files in turn
update_all()
{
    update_tests
    update_hongkong
    update_india
    update_indonesia
    update_japan
    update_mexico
    update_pakistan
    update_singapore
    update_southafrica
    update_thailand
}

update_initial_deployment

