/* alloc and free header definitions
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,14-oct-85,Creation. This may not go out."
#pragma REVISED "zap,20-oct-86,revised for near and far"
#pragma REVISED "zap, 3-aug-87,Remove near/farness. They have to coexist."
#pragma REVISED "zap,11-sep-87,remove add_to_ptr() macro"
#endif

#ifndef __alloch

#include <dos.h>

struct ffree_list_item{
  struct ffree_list_item far *next;
  unsigned long length;
};

struct nfree_list_item{
  struct nfree_list_item near *next;
  unsigned short length;
};

#define _FREE_LIST_SIZE 20
#define FHN_SIZE sizeof(struct nfree_list_item)
#define FHF_SIZE sizeof(struct ffree_list_item)
#define MIN_FALLOC			4
#define MIN_NALLOC			2

void _nmerge_free_lists(void);
int _nmerge_free_blocks(struct nfree_list_item near *);
struct nfree_list_item near *_nmalloc_find(struct nfree_list_item near * ,
           unsigned );
struct nfree_list_item near *_nmalloc_take(struct nfree_list_item near * ,
           unsigned );

void _fmerge_free_lists(void);
int _fmerge_free_blocks(struct ffree_list_item far *);
struct ffree_list_item far *_fmalloc_find(struct ffree_list_item far * ,
           unsigned );
struct ffree_list_item far *_fmalloc_take(struct ffree_list_item far * ,
           unsigned );

#define __alloch
#endif  /* __alloch */

