/* ====================================================================== */
/* Module: <$module.name$> */
/* ====================================================================== */

<$header : join(\n\n)$>
<$if concat(ellipsis)$>#include <stdarg.h>

<$endif$>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/err.h>

#include <kedr/core/kedr.h>
#include <kedr/leak_check/leak_check.h>

MODULE_AUTHOR("<$module.author$>");
MODULE_LICENSE("GPL");
/* ====================================================================== */

/* Replacement functions
 * 
 * [NB] Each deallocation should be processed in a replacement function
 * BEFORE calling the target function.
 * Each allocation should be processed AFTER the call to the target 
 * function.
 * This allows to avoid some problems on multiprocessor systems. As soon
 * as a memory block is freed, it may become the result of a new allocation
 * made by a thread on another processor. If a deallocation is processed 
 * after it has actually been done, a race condition could happen because 
 * another thread could break in during that gap. */
/* ====================================================================== */

<$block : join(\n)$>
/* ====================================================================== */

/* Names and addresses of the functions of interest */
static struct kedr_pre_pair pre_pairs[] =
{
<$prePair: join()$>
	{
		.orig = NULL
	}
};

static struct kedr_post_pair post_pairs[] =
{
<$postPair: join()$>
	{
		.orig = NULL
	}
};

static struct kedr_payload payload = {
	.mod                    = THIS_MODULE,

	.pre_pairs              = pre_pairs,
	.post_pairs             = post_pairs,
};
/* ====================================================================== */

extern int functions_support_register(void);
extern void functions_support_unregister(void);

static void __exit
<$module.name$>_cleanup_module(void)
{
	kedr_payload_unregister(&payload);
	functions_support_unregister();

	KEDR_MSG("[<$module.name$>] Cleanup complete\n");
}

static int __init
<$module.name$>_init_module(void)
{
	int ret = 0;
	KEDR_MSG("[<$module.name$>] Initializing\n");
	
	ret = functions_support_register();
	if(ret != 0)
		goto fail_supp;

	ret = kedr_payload_register(&payload);
	if (ret != 0) 
		goto fail_reg;
  
	return 0;

fail_reg:
	functions_support_unregister();
fail_supp:
	return ret;
}

module_init(<$module.name$>_init_module);
module_exit(<$module.name$>_cleanup_module);
/* ====================================================================== */
