
::################ Large Scale Encoding Environment ##################
::#Encode all the sequences
python SoftwareLibraries\ENC_SRC\ENC_win.py
::#Encode the 100 first sequences
::#python ./SoftwareLibraries/ENC_SRC/ENC_win.py 100

::##################### Subset Selection #############################
::The subset should be transferred from DATA\ENC to DATA\SUB_ENC

::##################### Quality Measure ##############################
::#Decode all the sequences and calculate PSNR
python SoftwareLibraries\DEC.py
::#Aggregate all the PSNR output files into a CSV file
python ./SoftwareLibraries/AggregatePSNRtoCSV.py

::################# Quality Measure Analysis #########################
::The Quality Measure Analysis module saves data in DATA\QMA

( cd SoftwareLibraries ; bash script_run_all.sh )

::###################### Visualize ###################################
::The visualize module takes data from DATA\QMA

( cd DATA/QMA; gnuplot graph_scatter__PSNRvar_vs_PSNR_interpolated.gplot )




