**php-afltools** is a set of tools to make fuzzing PHP's Zend engine simple and efficient

- Instrument AFL++ directly in PHP code with simple function calls
- fuzz PHP's zend engine, libraries and extensions
- AFL's persistent mode implemented 
- Drop-in extension that works with existing PHP codebases
- FuzzedDataProvider class: Built-in data provider for structured fuzzing of multiple data types

### Example usage
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

# Install

## The easy way - docker

```bash
git clone https://github.com/mumubebe/php-afltools.git
cd php-afltools/
docker build -t afltools .
docker run -it afltools bash

# run an example
cd examples/cdata_sections
chmod +x run.sh && ./run.sh
```

## Manual adding extensions to the PHP source tree 

```bash
PHP_SRC="~/php-src/"

git clone https://github.com/mumubebe/php-afltools.git
mv php-afltools "$PHP_SRC"/ext

cd $PHP_SRC
rm configure && ./buildconf
./configure --enable-afltools # --other-options
make
```


# FuzzedDataProvider class
A helper class for structured consumption of fuzzing input data.
```php
new FuzzedDataProvider(string $data)
```
todo: methods and examples

