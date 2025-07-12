<?php

$f = __DIR__ . '/php/fuzzeddataprovider.php';
if (!file_exists($f)) {
    throw new RuntimeException("file not found: $f");
}

require_once $f;
