#!/bin/sh

readonly bake_file="${HOME}/.bake"

create_bake_file ()
{
  cat << 'EOF' > "$bake_file"
# bake configuration file
# see 'bake help' for info

root_dir=
EOF
}

read_bake_file ()
{
  if [ -s "$bake_file" ]; then
    if ! . "$bake_file"; then
      while true
      do
        printf 'bake: file %s not readable; fix it [y/N]? ' "$bake_file"
        read erase
        case "$erase" in
          Y|y|YY|yy)
            create_bake_file
            exit 0
            ;;
          N|n|NN|nn|'')
            exit 1
            ;;
        esac
      done
    elif [ ! -d "$root_dir" ] && [ "$root_dir" != '' ]; then
      print 'bake: "%s" is not a dir' "$root_dir"
      exit 1
    fi
  else
    create_bake_file
    . $bake_file
  fi
}

create_backup ()
{

  local file_name bak_file dir

  if [ "$1" != '' ] && [ ! -d "$1" ]; then
   printf '"%s" is not a directory' "$1"
  fi 

  [ -z "$1" ] && dir='/tmp' || dir="$(dirname $1)"/"$(basename $1)"

  [ -z "$root_dir" ] && root_dir="$(pwd)"
  [ "$root_dir" != "$(pwd)" ] && cd "${root_dir}"

  cd ..

  file_name="$(echo $root_dir | tr / _ | cut -c 2-)"."$(date +%s)".tar.gz
  bak_file="${dir}/$file_name"

  if tar -zc --totals --checkpoint=.500 "$(basename $root_dir)" > "$bak_file"; then
    printf 'bake: file created: %s\n' "$bak_file"
    exit 0
  else
    exit 1
  fi
}

if [ $# -gt 1 ]; then
  printf 'bake [set|unset|what]\n'
  exit 1
fi

case "$1" in
  '')
    create_backup
    exit 1
    ;;
  set)
    root_dir="$(pwd)"
    sed -i "s|\(root_dir=\)\(.*\)|\1${root_dir}|" "$bake_file" || exit 1
    printf 'root_dir=%s\n' "$root_dir" && exit 0
    exit 1
    ;;
  unset)
    sed -i "s/\(root_dir=\)\(.*\)/\1/" "$bake_file" || exit 1
    read_bake_file
    printf 'root_dir=%s\n' "$root_dir" && exit 0
    exit 1
    ;;
  what)
    read_bake_file
    printf 'root_dir=%s\n' "$root_dir" && exit 0
    exit 1
    ;;
  where)
    while :
    do
      printf '(q|Q for quit): '
      read dir
      if [ "$dir" = 'q' ] || [ "$dir" = 'Q' ] || [ ! -d "$dir" ]; then
        exit 1
      else
        read_bake_file
        create_backup "$dir"
        exit 1
      fi
    done
    exit 1
    ;;
  help)
    cat << EOF
usage: bake [set|unset|what|where]
'bake' creates backups on Linux (POSIX compliant, may work with Mac), on /tmp by default. 'bake set' sets current dir as the root dir for backup.
EOF
    exit 0
    ;;
  *)
    printf 'bake [set|unset|what|where]\n'
    exit 1
esac
