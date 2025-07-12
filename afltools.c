/* afltools extension for PHP */

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include "php.h"
#include "ext/standard/info.h"
#include "php_afltools.h"
#include "afltools_arginfo.h"

extern void __afl_coverage_on(void);
extern void __afl_coverage_off(void);
extern void __afl_coverage_discard(void);
extern void __afl_coverage_skip(void);

/* Empty macros if AFL is not installed */
#ifndef __AFL_COVERAGE
#define __AFL_COVERAGE()
#endif

#ifndef __AFL_COVERAGE_START_OFF
#define __AFL_COVERAGE_START_OFF()
#endif

#ifndef __AFL_INIT
#define __AFL_INIT()
#endif

#ifndef __AFL_COVERAGE_ON
#define __AFL_COVERAGE_ON()
#endif

#ifndef __AFL_COVERAGE_OFF
#define __AFL_COVERAGE_OFF()
#endif

/* Ignore loop, just return 1 once */
#ifndef __AFL_LOOP
#define __AFL_LOOP(i)            \
    ({                           \
        static int once = 1;     \
        int result = once;       \
        once = 0;                \
        result;                  \
    })
#endif

__AFL_COVERAGE();
__AFL_COVERAGE_START_OFF();

/* For compatibility with older PHP versions */
#ifndef ZEND_PARSE_PARAMETERS_NONE
#define ZEND_PARSE_PARAMETERS_NONE() \
	ZEND_PARSE_PARAMETERS_START(0, 0) \
	ZEND_PARSE_PARAMETERS_END()
#endif

PHP_FUNCTION(AFL_INIT)
{
	ZEND_PARSE_PARAMETERS_NONE();
	__AFL_INIT();
}


PHP_FUNCTION(AFL_COVERAGE_ON)
{
	ZEND_PARSE_PARAMETERS_NONE();
	__AFL_COVERAGE_ON();
}

PHP_FUNCTION(AFL_COVERAGE_OFF)
{
	ZEND_PARSE_PARAMETERS_NONE();
	__AFL_COVERAGE_OFF();
}

PHP_FUNCTION(AFL_LOOP)
{
	zend_long max_cnt;

	ZEND_PARSE_PARAMETERS_START(1, 1)
		Z_PARAM_LONG(max_cnt)
	ZEND_PARSE_PARAMETERS_END();
	
	RETURN_LONG(__AFL_LOOP((int) max_cnt));
}

/* A test function with three parameters (bool, int, string) */
PHP_FUNCTION(test_three_arg_fuzz)
{
    zend_bool flag;
    zend_long number;
    char *input = NULL;
    size_t input_len;

    // Parse parameters: 'b' = bool, 'l' = long (int), 's' = string
    if (zend_parse_parameters(ZEND_NUM_ARGS(), "bls", &flag, &number, &input, &input_len) == FAILURE) {
        RETURN_FALSE;
    }

    // Check if inputs match the trigger conditions
    if (flag == 1 && number == 1337 && input_len >= 7) {
        if (input[0] == 'C')
        if (input[1] == 'R')
        if (input[2] == 'A')
        if (input[3] == 'S')
        if (input[4] == 'H')
        if (input[5] == 'M')
        if (input[6] == 'E') {
            // CRASH: NULL pointer dereference
            volatile char *p = NULL;
            *p = 'X';
        }
    }
}

/* A test vulnerable function */
PHP_FUNCTION(test_one_arg_fuzz)
{
    char *input = NULL;
    size_t input_len;

    if (zend_parse_parameters(ZEND_NUM_ARGS(), "s", &input, &input_len) == FAILURE) {
        RETURN_FALSE;
    }

    // Chain of conditions — crash only if the sequence is exactly "TRIGGERME"
    if (input_len >= 9) {
        if (input[0] == 'T')
        if (input[1] == 'R')
        if (input[2] == 'I')
        if (input[3] == 'G')
        if (input[4] == 'G')
        if (input[5] == 'E')
        if (input[6] == 'R')
        if (input[7] == 'M')
        if (input[8] == 'E') {
            // CRASH: NULL pointer dereference
            volatile char *p = NULL;
            *p = 'X';
        }
    }
}


PHP_RINIT_FUNCTION(afltools)
{
#if defined(ZTS) && defined(COMPILE_DL_AFLTOOLS)
	ZEND_TSRMLS_CACHE_UPDATE();
#endif

	return SUCCESS;
}

PHP_MINFO_FUNCTION(afltools)
{
	php_info_print_table_start();
	php_info_print_table_row(2, "afltools support", "enabled");
	php_info_print_table_end();
}

zend_module_entry afltools_module_entry = {
	STANDARD_MODULE_HEADER,
	"afltools",					/* Extension name */
	ext_functions,					/* zend_function_entry */
	NULL,							/* PHP_MINIT - Module initialization */
	NULL,							/* PHP_MSHUTDOWN - Module shutdown */
	PHP_RINIT(afltools),			/* PHP_RINIT - Request initialization */
	NULL,							/* PHP_RSHUTDOWN - Request shutdown */
	PHP_MINFO(afltools),			/* PHP_MINFO - Module info */
	PHP_AFLTOOLS_VERSION,		/* Version */
	STANDARD_MODULE_PROPERTIES
};

#ifdef COMPILE_DL_AFLTOOLS
# ifdef ZTS
ZEND_TSRMLS_CACHE_DEFINE()
# endif
ZEND_GET_MODULE(afltools)
#endif
