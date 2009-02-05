function h=fp_unscale_h_matrix(h,xb,yb,verbose)
%fipref('DataTypeOverride','ForceOFF','LoggingMode','on');
input_frac=19;
input_whole=7;


h=fp(h,input_whole,input_frac);


xb=fp(xb,input_whole,input_frac);
yb=fp(yb,input_whole,input_frac);   
if verbose
    h=h';
    disp(sprintf('TI:{16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,1}',hex(h(1)),hex(h(2)),hex(h(3)),hex(h(4)),hex(h(5)),hex(h(6)),hex(xb),hex(yb)));
    h=h';
end

h(1,3)=-fp(h(1,1)*xb,input_whole,input_frac)-fp(h(1,2)*yb,input_whole,input_frac)+h(1,3)+xb;
h(2,3)=-fp(h(2,1)*xb,input_whole,input_frac)-fp(h(2,2)*yb,input_whole,input_frac)+h(2,3)+yb;
if verbose
    h=h';
    disp(sprintf('TO:{16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,1}',hex(h(1)),hex(h(2)),hex(h(3)),hex(h(4)),hex(h(5)),hex(h(6))));
    h=h';
end

function out=fp(val,whole,frac)
out=fi(val,1,1+whole+frac,frac,'MaxProductWordLength',(1+whole+frac)*2,'SumWordLength',(1+whole+frac),'RoundMode','Floor','SumMode','KeepLSB');
