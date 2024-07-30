#!/usr/coreutils/bin/bash

export PROGNAME="$0"
export DELAY=300
export LIMIT=15
export COUNT=32767
export DEBUG=0

Usage() {
	echo "usage: $PROGNAME [--limit mins] [--count num] [--delay secs] name-pattern"
	echo
	echo "example: $PROGNAME '(quic_multistream_test|threadstest)'"
	echo "example: $PROGNAME --limit 10 '(quic_multistream_test|threadstest)'"
	exit 1
}

if [ "$1" = "" ]; then
	Usage
fi

while [ ${1:0:2} = "--" ]; do
	if [ $DEBUG -ne 0 ]; then
		echo checking arg $1
	fi
	case $1 in
		--debug)
			shift
			DEBUG=1
			;;
		--limit)
			shift
			if [ "$1" = "" ]; then
				Usage
			fi
			LIMIT=$1
			shift
			;;
		--delay)
			shift
			if [ "$1" = "" ]; then
				Usage
			fi
			DELAY=$1
			shift
			;;
		--count)
			shift
			if [ "$1" = "" ]; then
				Usage
			fi
			COUNT=$1
			shift
			;;
		*)
			Usage
			;;
	esac
done

while [ $COUNT -gt 0 ]; do
	ps | \
	grep -E "$1" | \
	sed -r 's/^ +//' | \
	sed -r 's/ [^ ]+ +([0-9][0-9])\:[0-9][0-9] / 00 \1 /' | \
	sed -r 's/ [^ ]+ +([0-9][0-9])\:([0-9][0-9])\:[0-9][0-9] / \1 \2 /' | \
	while read CMD; do
		pid=`echo $CMD | sed -r 's/^([0-9]+) .*/\1/'`
		hours=`echo $CMD | sed -r 's/^[0-9]+ ([0-9]{2}) .*/\1/'`
		minutes=`echo $CMD | sed -r 's/^[0-9]+ [0-9]{2} ([0-9]{2}) .*/\1/'`
		if [ $DEBUG -ne 0 ]; then
			echo "checking $CMD"
		fi
		if [ $hours -gt 0 -o $minutes -gt $LIMIT ]; then
			if [ $DEBUG -ne 0 ]; then
				echo "killing $pid for exceeding $LIMIT"
			fi
			echo kill -9 $pid
			kill -9 $pid
		fi
	done
	COUNT=$((COUNT - 1))
	if [ $DEBUG -ne 0 ]; then
		echo $COUNT remaining
	fi
	if [ $COUNT -gt 0 ]; then
		sleep $DELAY
	fi
done
