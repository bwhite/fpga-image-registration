fipref('DataTypeOverride','ForceOFF','LoggingMode','on');
warning off fi:underflow
for i=1:100
    a=(2*(rand()-.5))*2^7;
    b=(2*(rand()-.5))*2^7;
    fp_gauss_elim_divider(a,b,1);
end
