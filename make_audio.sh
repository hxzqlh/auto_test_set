#!/bin/bash

VERSION="1.0.0.0"

media=
out_dir="."

print_usage ()
{
    echo "Usage: $0 -i media -d out_dir"
}

show_info ()
{
    echo "media:[$media]"
    echo "output to dir:[$out_dir]"
}

check_opts () 
{
    while getopts "i:d:v" opt; do
        case "$opt" in
          "i")
            media="$OPTARG"
            [ ! -f "$media" ] && echo "media:[$media] not exit" && exit 2
            ;;

          "d")
            out_dir="$OPTARG"
            [ ! -d "$out_dir" ] && echo "outpur dir:[$out_dir] not exit" && exit 2
            ;;
          "v")
            echo "$0 $VERSION"
            exit 0
            ;;

          "?")
            echo "Unknown option $OPTARG"
            ;;

          ":")
            echo "No argument value for option $OPTARG"
            ;;
          *)
          # Should not occur
            echo "Unknown error while processing options"
            ;;
        esac
        #echo "OPTIND is now $OPTIND"
      done
    
     [ x"$media" == x ]  && print_usage && exit 1
}

do_work ()
{
    k=0

    run="make_audio_sln.sh"
    echo "#!/bin/bash" > "$run"
 
    while read sln; do
        ((k++))
        echo "Line # $k: $sln"

        start=`echo "$sln" | cut -d "," -f 1`
        duration=`echo "$sln" | cut -d "," -f 2`
        smp_rate=`echo "$sln" | cut -d "," -f 3`
        ch_num=`echo "$sln" | cut -d "," -f 4`
        bitrate=`echo "$sln" | cut -d "," -f 5`

        cmd="./facade_audio.sh -i $media "

        [ "x$start" != "x" ] && [ "$start" != "-" ] && cmd+=" -s $start "
        [ "x$duration" != "x" ] && [ "$duration" != "-" ] && cmd+=" -t $duration "
        [ "x$smp_rate" != "x" ] && [ "$smp_rate" != "-" ] && cmd+=" -r $smp_rate "
        [ "x$ch_num" != "x" ] && [ "$ch_num" != "-" ] && cmd+=" -c $ch_num "
        [ "x$bitrate" != "x" ] && [ "$bitrate" != "-" ] && cmd+=" -b $bitrate "

        cmd+=" -d $out_dir"

        echo "$cmd"
        echo "$cmd" >> "$run"
        
    done < "audio.txt"
    bash "$run"

    echo "Total number of solutions: $k"
}

check_opts "$@"

show_info 

do_work
