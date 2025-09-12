<?php
AFL_INIT(); // Initialize AFL

// Persistent mode
while(AFL_LOOP(100000)) {
        $input = file_get_contents("php://stdin");
        $dom = Dom\XMLDocument::createEmpty();
        $container = $dom->createElement("container");
        AFL_COVERAGE_ON(); // We start AFL coverage from here
                $container->append($dom->createCDATASection($input));
                $container->innerHTML;
        AFL_COVERAGE_OFF(); // We end AFL coverage here
}

?>
