UNIT VAREXT8;
interface
USES TYPE8;
CONST
 version='     AMP 8_D     ';
 asterix='******************************';
VAR

 transfer,loaded:BOOLEAN;   {* compute TF,TF is in form Yo*DL/DM          *}
 probable:BOOLEAN;          {* solution of YxYn is O'K                    *}
 gen_sens:BOOLEAN;          {* sensitivities are for generator            *}
 deltaL,LCOF,deltaM,MCOF,Y0:STRING;
 {* $TF Y0*D(a+d)(b+c)/D(a+d)(a+d)                                        *}
 {* deltaL=D(a+d)(b+c)      deltaM=D(a+d)(a+d)                            *}
 {* LCOF=(a+d)(b+c)         MCOF=(a+d)(a+d)                               *}
 TFmp_PT:drpt;              {* values of TF module and phase              *}
 TFri_PT:drpt;              {* values of TF re an im                      *}
 Y0_PT:yptr;                {* pointer to YO-load                         *}
 generator:BOOLEAN;         {* $GR $GS                                    *}
 YxYn_PT:drpt;              {* values of result of nonlinear equation set *}
 SrSi_PT:drpt;              {* values of sensitivities                    *}
 Ysens_HEAD_PT:listcpt;     {* complex admittance values for TF_SENS      *}
 Ysgen_HEAD_PT:listcpt;     {* complex admittance values for NEWTON       *}
 SxrSxi_PT:drpt;            {* reference values of sens for $GR & dist    *}
 ZM_PT:drpt;                {* store result TF first disto pass           *}
 ZMh_PT:drpt;               {* store result TF harmonics second disto pass*}
 VIh_PT:drpt;               {* store result TF=V/I harmonics third disto p*}
 AH_PT:listbpt;             {* store result of disto analysis             *}
 FB_PT,FH_PT:listbpt;       {* base freqency and harmonics  lists         *}
 invertrx,invertrn:BOOLEAN; {* Rx or Rn marker                            *}
 Yx_symb,Yn_symb,eps_symb:STRING;
 YXCOF,YNCOF:STRING;
 Yx_ptr, Yn_ptr:yptr;
 Rx_ptr, Rn_ptr:rptr;
 Gx_ptr, Gn_ptr:gptr;
 {* Yxs-Yx_name    yxprefix=Yx_name ax bx cx dx   YXCOF=(bx+cx)(ax+dx)    *}
 {* Yns-Yn_name    ynprefix=Yn_name an bn cn dn   YNCOF=(bn+cn)(an+dn)    *}
 yxnc,yxna,yxnb,yxnd,ynnc,ynna,ynnb,ynnd:INTEGER;
 R_GEN_lineptr:listapt;
 S_GEN_lineptr:listapt;
 disto:BOOLEAN;          {* analysis of nonlinear distortion for GR       *}
 harmonics:INTEGER;      {* number of harmonics                           *}
 vnb,vnc:INTEGER;        {* voltage node form disto measure               *}
 disto_pass:INTEGER;     {* counter of main loop passes after             *}
 sensor:BOOLEAN;         {* generator with sensors GS                     *}
 itrmax:INTEGER;         {* max allowed number of iterations in NEWTON    *}
 accuracy:DOUBLE;        {* accuracy of the solution                      *}
 NS_PT:drpt;             {* ReTF and ImTF accepted as a result            *}
 SS_PT:drpt;             {* STFre &  STFim accepted for succesive sensors *}
 eYn_PT:drpt;            {* Results of SCONV analysis                     *}
 
 mcadfilenum:INTEGER;    {* MCAD *mXX file extension number                    *}
 mcaddirfile_flag:BOOLEAN;

 mcad_numberMajor:INTEGER;      {* trace task major - change should result in new values listing *}
 mcad_numberMiddle:INTEGER;     {* trace task middle - change should result in new values listing *}

 mcad_values_flag:BOOLEAN;
 valfilenum:INTEGER;    {* MCAD VALUES *mvXX file extension number    *}
 valdirfile_flag:BOOLEAN;

 probes_flag:BOOLEAN;
 PROBES_TF_PT:listapt;

 TF_name:STRING;             //* change of type  - TF_name:STRING[linlength];
 EXPANDED_COMP_PT:listapt;     { comp generated by  EFH + T  }
 EXTENDED_COMP_PT:listapt;  { comp generated by  MOD + K  }

 MAT_PT:matptr;
 MAT_COMP_PT:listapt;
 MAT_COMM_FREQ_PT:listbpt;          // not MAT_F_PT
 format_dB_flag, format_MP_flag, format_RI_flag: BOOLEAN;
 check_nodes:array[1..nmax+1] of INTEGER;
 raw:BOOLEAN;
 RAW_LIST_PT:raw_file_pt_type; // this is pointer to whole list of files
 RAW_FILE_PT:raw_file_pt_type; // this is a pointer to current file list

implementation
END.
