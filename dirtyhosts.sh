#!/bin/bash
set -e
set -x

[[ -f $HOME/.dirtyhostsrc ]] && . $HOME/.dirtyhostsrc

usage() {
  echo "Usage: $(basename $0) OPTION DOMAIN"
  exit 0
}

#dirty_status() {
#  dirty_status_line=$(grep '^#dirty_status' $HOSTSFILE)
#  local status=$(echo $dirty_status_line | cut -d" " -f2)
#  echo $status
#}

_add() {
  _host="$1"
  for d in $_host
  do
    if ! echo "127.0.0.1 "$d" #dirty" >> "$HOSTSFILE"
    then
      exit 1
    fi
  done
}

_del() {
  _host="$1"
  for d in $_host
  do
    if [[ $LINUX_SED = true ]]
    then
      if ! sed -i "/$d\ #dirty/d" "$HOSTSFILE"
      then
        exit 1
      fi
    else
      if ! sed -i '' "/$d\ #dirty/d" "$HOSTSFILE"
      then
        exit 1
      fi
    fi
  done
}

_toggle2() {
  dirty_status_line=$(grep '^#dirty_status' $HOSTSFILE)
  local status=$(echo $dirty_status_line | cut -d" " -f2)
  if echo "$status"| grep -q 'active$'
  then
    echo  active
  else
    echo inactive
  fi

}
_toggle() {
  while read -r line
  do
    if echo $line | grep -q '#dirty$'
    then
      echo $line
    fi
  done < $HOSTSFILE
}



STATUS=$(grep "^#dirty_status:" "$HOSTSFILE"|cut -d" " -f2)

[[ $STATUS = on || $STATUS = off ]] || { echo "Status error"; exit 1; }

[[ $# = 0 ]] && { echo "Status: $STATUS"; exit 0; }

[[ $# = 2 ]] && { ACTION="$1"; DOMAIN="$2"; } || { usage; exit 1; }


if [[ $(id -u) = 0 ]]
then
  echo "rooooooot"
  exit 1
fi



if [[ $AUTO_WWW = true ]]
then
  DOMAIN="$2 www.$2"
else
  DOMAIN="$2"
fi


case $ACTION in
  add)
    _add "$DOMAIN" || exit 1
  ;;
  del)
    _del "$DOMAIN" || exit 1
  ;;
esac

exit 0
