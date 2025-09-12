#!/bin/bash
afl-fuzz -i corpus/ -o out/ -- /php-src/sapi/cli/php fuzz.php
