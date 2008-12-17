function c=fp_gauss_elim_divider(a,b,verbose)
if ~exist('verbose')
    verbose=0;
end
div_frac=19;
div_whole=7;
a=fpr(a,div_whole,div_frac);
b=fpr(b,div_whole,div_frac);
c=fp(divide(fpt(div_whole,div_frac),a,b),div_whole,div_frac);

if verbose
    disp(sprintf('TI:{1,16#%s#,16#%s#}',hex(a),hex(b)))
    disp(sprintf('TO:{16#%s#,0,1}',hex(c)))
end

function out=fp(val,whole,frac)
out=fi(val,1,1+whole+frac,frac,'MaxProductWordLength',(1+whole+frac)*2,'MaxSumWordLength',(1+whole+frac)+3,'RoundMode','Floor');

function out=fpr(val,whole,frac)
out=fi(val,1,1+whole+frac,frac,'MaxProductWordLength',(1+whole+frac)*2,'MaxSumWordLength',(1+whole+frac)+3,'RoundMode','Round');

function out=fpt(whole,frac)
out=numerictype('Signed',true,'WordLength',whole+frac+1,'FractionLength',frac);