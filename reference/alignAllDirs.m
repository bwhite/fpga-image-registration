function alignAllDirs(directory)
directory=strcat(directory,'/');
dir_list=dir(directory);
mkdir('results')
for i=1:length(dir_list)
    if dir_list(i).isdir ~= 1 || strcmp(dir_list(i).name,'..') || strcmp(dir_list(i).name,'.')
        continue
    end
    [ssd_error, overlap_pct, homographies,files,file_directory]=alignImagesDir(strcat(directory,dir_list(i).name));
    saveAlignment(strcat('results/',dir_list(i).name,'.mat'),ssd_error, overlap_pct, homographies,files,file_directory)
end