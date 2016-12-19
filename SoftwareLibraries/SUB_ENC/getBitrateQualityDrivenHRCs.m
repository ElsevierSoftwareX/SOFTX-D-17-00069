
%% ---------------------------------------------------------
% This function is used to select HRCs from the large-scal database. In
% fact, this function select the HRCs that might cover the different ranges
% of bitrate and quality. 
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
function [selected_idx] = getBitrateQualityDrivenHRCs(DistortionCSV, BitrateCSV)


%Inputs
[dataPSNR, txtHRCsPSNR, ~] = xlsread(DistortionCSV);
txtHRCsPSNR = txtHRCsPSNR(2:end,1);
[dataRate, txtHRCsRate, ~] = xlsread(BitrateCSV);
txtHRCsRate = txtHRCsRate(2:end,1);
src = {'src01' 'src02' 'src03' 'src04' 'src05' 'src06' 'src07' 'src08' 'src09' 'src10'};
k=17; %number of cluster ---- 20 -- > 44,  17 --> 30, 15 --> 28, 12 --> 20
nranges = 4; %number of ranges within the group %For k=17, 1= 1.5%, 2=3%, 3=4.5%, 4=6%


%initialize variables
rankRate = zeros(size(dataPSNR, 1),numel(src));
rankPSNR = zeros(size(dataPSNR, 1),numel(src));

%Calculate the Cost function
dataCost = dataPSNR./log(dataRate);

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
all_rank_psnr = reshape(rankPSNR, [], 1);
all_rank_rate = reshape(rankRate, [], 1);
all_rank = [all_rank_rate, all_rank_psnr];
[idx,~,~,~] = kmeans(all_rank, k, 'Distance', 'sqeuclidean', 'MaxIter',10000, 'Replicates',100);
all_clsHRC = idx;
clsHRC = reshape(all_clsHRC, [], numel(src));

txt_hrc_cluster = cell(2000,numel(src), k); % you may need to increase the 2000
%re arrange the data to get hrcs pper cluster per source
for m=1:k
    for i=1:numel(src)
        txt_hrc_cluster(1:sum(clsHRC(:,i)==m),i,m) = txtHRCsRate(clsHRC(:,i)==m);
    end
end

%find intersections
intsect = zeros(k, 4);
intsect_src_k = cell(k, 4);
intsect_src_k_hrc_txt = cell(k, 4);
intsect_src_k_hrc_idx = cell(k, 4);

for m=1:k %for each cluster: get the common hrcs between video sources -- (each cluster may have more than one group)
    group_out_new =[]; %to save the which source should stay in the first group
    group_in_new =[]; %to save which source should go to another group
    %start with the first source, if it is empty, select the next one
    x = 1;
    while true
        A = txt_hrc_cluster(:,x,m);
        A = A(find(~cellfun(@isempty,A)));
        A_copy = A;
        
        if ~isempty(A)
            break;
        else
            x = x + 1;
        end
    end
    group_in_new = [group_in_new; x]; %save the current source in the group
    
    %iterate through the other sources to who is in and out, Justt keep
    %source that has at least 10 common HRCs
    for i=x+1:numel(src)
        B = txt_hrc_cluster(:,i,m);
        B = B(find(~cellfun(@isempty,B)));
        if numel(B) < 10
            group_out_new = [group_out_new; i];
            continue;
        end
        A = intersect(A, B); %save the intersect
        
        if numel(A) <= 10
            A = A_copy;
            group_out_new = [group_out_new; i];
            continue;
        end
        
        group_in_new = [group_in_new; i];
    end
    
    intsect(m, 1) = numel(A); %save the commoon HRCs of the first group
    intsect_src_k (m,1) = {group_in_new}; %save the sources of the first group
    [~,txt_idx] = ismember(A,txtHRCsPSNR);
    intsect_src_k_hrc_txt (m,1) = {txtHRCsPSNR(txt_idx)}; %save the full name of HRC of intersect group
    intsect_src_k_hrc_idx (m,1) = {txt_idx}; %save the index of HRC of intersect group
    
    %iterate through the out group till it is empty
    count = 2;
    while ~isempty(group_out_new)
        curr_group = group_out_new;
        group_out_new = [];
        group_in_new = [];
        x =1;
        while true
            A = txt_hrc_cluster(:,curr_group(x),m);
            A = A(find(~cellfun(@isempty,A)));
            A_copy = A;
            if ~isempty(A)
                break;
            else
                x = x + 1;
            end
        end
        
        group_in_new = [group_in_new; curr_group(x)];
        
        for i=x+1:numel(curr_group)
            B = txt_hrc_cluster(:,curr_group(i),m);
            B = B(find(~cellfun(@isempty,B)));
            if numel(B) < 10
                group_out_new = [group_out_new; curr_group(i)];
                continue;
            end
            A = intersect(A, B);
            
            if numel(A) <= 10
                A = A_copy;
                group_out_new = [group_out_new; curr_group(i)];
                continue;
            end
            
            group_in_new = [group_in_new; curr_group(i)];
            
        end
        
        intsect(m, count) = numel(A);
        intsect_src_k (m,count) = {group_in_new};
        [~,txt_idx] = ismember(A,txtHRCsPSNR);
        intsect_src_k_hrc_txt (m,count) = {txtHRCsPSNR(txt_idx)};
        intsect_src_k_hrc_idx (m,count) = {txt_idx};
        count = count + 1;
    end
end
k_all = sum(sum(intsect~=0)); %to save the total number of groups


%get hrcs for different number of ranges max = Nranges
selected_idx = cell(k,size(intsect_src_k,2), nranges); % to save the final selection in each range
for curr_nranges=1:nranges
    %for each cluster (group) now, divide the range of [COST] into Nranges and
    %select the common HRC that is close to center of each range
    for m=1:k %for each cluster
        for n=1:size(intsect_src_k,2) % for each each group in a cluster
            if intsect(m,n)~=0
                current_srcs = cell2mat(intsect_src_k(m,n)); % get the sources of current group
                current_hrcs = cell2mat(intsect_src_k_hrc_idx(m,n)); % get the common HRCs of current group
                current_cost = dataCost(current_hrcs, current_srcs); % get the COST of current group
                
                current_cost_min = min(min(current_cost)); %min value of COST in a group
                current_cost_max = max(max(current_cost)); %max value of COST in a group
                
                indx_ranges = linspace(current_cost_min,current_cost_max, curr_nranges+1); %divide the range [min, max] into Nranges
                centers = zeros(curr_nranges,1); % to save the center of each Nrange
                
                selected_idx_hrc = [];
                if numel (current_srcs) == 1 % if the group contains only one source
                    for r=1:numel(centers) % for each range
                        first_idx = find(dataCost(current_hrcs,current_srcs)>=indx_ranges(r));
                        second_idx = find(dataCost(current_hrcs,current_srcs)<indx_ranges(r+1));
                        range_idx_selected = intersect(first_idx,second_idx);
                        
                        if isempty(range_idx_selected)
                            continue;
                        end
                        centers(r,1) = (indx_ranges(r)+indx_ranges(r+1))/2;
                        cost_minus_center = abs(dataCost(current_hrcs(range_idx_selected), current_srcs)-centers(r,1));
                        [~, sort_idx_range] = sort(cost_minus_center);
                        %sort_idx(:,in_r) = sort_idx_range;
                        
                        %get hrc_idx
                        selected_idx_hrc = [selected_idx_hrc; current_hrcs(range_idx_selected(sort_idx_range(1)))];
                    end
                else
                    for r=1:numel(centers) % for each range
                        in_range = []; % to save the source that its HRCs inn this range
                        flag = false; % to check whether there are hrcs in a range or not
                        x=1;
                        while true
                            if x>numel(current_srcs)
                                flag = true;
                                break;
                            end
                            first_idx = find(dataCost(current_hrcs,current_srcs(x))>=indx_ranges(r));
                            second_idx = find(dataCost(current_hrcs,current_srcs(x))<indx_ranges(r+1));
                            range_idx_selected = intersect(first_idx,second_idx);
                            if ~isempty(range_idx_selected)
                                break;
                            else
                                x = x + 1;
                            end
                        end
                        
                        % no HRCs in the range
                        if flag
                            continue;
                        end
                        
                        in_range = [in_range; current_srcs(x)];
                        for i=x+1:numel(current_srcs) % get the common HRC in the range for all sources
                            
                            first_idx = find(dataCost(current_hrcs,current_srcs(i))>=indx_ranges(r));
                            second_idx = find(dataCost(current_hrcs,current_srcs(i))<=indx_ranges(r+1));
                            
                            range_idx = intersect(first_idx,second_idx);
                            
                            if isempty(range_idx)
                                continue;
                            end
                            
                            range_idx_selected_copy = range_idx_selected;
                            range_idx_selected = intersect(range_idx,range_idx_selected);
                            if isempty(range_idx_selected)
                                range_idx_selected = range_idx_selected_copy;
                                continue;
                            end
                            in_range = [in_range; current_srcs(i)];
                        end
                        
                        %we have the source that have common hrcs in the
                        %range, now, get the HRC that is close to the middle
                        %point in the range
                        
                        %sort index for each group in in_range
                        centers(r,1) = (indx_ranges(r)+indx_ranges(r+1))/2;
                        sort_idx = zeros(numel(range_idx_selected), numel(in_range));
                        for in_r = 1:numel(in_range)
                            cost_minus_center = abs(dataCost(current_hrcs(range_idx_selected), in_range(in_r))-centers(r,1));
                            [~, sort_idx_range] = sort(cost_minus_center);
                            sort_idx(:,in_r) = sort_idx_range;
                        end
                        
                        % incremental search for the closet common hrc between
                        % points
                        for row_sort_idx=1:size(sort_idx, 1)
                            get_cell = {};
                            for col_sort_idx=1:size(sort_idx, 2)
                                get_cell = [get_cell, sort_idx(1:row_sort_idx, col_sort_idx)];
                            end
                            
                            if numel(get_cell)==1
                                cell_one = cell2mat(get_cell(1));
                                selected_idx_range = cell_one(1);
                            else
                                selected_idx_range = intersect2(get_cell);
                            end
                            if ~isempty(selected_idx_range)
                                break;
                            end
                        end
                        
                        %get hrc_idx
                        selected_idx_hrc = [selected_idx_hrc; current_hrcs(range_idx_selected(selected_idx_range(1)))];
                    end
                end
                selected_idx(m, n, curr_nranges) = {selected_idx_hrc};
            end
        end
    end
    
    %get the parameter of each hrc
    %hrc_parameters = cell(k, 7, size(intsect_src_k,2)); % to save the parameters of final selection
    %get file name of all selected hrcs per source
    fid = fopen(['hrc_bitratequality_driven_' num2str(k) '_' num2str(curr_nranges)  '.txt'], 'w');
    fid2 = fopen(['hrc_bitratequality_driven_' num2str(k) '_' num2str(curr_nranges)  '_parameters.csv'], 'w');
    
    hrc_per_cluster = [];
    for m=1:k %for each cluster
        fprintf(fid, '\n%s :: %d\n', 'Cluster', m);
        for n=1:size(intsect_src_k,2) % for each each group in a cluster
            if intsect(m,n)~=0
                fprintf(fid, '*** %s :: %d\n', 'GROUP', n);
                curr_hrcs = cell2mat(selected_idx(m,n, curr_nranges));
                hrc_per_cluster = [hrc_per_cluster; curr_hrcs];
                for hrc = 1:numel(curr_hrcs)
                    txt_idx = curr_hrcs(hrc);
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
            end
        end
    end
    
    fclose(fid);
    fclose(fid2);
end