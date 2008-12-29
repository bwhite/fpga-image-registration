function Hn=fp_compose_h_matrix(H,P)

%- H*P
%-- [    h0*p0+h1*p3,    h0*p1+h1*p4, h0*p2+h1*p5+h2]
%-- [    h3*p0+h4*p3,    h3*p1+h4*p4, h3*p2+h4*p5+h5]
%-- [              0,              0,              1]

fipref('DataTypeOverride','ForceOFF','LoggingMode','on');
%fipref('DataTypeOverride','ScaledDoubles','LoggingMode','on');
input_frac=19;
input_whole=7;
H=fp(H,input_whole,input_frac);
P=fp(P,input_whole,input_frac);

Hn=fp(zeros(3),input_whole,input_frac);
Hn(1,1)=fp(H(1,1)*P(1,1),input_whole,input_frac)+fp(H(1,2)*P(2,1),input_whole,input_frac);
Hn(1,2)=fp(H(1,1)*P(1,2),input_whole,input_frac)+fp(H(1,2)*P(2,2),input_whole,input_frac);
Hn(1,3)=fp(H(1,1)*P(1,3),input_whole,input_frac)+fp(H(1,2)*P(2,3),input_whole,input_frac)+H(1,3);

Hn(2,1)=fp(H(2,1)*P(1,1),input_whole,input_frac)+fp(H(2,2)*P(2,1),input_whole,input_frac);
Hn(2,2)=fp(H(2,1)*P(1,2),input_whole,input_frac)+fp(H(2,2)*P(2,2),input_whole,input_frac);
Hn(2,3)=fp(H(2,1)*P(1,3),input_whole,input_frac)+fp(H(2,2)*P(2,3),input_whole,input_frac)+H(2,3);


function out=fp(val,whole,frac)
out=fi(val,1,1+whole+frac,frac,'MaxProductWordLength',(1+whole+frac)*2,'SumWordLength',(1+whole+frac),'RoundMode','Floor','SumMode','KeepLSB');
