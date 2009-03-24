whole=8;
frac=19;
sA=fi(bitsra(A,8),1,1+whole+frac,frac,'MaxProductWordLength',(1+whole+frac)*2,'SumWordLength',(1+whole+frac),'RoundMode','Floor','SumMode','KeepLSB')
sb=fi(bitsra(b,8),1,1+whole+frac,frac,'MaxProductWordLength',(1+whole+frac)*2,'SumWordLength',(1+whole+frac),'RoundMode','Floor','SumMode','KeepLSB')
h=gauss_elim_fixed(sA,sb)
H=[h(2)+1 h(3) h(1);h(5) h(6)+1 h(4); 0 0 1];
hsc=fp_unscale_h_matrix(H,320,240)