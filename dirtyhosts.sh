#!/bin/bash
set -e
set -x

HOSTSFILE="hosts.local"
AUTO_WWW=true

echo_status() {
  echo $(grep "^#dirty_status:" "$HOSTSFILE"|cut -d" " -f2)
}

usage() {
  echo "Usage: $(basename $0) OPTION DOMAIN"
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
    if ! sed -i '' "/$d\ #dirty/d" "$HOSTSFILE"
    then
      exit 1
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

STATUS=$(echo_status)

[[ $STATUS = on || $STATUS = off ]] || { echo "Status error"; exit 1; }

[[ $# = 0 ]] && { echo "Status: $STATUS"; exit 0; }

[[ $# = 2 ]] && { ACTION="$1"; DOMAIN="$2"; } || { usage; exit 1; }

exit 4


_toggle2
exit 4

_toggle
exit 4

if [[ $(id -u) = 0 ]]
then
  echo "rooooooot"
  exit 1
fi

#we want 2 parameters
if [[ ! $# = 2 ]]
then
  usage
  exit 1
fi

ACTION="$1"

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
