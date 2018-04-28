#ifndef PSB_C_SBASE_
#define PSB_C_SBASE_
#include "psb_c_base.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct PSB_C_SVECTOR {
  void *svector;
} psb_c_svector; 

typedef struct PSB_C_SSPMAT {
  void *sspmat;
} psb_c_sspmat; 


/* dense vectors */
psb_c_svector* psb_c_new_svector();
psb_i_t    psb_c_svect_get_nrows(psb_c_svector *xh);
psb_s_t   *psb_c_svect_get_cpy( psb_c_svector *xh);
psb_i_t    psb_c_svect_f_get_cpy(psb_s_t *v, psb_c_svector *xh);
psb_i_t    psb_c_svect_zero(psb_c_svector *xh);

psb_i_t    psb_c_sgeall(psb_c_svector *xh, psb_c_descriptor *cdh);
psb_i_t    psb_c_sgeins(psb_i_t nz, const psb_l_t *irw, const psb_s_t *val,
		    psb_c_svector *xh, psb_c_descriptor *cdh);
psb_i_t    psb_c_sgeins_add(psb_i_t nz, const psb_l_t *irw, const psb_s_t *val,
			psb_c_svector *xh, psb_c_descriptor *cdh);
psb_i_t    psb_c_sgeasb(psb_c_svector *xh, psb_c_descriptor *cdh);
psb_i_t    psb_c_sgefree(psb_c_svector *xh, psb_c_descriptor *cdh);

/* sparse matrices*/
psb_c_sspmat* psb_c_new_sspmat();
psb_i_t    psb_c_sspall(psb_c_sspmat *mh, psb_c_descriptor *cdh);
psb_i_t    psb_c_sspasb(psb_c_sspmat *mh, psb_c_descriptor *cdh);
psb_i_t    psb_c_sspfree(psb_c_sspmat *mh, psb_c_descriptor *cdh);
psb_i_t    psb_c_sspins(psb_i_t nz, const psb_l_t *irw, const psb_l_t *icl,
			const psb_s_t *val, psb_c_sspmat *mh, psb_c_descriptor *cdh);
psb_i_t    psb_c_smat_get_nrows(psb_c_sspmat *mh);
psb_i_t    psb_c_smat_get_ncols(psb_c_sspmat *mh);

/* psb_i_t    psb_c_sspasb_opt(psb_c_sspmat *mh, psb_c_descriptor *cdh,  */
/* 			const char *afmt, psb_i_t upd, psb_i_t dupl); */
psb_i_t    psb_c_ssprn(psb_c_sspmat *mh, psb_c_descriptor *cdh, _Bool clear);
psb_i_t    psb_c_smat_name_print(psb_c_sspmat *mh, char *name); 

/* psblas computational routines */
psb_s_t psb_c_sgedot(psb_c_svector *xh, psb_c_svector *yh, psb_c_descriptor *cdh);
psb_s_t psb_c_sgenrm2(psb_c_svector *xh, psb_c_descriptor *cdh);
psb_s_t psb_c_sgeamax(psb_c_svector *xh, psb_c_descriptor *cdh);
psb_s_t psb_c_sgeasum(psb_c_svector *xh, psb_c_descriptor *cdh);
psb_s_t psb_c_sspnrmi(psb_c_sspmat *ah, psb_c_descriptor *cdh);
psb_i_t psb_c_sgeaxpby(psb_s_t alpha, psb_c_svector *xh, 
		       psb_s_t beta, psb_c_svector *yh, psb_c_descriptor *cdh);
psb_i_t psb_c_sspmm(psb_s_t alpha, psb_c_sspmat *ah, psb_c_svector *xh, 
		    psb_s_t beta, psb_c_svector *yh, psb_c_descriptor *cdh);
psb_i_t psb_c_sspmm_opt(psb_s_t alpha, psb_c_sspmat *ah, psb_c_svector *xh, 
			psb_s_t beta, psb_c_svector *yh, psb_c_descriptor *cdh,
			char *trans, bool doswap);
psb_i_t psb_c_sspsm(psb_s_t alpha, psb_c_sspmat *th, psb_c_svector *xh, 
		      psb_s_t beta, psb_c_svector *yh, psb_c_descriptor *cdh);
#ifdef __cplusplus
}
#endif  /* __cplusplus */

#endif
