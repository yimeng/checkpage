BEGIN{FS="\""}
$0!~/[Hh][Rr][Ee][Ff]=/{next}
{ for(pos=1;pos<NF-1;pos++)
        if($pos~/[Hh][Rr][Ee][Ff]=$/)
                printf("%s\n",$(++pos))
}
