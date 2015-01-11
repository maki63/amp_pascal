UNIT TYPE8;

interface
CONST
 nmax=200; { allowed number of nodes }
 lmax=32;  { allowed number of character in name }
 linlength=250;
 indexmax=9;                   {allowed number of points in flog}
 fm:ARRAY[1..indexmax] OF DOUBLE=(1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0);

 gi_MOD_str='gi';
 gE_MOD_str='gE';
 gF_MOD_str='gF';
 gH_MOD_str='gH';
 gN_MOD_str='gN';
 gx_MOD_val=1.0E-3;

 g_MAT_str='GMAT';

 bmaxdim=10;
 matmaxdim=bmaxdim-1;

 g_T_str='GT';         {prefix for T models}
 max_1over0_value=1.0E+18; {max for 1/sin(tetha)->inf }
 min_num_value=1.0/max_1over0_value;
 tab_str='        ';
TYPE
symb=STRING[lmax];
{ linetype=STRING[linlength]; }
linetype=ANSISTRING;
tmat=ARRAY[1..nmax+1] OF SHORTINT;
cf=ARRAY[1..2,1..nmax+1] OF SHORTINT;

drpt=^DR;
DR=RECORD
    red,imd:DOUBLE;
    drptn:drpt
   END;

listpt=^LIST;
LIST=RECORD
      oneline:linetype;
      lpth,lptt:listpt
     END;

listapt=^LISTA;
LISTA= RECORD
        oneline:linetype;
        lpt:listapt
       END;

listbpt=^LISTB;
LISTB= RECORD
        value:DOUBLE;
        vpt:listbpt
       END;

listcpt=^LISTC;
LISTC= RECORD
        valre, valim :DOUBLE;
        cvpt:listcpt
        END;

varpt=^VARLST;
VARLST=RECORD
        varname:symb;      { name of model }
        line_pt:listapt;
        varnext:varpt;
        case Var_complex:boolean of
        FALSE: ( VVR_HEAD_PT, VVR_TAIL_PT:listbpt );
        TRUE: ( VVC_HEAD_PT, VVC_TAIL_PT:listcpt );
       END;

trimpt=^TRIMLST;
TRIMLST=RECORD
         trimname:symb;   { name of model }
         line_pt:listapt;
         TRIM_HEAD_PT,TRIM_TAIL_PT:listbpt;
         trimnext:trimpt;
        END;

TUN_TYPE=(lin, poly, ratio, exponent, logaritmic);

tunpt=^TUNLST;
TUNLST=RECORD
        tunname:symb;    { name of model }
        tunpara:symb;
        tuntrimpt:trimpt;
        tuntype:TUN_TYPE;
        tunconst,tunvar:DOUBLE;
        line_pt:listapt;
        TUN_HEAD_PT,TUN_TAIL_PT:listbpt;
        tunnext:tunpt
       END;

parpt=^PARLST;
PARLST=RECORD
        parname:symb;      { name of model }
        parcount:integer;  { number of values on the list }
        line_pt:listapt;
        parnext:parpt;
        case PAR_complex:boolean of
        FALSE: ( PVR_HEAD_PT, PVR_TAIL_PT, PVR_CURR_PT:listbpt );
        TRUE:  ( PVC_HEAD_PT, PVC_TAIL_PT, PVC_CURR_PT:listcpt );
       END;

letpt=^LETLST;
LETLST=RECORD
        letname:symb;      { name of model }
        vre:DOUBLE;
        vim:DOUBLE;
        line_pt:listapt;
        complex_flag:boolean;
        letnext:letpt;
       END;

dptr=^D_TYPE;
D_TYPE=RECORD
        CF_PT,drfpt:drpt;
        d:INTEGER;
        dname:symb;
        dcreb,ctb0,ctb:BOOLEAN;
        ddim,lgt,lgt0,csg,csg0:INTEGER;
        wr,kl,ROW0,COL0,ROW,COL:cf;
        RT0,CT0,RT,CT:tmat;
        dnext:dptr
       END;

{ MODEL_DEF - primary component defined by $MOD }

VAR_TYPE=(CONSTANT, VARIABLE, TUNED, GEN, MODEL_DEF, PARAM );
G_TYPE  =(GENUINE, MODEL_PAR, MODEL_ID);


yptr=^YRECTYPE;
YRECTYPE= RECORD
        ya,yb:INTEGER;
        yname:symb;
        yvre:DOUBLE;
        yvim:DOUBLE;
        yvar:VAR_TYPE;
        yref:symb;     { name of model if tuned or var }
        ytunpt:tunpt;
        yvarpt:varpt;
        yparpt:parpt;
        line_pt:listapt;
        ynext:yptr;
       END;

gptr=^GRECTYPE;
GRECTYPE= RECORD
        ga,gb,gc,gd:INTEGER;
        gname:symb;
        gvre:DOUBLE;
        gvim:DOUBLE;
        gtype:G_TYPE;
        gvar:VAR_TYPE;
        gref:symb;                { name of model if tuned or var }
        gtunpt:tunpt;
        gvarpt:varpt;
        gparpt:parpt;
        line_pt:listapt;
        gnext:gptr
       END;

zptr=^ZRECTYPE;
ZRECTYPE= RECORD
        za,zb:INTEGER;
        zvre,zvim:DOUBLE;
        zname:symb;
        zvar:VAR_TYPE;
        line_pt:listapt;
        zref:symb;                { name of model if tuned or var }
        ztunpt:tunpt;
        zvarpt:varpt;
        zparpt:parpt;
        znext:zptr
       END;

rptr=^RRECTYPE;
RRECTYPE= RECORD
        ra,rb:INTEGER;
        rv:DOUBLE;
        rname:symb;
        rvar:VAR_TYPE;
        line_pt:listapt;
        rref:symb;                { name of model if tuned or var }
        rtunpt:tunpt;
        rvarpt:varpt;
        rparpt:parpt;
        mod_fr:double;                { MOD: resonance freq }
        mod_qr:double;                 { MOD: quality factor }
        rnext:rptr
       END;

cptr=^CRECTYPE;
CRECTYPE= RECORD
        ca,cb:INTEGER;
        cv:DOUBLE;
        cname:symb;
        cvar:VAR_TYPE;
        line_pt:listapt;
        cref:symb;                { name of model if tuned or var }
        ctunpt:tunpt;
        cvarpt:varpt;
        cparpt:parpt;
        mod_fr:double;                { MOD: resonance freq }
        mod_qr:double;                 { MOD: quality factor }
        cnext:cptr
       END;

lptr=^LRECTYPE;
LRECTYPE= RECORD
        la,lb,lc:INTEGER;        { la is * node  lc is a HIL - current voltage to controlling node }
        lv:DOUBLE;               { lc = 0 means the HIL was not set }
        lname:symb;              { la node is changed by K }
        lvar:VAR_TYPE;           { lb node is changed by MOD }
        line_pt:listapt;
        lref:symb;               { name of model if tuned or var }
        ltunpt:tunpt;
        lvarpt:varpt;
        lparpt:parpt;
        mod_fr:double;                { MOD: resonance freq }
        mod_qr:double;                 { MOD: quality factor }
        lnext:lptr
       END;

kptr=^KRECTYPE;
KRECTYPE= RECORD
        kv:DOUBLE;
        kname:symb;
        line_pt:listapt;
        k_lname1:symb;                  { name of coupled inductors }
        k_lname2:symb;                  { name of coupled inductors }
        knext:kptr
       END;

aptr=^ARECTYPE;
ARECTYPE= RECORD
        aa,ab,ac,ad:INTEGER;
        aname:symb;
        line_pt:listapt;
        anext:aptr
       END;

SOURCE_TYPE=(GENERIC, AC, NOISE );

vptr=^VRECTYPE;
VRECTYPE= RECORD
        va,vb:INTEGER;
        vname:symb;
        vtype:SOURCE_TYPE;
        line_pt:listapt;
        vref:symb;                { name of model if not generic }
        vnext:vptr
       END;

iptr=^IRECTYPE;
IRECTYPE= RECORD
        ia,ib:INTEGER;
        iname:symb;
        itype:SOURCE_TYPE;
        line_pt:listapt;
        iref:symb;                { name of model if not generic }
        inext:iptr
       END;

PROBE_TYPE=(PROBE_U, PROBE_I, PROBE_Z, PROBE_TU, PROBE_TI, PROBE_TN, PROBE_TM);
PORT_PROBE_TYPE=(L_PORT, M_PORT, NIL_PORT, DEF_PORT);    {L_PORT in nominator, M_PORT in denominator, NIL_PORT don't care}
pptr=^PRECTYPE;
PRECTYPE= RECORD
        pa,pb,pc,pd:INTEGER;
        pname:symb;
        ptype:PROBE_TYPE;
        line_pt:listapt;
        pref:symb;                { name of model if not generic }
        pnext:pptr
       END;

eptr=^ERECTYPE;
ERECTYPE= RECORD
        ea,eb,ec,ed:INTEGER;
        ename:symb;
        ev:DOUBLE;
        line_pt:listapt;
        enext:eptr
       END;

hptr=^HRECTYPE;
HRECTYPE= RECORD
        ha,hb,hc,hd:INTEGER;
        hname:symb;
        hv:DOUBLE;
        line_pt:listapt;
        hnext:hptr
       END;

fptr=^FRECTYPE;
FRECTYPE= RECORD
        fa,fb,fc,fd:INTEGER;
        fname:symb;
        fv:DOUBLE;
        line_pt:listapt;
        fnext:fptr
       END;

nptr=^NRECTYPE;
NRECTYPE= RECORD
        na,nb,nc,nd:INTEGER;
        nname:symb;
        nv:DOUBLE;
        line_pt:listapt;
        nnext:nptr
       END;

tptr=^TRECTYPE;
TRECTYPE= RECORD
        ta,tb,tc:INTEGER;
        tname:symb;
        t_zr:DOUBLE;
        t_td:DOUBLE;
        line_pt:listapt;
        tnext:tptr
       END;

{ For TOOLBOX MODULE }
COMPLEX=RECORD
          Re,Im:DOUBLE;
        END;
COFFMAT_TYPE=ARRAY[1..2,1..matmaxdim+1] OF INTEGER;         { (w+r)(k+l) coffactor elements }
TMAT_TYPE=ARRAY[1..matmaxdim+1] OF INTEGER;                 { transformation matrix }
YMATRIX_TYPE=ARRAY [1..matmaxdim,1..matmaxdim] OF COMPLEX;

ecoffpt=^ELEMCOFF;                                         { elementary row/col coffactor definition }
ELEMCOFF = RECORD
        cs:INTEGER;                                         { change sign }
        lc:INTEGER;                                         { length }
        notapp:BOOLEAN;                                     { TRUE - not applicable - not in order }
        TM: TMAT_TYPE;                                      { transformation matrix }
        x:COFFMAT_TYPE;                                     { operations }
        END;


coffpt=^COFF;                                               { COFF = elementary rows and cols }
COFF = RECORD
         cs:INTEGER;                                        { global change sign   }
         len:INTEGER;
         notapp:BOOLEAN;                                    { TRUE - not applicable - coff does not exist  }
         rows,cols: ELEMCOFF;                               { coffactor operators   }
         D:COMPLEX;                                         { value of coffactor    }
       END;

matrixpt = ^LISTMAT;                                         { ToolBox definition }

{matrixpt = ^LISTMAT;}

LISTMAT= RECORD
        fmat:DOUBLE;
        matcol,matrow:INTEGER;
        ymat:YMATRIX_TYPE;
        next_f_mat_pt:matrixpt;
        END;

MATRIX_TYPE = ( YRI, S1P, S2P, S3P, S4P, S5P, S6P, S7P, S8P, S9P );
MATRIX_TS_FREQ = (  GHz, MHz, KHz, Hz);
MATRIX_TS_PARAM = ( S, Y, Z, H, G);
MATRIX_TS_FORMAT = ( DB, MA, RI);

matptr=^MATRECTYPE;
MATRECTYPE= RECORD
        matname:symb;
        mattypestr:symb;
        matfilestr:string;
        mattype:MATRIX_TYPE;
        mattsfreq:MATRIX_TS_FREQ;
        mattsparam:MATRIX_TS_PARAM;
        mattsformat:MATRIX_TS_FORMAT;
        mattsRref:DOUBLE;
        mat_dim:INTEGER;
        mat_fq_dim:INTEGER;
        MAT_FILE_DATA_PT:matrixpt;        /// file data
        MAT_S_PT:matrixpt;                /// normalized S - RI format
        MAT_Y_PT:matrixpt;                /// converter into Y
        MAT_INTERP_Y_PT:matrixpt;         /// interpolated data
        MAT_VAR_PT:listapt;
        line_pt:listapt;
        matnext:matptr;
       END;


bptr=^BRECTYPE;
BRECTYPE= RECORD
        bname:symb;
        bndim:INTEGER;
        bnodes:ARRAY[1..bmaxdim] OF INTEGER;
        bref:symb;     { name of matrix }
        bmatpt:matptr;
        line_pt:listapt;
        bnext:bptr;
       END;

taskpt=^TASK;
TASK=RECORD
      CDEF_PT:listapt;
      COMD_PT:listapt;
      COFF_PT:dptr;
      FREQ_PT:listbpt;
      VAR_PT:varpt;
      TUN_PT:tunpt;
      TRIM_PT:trimpt;
      PAR_PT:parpt;
      LET_PT:letpt;
      numberMajor:INTEGER;      // assigned in EXTRACT_TASKS 
      numberMiddle:INTEGER;     // changed by SET_PAR_COMP and 
      numberMinor:INTEGER;      // assigned in CREATE_PROBES_TF_TASKS
      task_name:string;
      tpt:taskpt;
    END;

parameterpt=^PARAMETER;
PARAMETER=RECORD
       ps:symb;pv:INTEGER;
       ppt:parameterpt
      END;

devicept=^DEVICE;
DEVICE=RECORD
        devpt:devicept;
        devname:symb;
        nodes:INTEGER;
        liblines:LISTA;
        llpth:listapt;
        parameters:PARAMETER;
        ppth:parameterpt;
     END;

libpt=^LIBR;
LIBR=RECORD
      def:DEVICE;
      defpt:libpt
    END;



raw_data_rec_type = RECORD
      num_of_var:integer;
      num_of_points:integer;
     END;

lists_pt=^LISTS;
LISTS= RECORD
        name_str:ANSISTRING;
        next_name_pt:lists_pt
       END;


raw_point_list_pt_type=^raw_point_list_type;
raw_point_list_type = RECORD
        point:listcpt;
        next_point_pt:raw_point_list_pt_type;
    END;

// the list of points and var_names is one file
// freq is the first variable
// all points in one file have equal size - i.e freq is common
//
raw_file_pt_type=^raw_file_type;
raw_file_type = RECORD
        raw_data_rec:raw_data_rec_type;
        var_list_pt:lists_pt;
        point_list_pt:raw_point_list_pt_type;
        numberMajor:INTEGER;    // all jobs with numberMajor 
        numberMiddle:INTEGER;   // and numberMiddle go to the same file
        task_name:string;
        para_descr:string;
        next_raw_file_pt:raw_file_pt_type;
    END;

implementation
END.
