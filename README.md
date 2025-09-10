# Adding extensions to the PHP source tree 

```bash
PHP_SRC="~/php-src/"

git clone https://github.com/mumubebe/php-afltools.git
mv php-afltools "$PHP_SRC"/ext

cd $PHP_SRC
rm configure && ./buildconf
./configure --enable-afltools # --other-options
make
```

# Example PHP fuzz script
```php
<?php
AFL_INIT(); // Initialize AFL

// Persistent mode
while(AFL_LOOP(100000)) {
  AFL_COVERAGE_ON(); // We start AFL coverage from here
  @exif_read_data('/tmp/fuzz');
  AFL_COVERAGE_OFF(); // We end AFL coverage here
}

?>
```
