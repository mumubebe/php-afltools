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
