#!/bin/bash

VERSION="1.0.0.0"

media=
start_sec=
duration=
wxh=
fps=
#128k 256k 
bitrate=
out_dir="."

print_usage ()
{
    echo "Usage: $0 -i media [-s start_sec] [-t duration] [-p wxh] [-r fps] [-b bitrate] -d out_dir"
}

show_info ()
{
    echo "media:[$media]"
    [ x$start_sec != x ] && echo "start from:[$start_sec]"
    [ $duration != x ] && echo "duration:[$duration]"
    [ x$wxh != x ] && echo "frame_size:[$wxh]"
    [ x$fps != x ] && echo "fps:[$fps]"
    [ x$bitrate != x ] && echo "bitrate:[$bitrate]"
    echo "output to dir:[$out_dir]"
}

check_opts () 
{
    while getopts "i:s:t:p:r:b:d:v" opt
      do
        case "$opt" in
          "i")
            media="$OPTARG"
            [ ! -f "$media" ] && echo "media:[$media] not exit" && exit 2
            #name=`basename "$media"`
            #dir="$(cd $(dirname "$media") && pwd -P)"
            #media="$dir/$name"
            ;;

          "s")
            start_sec="$OPTARG"
            ;;
 
          "t")
            duration="$OPTARG"
            ;;

          "p")
            wxh="$OPTARG"
            ;;

          "r")
            fps="$OPTARG"
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
    run="ffmpeg_video.sh"
    echo "#!/bin/bash" > "$run"
    echo "$cmd" >> "$run"
    chmod +x $run

    for file in `ls video_*.txt`; do
        echo "Generating for: $file"
        fmt=`echo $file | cut -d "_" -f 2 | cut -d "." -f 1 `
        k=0

        while read codec; do
            ((k++))
            echo "Line # $k: $codec"

            cmd="ffmpeg -y " 
            [ x$start_sec != x ] && cmd+=" -ss $start_sec "
            cmd+="-i $media"
            [ x$duration != x ] && cmd+=" -t $duration "
            cmd+=" -map v:0 "
            cmd+=" -c:v $codec "

            if [ $codec == "h263" ]; then 
                #Valid sizes are 128x96, 176x144, 352x288, 704x576, and 1408x1152 for h263
                cmd+=" -s 176x144 "
            else 
                [ x$wxh != x ] && cmd+=" -s $wxh "
            fi
            [ x$bitrate != x ] && cmd+=" -b:v $bitrate "

            # output file
            cmd+=" $out_dir/`echo $codec`_`echo $duration`s_`echo $wxh`_`echo $bitrate`.$fmt"
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
