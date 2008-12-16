function [c]=fp_signed_norm_mult(a,b,verbose)
if ~exist('verbose')
    verbose=0;
end
coord_word=27;
coord_whole=0;
a=fi(a,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Floor');
b=fi(b,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Floor');
c=fi(a*b,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Floor');
if verbose==1
    disp(sprintf('TI:{1,16#%s#,16#%s#}',hex(a),hex(b)))
    disp(sprintf('TO:{16#%s#,1}',hex(c)))
end
