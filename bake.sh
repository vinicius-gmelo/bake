#!/bin/sh

<<DESC
- Syntax: bake [set|unset|what]
- Create backups at /tmp, tar.gz files. 
  Root dir can be set with 'bake set'.
DESC

# TODO: 'bake n': 'n' is interval in minutes for creating backups

readonly bake_file=$HOME/.bake

read_bake_file ()
{
  if [ -s $bake_file ]; then
    . $bake_file 2>/dev/null
    if [ ! $? -eq 0 ] || [ ! -d $root_dir ]; then
      while true
      do
        printf 'file %s not readable; fix it [y/N]? ' "$bake_file"
        read erase
        case "$erase" in
          Y|y)
            echo 'root_dir=' > $bake_file
            break
            ;;
          N|n|'')
            exit 1
            ;;
        esac
      done
    fi
  else
    echo 'root_dir=' > $bake_file
    . $bake_file 2>/dev/null
  fi
}

create_backup ()
{
  [ -z $root_dir ] && root_dir=$(pwd)
  [ $root_dir != $(pwd) ] && cd ${root_dir}
  cd ..
  file_name=$(echo "$root_dir" | tr / _ | cut -c 2-).$(date +%s).tar.gz
  if [ -z $1 ]; then
    dir=/tmp
  else
    dir=$(dirname $1)/$(basename $1)
  fi
  bak_file=${dir}/$file_name
  # '--checkpoint=.500' - show progress
  tar -zc --totals --checkpoint=.500 $(basename $root_dir) > $bak_file
  if [ $? -eq 0 ]; then  
    printf 'bake: file created: %s\n' "$bak_file"
    exit 0
  fi
}

if [ $# -gt 1 ]; then
  printf 'bake [set|unset|what]\n'
  exit 1
fi

read_bake_file

case "$1" in
  '')
    create_backup
    exit 1
    ;;
  set)
    root_dir=$(pwd)
    sed -i "s|\(root_dir=\)\(.*\)|\1${root_dir}|" $bake_file || exit 1
    printf 'root_dir=%s\n' "$root_dir" && exit 0
    exit 1
    ;;
  unset)
    sed -i "s/\(root_dir=\)\(.*\)/\1/" $bake_file || exit 1
    read_bake_file
    printf 'root_dir=%s\n' "$root_dir" && exit 0
    exit 1
    ;;
  what)
    printf 'root_dir=%s\n' "$root_dir" && exit 0
    exit 1
    ;;
  where)
    while :
    do
      printf '(q|Q for quit): '
      read dir
      if [ $dir = q ] || [ $dir = Q ]; then
        exit 0
      elif [ -d $dir ]; then
        create_backup $dir
      fi
    done
    exit 1
    ;;
  *)
    printf 'bake [set|unset|what]\n'
    exit 1
esac
