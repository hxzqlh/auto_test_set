#!/bin/bash

VERSION="1.0.0.0"

media=
wxh=
out_dir="."

print_usage ()
{
    echo "Usage: $0 -i media [-p wxh] [-d out_dir]"
}

show_info ()
{
    echo "media:[$media]"
    [ x$wxh != x ] && echo "frame_size:[$wxh]"
    echo "output to dir:[$out_dir]"
}

check_opts () 
{
    while getopts "i:p:d:v" opt
      do
        case "$opt" in
          "i")
            media="$OPTARG"
            [ ! -f "$media" ] && echo "media:[$media] not exit" && exit 2
            ;;

          "p")
            wxh="$OPTARG"
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
    run="ffmpeg_image.sh"
    echo "#!/bin/bash" > "$run"
    echo "$cmd" >> "$run"
    chmod +x $run

    while read fmt; do
        echo "Generating for: $fmt"

        cmd="ffmpeg -y " 
        cmd+="-i $media"
        cmd+=" -pix_fmt yuv420p "
        
        [ x$wxh != x ] && cmd+=" -s $wxh "

        # output file
        cmd+=" $out_dir/$wxh.$fmt"

        echo "echo \"$cmd\"" >> $run
        echo "$cmd" >> $run

    done < "image_fmt.txt"

    bash $run
}

check_opts "$@"

show_info

ffmpge_work
