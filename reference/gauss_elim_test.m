function gauss_elim_test(directory)
dir_list=dir(directory);
dir_list=dir_list(3:length(dir_list)); % Remove . and ..
max_error=0;
tot_error=0;
warning off fi:underflow
fipref('DataTypeOverride','ScaledDoubles','LoggingMode','on');
aug=[];
for f=1:length(dir_list)
    load(strcat(directory,'/',dir_list(f).name));
    x_fixed=gauss_elim_fixed(A,b);
    x_fixed_d=double(x_fixed);
    x_float=A\b;%gauss_elim_float(A,b);
    abs_error=abs(x_fixed_d-x_float);
    max_error=max([abs_error(:)',max_error]);
    tot_error=tot_error+sum(abs(x_fixed_d-x_float));
    disp(f)
end
disp('MaxError')
disp(max_error)
disp('AvgError')
disp(tot_error/(6*length(dir_list)))
