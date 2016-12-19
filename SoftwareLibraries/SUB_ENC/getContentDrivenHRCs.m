
%% ---------------------------------------------------------
% This function is used to select HRCs from the large-scal database. In
% fact, this function select the HRCs that behave differently with 
% different source contents. 
%
% It is an implementation of the algorithm that is in the following paper: 
% [The Paper]
%
% For more info and bugs reporting, please contact, Ahmed Aldahdooh,
% University of Nantes, (ahmed.aldahdooh@univ-nantes.fr)
%
% The inputs are:
%   -DistortionCSV: it is a distortion matrix MxN: M represents the total
%   set of the HRCs and N represents the number of source contents
%   -BitrateCSV: it is a bitrate matrix MxN: M represents the total
%   set of the HRCs and N represents the number of source contents
%
% The output:
%   -selected_idx: the indices of (M), i.e. the selected HRCs
%% ---------------------------------------------------------
function [selected_idx] = getContentDrivenHRCs(DistortionCSV, BitrateCSV)

%Inputs
[dataPSNR, txtHRCsPSNR, ~] = xlsread(DistortionCSV);
txtHRCsPSNR = txtHRCsPSNR(2:end,1);
[dataRate, txtHRCsRate, ~] = xlsread(BitrateCSV);
txtHRCsRate = txtHRCsRate(2:end,1);
src = {'src01' 'src02' 'src03' 'src04' 'src05' 'src06' 'src07' 'src08' 'src09' 'src10'};
k=17; %number of cluster --- 20 -- > 44,  17 --> 30, 15 --> 28, 12 --> 20

%initialize variables
rankRate = zeros(size(dataPSNR, 1),numel(src));
rankPSNR = zeros(size(dataPSNR, 1),numel(src));

for i=1:numel(src)
    [~,sort_index_Rate] = sort(log(dataRate(:,i)), 'descend');
    [~,sort_index_PSNR] = sort(dataPSNR(:,i));
    
    %ranking
    for j=1:numel(dataPSNR(:,i))
        idx1 = find(sort_index_Rate==j);
        idx2 = find(sort_index_PSNR==j);
        rankRate(j,i) = idx1;
        rankPSNR(j,i) = idx2;
    end
end

%do clustering
dataRank = sqrt(rankPSNR.^2+rankRate.^2);
all_rank_psnr = reshape(rankPSNR, [], 1);
all_rank_rate = reshape(rankRate, [], 1);
all_rank = [all_rank_rate, all_rank_psnr];
[idx,~,~,~] = kmeans(all_rank, k, 'Distance', 'sqeuclidean', 'MaxIter',10000, 'Replicates',100);
all_clsHRC = idx;
clsHRC = reshape(all_clsHRC, [], 10);

%group cluster due to the behavior 
cluster_dist_per_hrc = zeros(size(clsHRC,1),7);
for hrc = 1 : size(cluster_dist_per_hrc,1)
    sort_cluster_per_hrc = sort(unique(clsHRC(hrc,:)));
    cluster_dist_per_hrc(hrc,:) = [sort_cluster_per_hrc zeros(1, 7-numel(sort_cluster_per_hrc))];
end

[clsHRC_unique,~,ic] = unique(cluster_dist_per_hrc, 'rows');

% statistics
statistics_per_hrc = zeros(size(clsHRC_unique,1),5);
for uni_hrc = 1 : size(clsHRC_unique,1)
    statistics_per_hrc(uni_hrc,1) = sum(ic==uni_hrc);
    statistics_per_hrc(uni_hrc,2) = sum(ic==uni_hrc)/size(clsHRC,1);
    statistics_per_hrc(uni_hrc,3) = (numel(unique(clsHRC_unique(uni_hrc,:)))-1)/k;
    
    idx_hrcs = ic==uni_hrc;
    rank_data_hrc = dataRank(idx_hrcs,:);
    statistics_per_hrc(uni_hrc,4) = std(rank_data_hrc(:));
    statistics_per_hrc(uni_hrc,5) = statistics_per_hrc(uni_hrc,3)*statistics_per_hrc(uni_hrc,4);
end

%from each unique hrc group
selected_idx = zeros(size(clsHRC_unique,1),1);
selected_idx_txt = cell(size(clsHRC_unique,1),1);
for hrc_g = 1:size(clsHRC_unique,1)
    %get hrcs that share the same unique group
    idx_hrc_g = find(ic==hrc_g);
    %select the one with highest std
    std_hrc_g = std(dataRank(idx_hrc_g,:), 0,2);
    [~, max_idx_hrc_g] = max(std_hrc_g);
    
    selected_idx(hrc_g) = idx_hrc_g(max_idx_hrc_g);
    selected_idx_txt(hrc_g) = txtHRCsPSNR(selected_idx(hrc_g));
end

%get the parameter of each hrc
%get file name of all selected hrcs per source
fid = fopen(['hrc_content_driven'  '.txt'], 'w');
fid2 = fopen(['hrc_content_driven' '_parameters.csv'], 'w');

for m=1:numel(selected_idx) %for each hrc
    fprintf(fid, '\n%s :: %d\n', 'HRC', m);
    
    txt_idx = selected_idx(m);
    txt_hrc = txtHRCsRate(txt_idx,1);
    fprintf(fid, '%s\n', [txt_hrc{:}]);
    
    %get parameters of selected HRCS
    %<CLUSTER> ---> <GOPTYPESIZE>_<RATECONTROL>_<REFRESH>_<INTRAPERIOD>_<SEARCHRANGE>_<BITDEPTH>_<SLICEARGUMENT>
    txt_hrc_split = strsplit(txt_hrc{:}, '_');
    GOPTYPESIZE = txt_hrc_split(2);
    RATECONTROL = txt_hrc_split(3);
    REFRESH = txt_hrc_split(4);
    INTRAPERIOD = txt_hrc_split(5);
    SEARCHRANGE = txt_hrc_split(6);
    BITDEPTH = txt_hrc_split(7);
    SLICEARGUMENT = txt_hrc_split(8);
    fprintf(fid2, '%d,%s,%s,%s,%s,%s,%s,%s\n', m, cell2mat(GOPTYPESIZE), cell2mat(RATECONTROL), cell2mat(REFRESH), cell2mat(INTRAPERIOD), cell2mat(SEARCHRANGE), cell2mat(BITDEPTH), cell2mat(SLICEARGUMENT));
end
fclose(fid2);
fclose(fid);