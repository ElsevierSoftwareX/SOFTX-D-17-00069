
The "Reproducible Video Quality Research Framework" is a framework to facilitate reproducibility of research in video quality evaluation.

The domain of objective video quality algorithms suffers from the lack of reproducible research.
Scientific progress is impacted by missing implementations of existing algorithms and missing test data.
The implementations are often missing because the individual authors hesitate to publish their code, thus requiring reimplementation of complex algorithms.
As test data for the correctness of the algorithms is often also missing, a reimplementation may not be validated.
As a consequence, comparisons published in the domain rely on uncertain data.

This research framework serves three purposes. 
* Firstly, it provides an environment for calculating a reproducible large-scale dataset of compressed video sequences that can be used both as test data and for comparisons of algorithms.
* Secondly, the framework provides the possibility to provide different Peak Signal to Noise Ratio (PSNR) measures as an example for the calculation of more complex algorithms and for comparisons in scientific research as most researchers compare their work to PSNR.
* Thirdly, a subset selection algorithm that can be targeted to different research questions is provided that allows for running computationally expensive algorithms on parts of the large-scale database while retaining important characteristics for the analysis.

This software package helps in developing and evaluating objective video quality measurement algorithms.
Researchers can reproduce the test dataset and provide the results of their algorithm so that exact reproducibility of their algorithm can be guaranteed.
Comparisons between different algorithms are also enabled because of the size of the large-scale dataset which reduces the probability of overtraining if the test design is carefully chosen.
Last but not least, it makes researchers in the field aware that even small differences in algorithms may lead to important differences in the conclusions of their algorithms thus providing motivation for precise descriptions or published reference software.


To learn more about this framework, visit [VQEG JEG-Hybrids Reproducible Framework](http://vqegjeg.intec.ugent.be/wiki/index.php/JEG_Reproducible_Video_Quality_Analysis_Framework).

## Getting Started

### Prerequisites

* Windows operating system
* Python
* Matlab (only for subset selection aspects)

### Basic Installation

The "Reproducible Video Quality Research Framework" is based on python scripts and does not require installation except from cloning the repository.

### Running the framework

For an extensive step by step guide, please visit [VQEG JEG-Hybrids Reproducible Framework](http://vqegjeg.intec.ugent.be/wiki/index.php/JEG_Reproducible_Video_Quality_Analysis_Framework)
