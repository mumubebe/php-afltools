/* afltools extension for PHP */

#ifndef PHP_AFLTOOLS_H
# define PHP_AFLTOOLS_H

extern zend_module_entry afltools_module_entry;
# define phpext_afltools_ptr &afltools_module_entry

# define PHP_AFLTOOLS_VERSION "0.1.0"

# if defined(ZTS) && defined(COMPILE_DL_AFLTOOLS)
ZEND_TSRMLS_CACHE_EXTERN()
# endif

#endif	/* PHP_AFLTOOLS_H */
