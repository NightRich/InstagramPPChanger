#!/bin/bash
DIR="$(cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "$DIR"

while getopts "p:f:l" OPTION 2; /dev/null; do
	case ${OPTION} in
		p)
			PHP_BINARY="$OPTARG"
			;;
		f)
			RUNNER_FILE="$OPTARG"
			;;
		l)
			DO_LOOP="yes"
			;;
		\?)
			break
			;;
	esac
done

if [[ "$PHP_BINARY" == "" ]]; then
	if [[ -f ./bin/php7/bin/php ]]; then
		export PHPRC=""
		PHP_BINARY="./bin/php7/bin/php"
	elif [[ ! -z $(type php) ]]; then
		PHP_BINARY=$(type -p php)
	else
		echo "Couldn't find a working PHP 7 binary, please use the installer."
		exit 1
	fi
fi

if [[ "$RUNNER_FILE" == "" ]]; then
	if [[ -f ./src/Artemis/run.php ]]; then
		RUNNER_FILE="./src/Artemis/run.php"
	else
		echo "src/Artemis/run.php not found"
		exit 1
	fi
fi

LOOPS=0

set +e

if [[ "$DO_LOOP" == "yes" ]]; then
	while true; do
		if [[ ${LOOPS} -gt 0 ]]; then
			echo "Restarted $LOOPS times"
		fi
		"$PHP_BINARY" "$RUNNER_FILE" $@
		echo "To escape the loop, press CTRL+C now. Otherwise, wait 5 seconds for the server to restart."
		echo ""
		sleep 5
		((LOOPS++))
	done
else
	exec "$PHP_BINARY" "$RUNNER_FILE" $@
fi