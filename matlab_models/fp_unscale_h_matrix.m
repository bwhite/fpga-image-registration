function h=fp_unscale_h_matrix(h,xb,yb)
fipref('DataTypeOverride','ForceOFF','LoggingMode','on');
input_frac=19;
input_whole=7;

h=fp(h,input_whole,input_frac);
xb=fp(xb,input_whole,input_frac);
yb=fp(yb,input_whole,input_frac);   

h(1,3)=-fp(h(1,1)*xb,input_whole,input_frac)-fp(h(1,2)*yb,input_whole,input_frac)+h(1,3)+xb;
h(2,3)=-fp(h(2,1)*xb,input_whole,input_frac)-fp(h(2,2)*yb,input_whole,input_frac)+h(2,3)+yb;

function out=fp(val,whole,frac)
out=fi(val,1,1+whole+frac,frac,'MaxProductWordLength',(1+whole+frac)*2,'SumWordLength',(1+whole+frac),'RoundMode','Floor','SumMode','KeepLSB');
