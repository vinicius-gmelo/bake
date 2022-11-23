#!/bin/sh

<<DESC
- Syntax: bake [set|unset|what]
- Create backups at /tmp, tar.gz files. 
  Root dir can be set with 'bake set'.
DESC

prompt_echo()
{
  local options
  local args
  for arg in $@
  do
    if [ $(echo $arg | cut -c 1-1) = - ]; then
      options="${options} ${arg}"
    else
      args="${args} ${arg}"
    fi
  done
  echo $options $(basename $0): $args
}

read_bake_file()
{

  bake_file=$HOME/.bake

  if [ -s $bake_file ]; then
    . $bake_file 2>/dev/null
    if [ ! $? -eq 0 ] || [ ! -d $root_dir ]; then
      while true; do
        prompt_echo -n "file '$bake_file' is not readable; fix it [y/N]? "
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
    touch $bake_file
    echo 'root_dir=' >> $bake_file
    . $bake_file 2>/dev/null
  fi
}

bake ()
{

  if [ -z $root_dir ]; then 
    local root_dir
    root_dir=$(pwd)
  fi

  if [ $root_dir != $(pwd) ]; then 
    cd ${root_dir}
  fi

  cd ..

  local base_name=$(basename $root_dir)

  # /foo/bar/ -> foo_bar.1669158229.tar.gz
  # alternative would be 'root_dir=${root_dir//\//_}' and passing '${root_dir:1}' to sed - using UNIX commands for POSIX compliance
  local bak_file=/tmp/$(echo $root_dir | tr / _ | cut -c 2-).$(date +%s).tar.gz

  # '--checkpoint=.500' - show progress of tar cmd
  # https://www.gnu.org/software/tar/manual/tar.html#checkpoints
  tar -zcf $bak_file --totals --checkpoint=.500 $base_name

  if [ $? -eq 0 ]; then  
    prompt_echo "file created: $bak_file"
    exit 0
  fi
}

bake_set ()
{
  local root_dir
  root_dir=$(pwd)
  sed -i "s|\(root_dir=\)\(.*\)|\1${root_dir}|" $bake_file || exit 1
  prompt_echo "root_dir=$root_dir" && exit 0
}

bake_unset ()
{
  sed -i "s/\(root_dir=\)\(.*\)/\1/" $bake_file || exit 1
  read_bake_file
  prompt_echo "root_dir=$root_dir" && exit 0
}

bake_what ()
{
  prompt_echo "root_dir=$root_dir" && exit 0
}

# TODO: 'bake where': read a dir and writes to that dir once

# TODO: 'bake n': 'n' is interval in minutes for creating backups

[ $# -gt 1 ] && exit 1

read_bake_file

case "$1" in
  '')
    bake
    exit 1
    ;;
  set)
    bake_set
    exit 1
    ;;
  unset)
    bake_unset
    exit 1
    ;;
  what)
    bake_what
    exit 1
    ;;
  *)
    prompt_echo 'bake [set|unset|what]'
    exit 1
esac
