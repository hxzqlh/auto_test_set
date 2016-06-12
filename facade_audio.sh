#!/bin/bash

VERSION="1.0.0.0"

media=
start_sec=
duration=
smp_rate=
ch_num=
#128k 256k...
bitrate=
out_dir="."

print_usage ()
{
    echo "Usage: $0 -i media [-s start_sec] [-t duration] [-r smp_rate] [-c ch_num] [-b bitrate] -d out_dir"
}

show_info ()
{
    echo "media:[$media]"
    [ x$start_sec != x ] && echo "start from:[$start_sec]"
    [ $duration != x ] && echo "duration:[$duration]"
    [ x$smp_rate != x ] && echo "sample_rate:[$smp_rate]"
    [ x$smp_size != x ] && echo "sample_size:[$smp_size]"
    [ x$ch_num != x ] && echo "channel_num:[$ch_num]"
    [ x$bitrate != x ] && echo "bitrate:[$bitrate]"
    echo "output to dir:[$out_dir]"
}

check_opts () 
{
    while getopts "i:s:t:r:c:b:d:v" opt
      do
        case "$opt" in
          "i")
            media="$OPTARG"
            [ ! -f "$media" ] && echo "media:[$media] not exit" && exit 2
            ;;

          "s")
            start_sec="$OPTARG"
            ;;
 
          "t")
            duration="$OPTARG"
            ;;

          "r")
            smp_rate="$OPTARG"
            ;;

          "c")
            ch_num="$OPTARG"
            ;;

          "b")
            bitrate="$OPTARG"
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

ffmpge_work ()
{
    run="ffmpeg_audio.sh"
    echo "#!/bin/bash" > "$run"
    echo "$cmd" >> "$run"
    chmod +x $run

    for file in `ls audio_*.txt`; do
        echo "Generating for: $file"
        fmt=`echo $file | cut -d "_" -f 2 | cut -d "." -f 1 `
        k=0

        ff_media="$media"
        ff_start_sec="$start_sec"
        ff_duration="$duration"
        ff_smp_rate="$smp_rate"
        ff_ch_num="$ch_num"
        ff_bitrate="$bitrate"
        ff_out_dir="$out_dir"

        while read line; do
            ((k++))
            echo "Line # $k: $line"

            echo "$line" | grep ","
            if [ $? -eq 0 ]; then 
                # do with some special such as: amr_nb,8000,1
                pos=0
                while [ ! -z "$line" ]; do
                    ((++pos))
                    seg=`echo $line | cut -d "," -f 1`
                    line=`echo ${line#*,}`
                    if [ $pos -eq 1 ]; then
                        codec=$seg
                    elif [ $pos -eq 2 ]; then
                        ff_smp_rate=$seg
                    elif [ $pos -eq 3 ]; then
                        ff_ch_num=$seg          
                    fi
                done
            else
                codec="$line"
            fi

            cmd="ffmpeg -y " 
            [ x$ff_start_sec != x ] && cmd+=" -ss $ff_start_sec "
            cmd+="-i $ff_media"
            [ x$ff_duration != x ] && cmd+=" -t $ff_duration "
            cmd+=" -map a:0 "
            cmd+=" -c:a $codec "

            [ x$ff_smp_rate != x ] && cmd+=" -ar $ff_smp_rate "
            [ x$ff_ch_num != x ] && cmd+=" -ac $ff_ch_num "
            [ x$ff_bitrate != x ] && cmd+=" -b:a $ff_bitrate "

            # for some experimental codecs
            cmd+=" -strict -2"

            cmd+=" $ff_out_dir/`echo $codec`_`echo $ff_duration`s_`echo $ff_smp_rate`_`echo $ff_ch_num`_`echo $ff_bitrate`.$fmt"
            echo "echo \"$cmd\"" >> $run
            echo "$cmd" >> $run

        done < $file
        echo "Total number of codecs in $file: $k"
    done

    bash $run
}

check_opts "$@"

show_info

ffmpge_work
