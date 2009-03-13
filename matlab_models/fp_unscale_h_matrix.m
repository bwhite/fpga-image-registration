function h=fp_unscale_h_matrix(h,xb,yb,verbose)
if ~exist('verbose')
    verbose = 0;
end
%fipref('DataTypeOverride','ForceOFF','LoggingMode','on');
input_frac=19;
input_whole=7;
trans_frac=1;
trans_whole=10;
output_frac=19;
output_whole=10;

h=fp(h,input_whole,input_frac);

xb=fp(xb,trans_whole,trans_frac);
yb=fp(yb,trans_whole,trans_frac);

if verbose
    h=h';
    disp(sprintf('TI:{16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,1}',hex(h(1)),hex(h(2)),hex(h(3)),hex(h(4)),hex(h(5)),hex(h(6)),hex(xb)));
    h=h';
end
ho=fpr(h,output_whole,output_frac);
xbo=fpr(xb,output_whole,output_frac);
ybo=fpr(yb,output_whole,output_frac);


h_1_3=ho(1,3)+xbo-fpr(h(1,1)*xb,output_whole,output_frac)-fpr(h(1,2)*yb,output_whole,output_frac);
h_2_3=ho(2,3)+ybo-fpr(h(2,1)*xb,output_whole,output_frac)-fpr(h(2,2)*yb,output_whole,output_frac);
 
h=fpr(h,output_whole,output_frac);
h(1,3)=h_1_3;
h(2,3)=h_2_3;

if verbose
    h=h';
    disp(sprintf('TO:{16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,1}',hex(h(1)),hex(h(2)),hex(h(3)),hex(h(4)),hex(h(5)),hex(h(6))));
    h=h';
end

function out=fp(val,whole,frac)
out=fi(val,1,1+whole+frac,frac,'RoundMode','Floor','SumMode','KeepLSB');

function out=fpr(val,whole,frac)
out=fi(val,1,1+whole+frac,frac,'RoundMode','Floor','SumMode','KeepLSB','SumWordLength',1+whole+frac);
