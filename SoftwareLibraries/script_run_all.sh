#!/bin/bash

#prefix="."
prefix="../DATA/QMA/"

echo "This script is part of the ReproducibleQualityResearch software"
echo "Licensed under: LPGLv3, Dec 15, 2016"
echo

echo "This script will generate all the data for the PSNR section of the paper"
echo "It has been tested on a standard Linux Ubuntu 14.04 LTS distribution"
echo "Press ENTER to continue, CTRL+C to stop"
echo
read

echo "Note that the input file 'FRmetricsFrameByFrame.csv' needs to be passed as parameter of the first script"
echo "Please edit the script if needed"
echo "The file can be either computed or downloaded from ftp://ftp.ivc.polytech.univ-nantes.fr/VQEG/JEG/HYBRID/hevc_database/FR/FRmetricsFrameByFrame.csv (~420 MB)"
echo "Scripts will assume it is available in the prefix dir "$prefix""
echo "Press ENTER to continue, CTRL+C to stop"
read

echo "Computing MSE values ..."
python script_create_other_psnr_data_and_msefile.py "$prefix"/FRmetricsFrameByFrame.csv mse_000 "$prefix"/FRmetricsFrameByFrame_mse.csv

echo
echo "Computing statistical information (e.g., PSNRvar etc) ..."
python script_create_psnr_stddev_per_frame.py "$prefix"/FRmetricsFrameByFrame.csv "$prefix"/FRmetricsFrameByFrame_mse.csv "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv

echo "Filtering data according to the rate control strategy ..."
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv  "$prefix"/list_hrcs_fixedQP.txt "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__fixedQP.csv
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv  "$prefix"/list_hrcs_RateControl.txt "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__RateControl.csv
echo

echo "Computing CDF for various rate control strategies ..."
python script_compute_perpoint_cdf_function_over_PSNR_G-PSNR_A.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__RateControl.csv  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__RateControl_cdf.txt
python script_compute_perpoint_cdf_function_over_PSNR_G-PSNR_A.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__fixedQP.csv  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__fixedQP_cdf.txt
echo


echo "Filtering data according to the identified subsets ..."
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/hrcs_sets/hrcs_content.txt    "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_content.csv
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/hrcs_sets/hrcs_rd.txt         "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_rd.csv
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/hrcs_sets/hrcs_random1_97.txt "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random1_97.csv
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/hrcs_sets/hrcs_random2_97.txt "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random2_97.csv
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/hrcs_sets/hrcs_random3_97.txt "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random3_97.csv
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/hrcs_sets/hrcs_random1_83.txt "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random1_83.csv
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/hrcs_sets/hrcs_random2_83.txt "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random2_83.csv
python script_filter_HRCs.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/hrcs_sets/hrcs_random3_83.txt "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random3_83.csv
echo


echo "Computing similarities between graphs (can take long time) ..."
python script_similarity.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_rd.csv > "$prefix"/similarity_ALL_with_rd.csv
python script_similarity.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_content.csv > "$prefix"/similarity_ALL_with_content.csv

python script_similarity.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random3_97.csv > "$prefix"/similarity_ALL_with_random3_97.csv
python script_similarity.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random2_97.csv > "$prefix"/similarity_ALL_with_random2_97.csv
python script_similarity.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random1_97.csv > "$prefix"/similarity_ALL_with_random1_97.csv

python script_similarity.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random3_83.csv > "$prefix"/similarity_ALL_with_random3_83.csv
python script_similarity.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random2_83.csv > "$prefix"/similarity_ALL_with_random2_83.csv
python script_similarity.py  "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance.csv "$prefix"/data_psnr000_vs_psnrA00_with_overall_mean_variance__hrcs_random1_83.csv > "$prefix"/similarity_ALL_with_random1_83.csv
echo

echo "Done. Please use the provided gnuplot files to visualize results."



