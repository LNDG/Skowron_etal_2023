# Analysis scripts for the paper "Neural variability compresses with increasing belief precision during Bayesian inference"

* Behavior folder contains scripts to replicate behavioral analyses and modelling
    * figure_example.m generates the simulated example of the Bayesian observer model (Figure 2B)
    * the modelling folder contains all scripts required to fit the behavioral models reported in the paper (i.e., Bayesian and Rescorla-Wagner learning models) and perform model/parameter recovery checks
    * get_beh.m and win_model_beh.m prepare variables (behavior and model parameters) for analysis (including winsorization)
    * beh_analysis_within.sav and model_beh.sav contain all variables required to replicate all behavioral results reported in the paper
    * plot_beh.m generates the plots shown in Figure 3, Figure 4D and Figure 5B
* Preproc folder contains script to perform fMRI preprocessing
    * script should be executed in numberic order. Unlabeled scripts and folders contain functions that are called in different preprocessing steps.
    * preproc_config.sh specifies paths and parameter setting for preprocessing
    * QC folder contains scripts to perform visual quality checks on preprocessed images
* GLM folder contains scripts to obtain standard GLM neural uncertainty correlates (i.e., beta estimates obtained by regressing sample-wise uncertainty estimates derived from our winning Bayesian observer model against the BOLD signal, see Results section in paper for details)
* trial-wise_PLS folder contains scripts to obtain BOLD SD estimates and run all PLS analyses reported in the paper
    * scripts labeled A-D generate BOLD SD estimates for the different trials epochs (note that get_timings.m should be run before to get trial timings)
    * E_PLS folder contains scripts to run PLS analyses on BOLD SD estimates and plot the results shown in Figure 4
    * the mean_analysis folder contains scripts to obtain (model-free) GLM beta estimates for each sample period (see Results section in paper for details) and perform PLS analysis
    * the offset_change folder contains scripts to perform the reported control analysis checking whether delta BOLD SD effects can be explained by between-subject differences in BOLD SD at first sample exposure (see Results section in paper)
    * the pMod_analysis folder contains scripts to run PLS analysis on standard GLM uncertainty estimates (see paper) and produce the plots in Figure 5
    * the pMod_control folder contains scripts to perform the reported control analysis checking if BOLD SD and standard GLM beta effects are spatially distinct (see Results in paper)

For more details please contact the author: skowron(at)mpib-berlin.mpg.de
