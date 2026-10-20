<h1 align="center">sync_osc_MSTMs: a library of multineuron spike train measures</h1>

<p align="center">
  <a href="https://doi.org/10.1371/journal.pcbi.1013597"><img src="https://img.shields.io/badge/paper-PLOS%20Comput%20Biol%20(2025)-informational" alt="Paper"/></a>
  <a href="http://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/badge/license-GPLv3-blue.svg" alt="License: GPL v3"/></a>
  <img src="https://img.shields.io/badge/language-MATLAB-orange" alt="Language: MATLAB"/>
</p>

This repository contains the code for the article ["Synchrony, oscillations, and phase relationships in collective neuronal activity: a highly-comparative overview of methods" by F. Baroni and B.D. Fulcher, _PLoS Computational Biology_ (2025)](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1013597).
It implements a library of multineuron spike train measures (MSTMs) that quantify synchrony, oscillations and phase relationships in population spike trains.
It also includes the generation of synthetic spike trains with controlled synchrony and oscillation properties, and the scripts that analyze synthetic and real spike trains and generate the paper's figures.

The code is written in MATLAB, with a few functions that call Python.
Our original code is licensed under the [GNU GPL v3 license](http://www.gnu.org/licenses/gpl-3.0.html) (or later).
This repository also includes packages developed by other authors in the `third-party` folder.
These are provided with their original licenses, which can be found in their respective subdirectories.
Please review and comply with those licenses before use.

## Contents

| Directory | Contents |
|---|---|
| [`synth_train_generation`](synth_train_generation) | Generation of synthetic spike trains, and the `script_*_train_range.m` scripts that sweep over their parameters. |
| [`data_analysis`](data_analysis) | The MSTM library (in [`data_analysis/MSTMs`](data_analysis/MSTMs)), the analysis of real and synthetic spike trains, and the figure-generating scripts. |
| [`common`](common) | Helper scripts for submitting batches of jobs to a computing cluster. |
| [`third-party`](third-party) | Packages developed by other authors, each with its original license. |
| [`script_all.m`](script_all.m) | The top-level script: every script needed to generate the synthetic data and analyze the synthetic and real spike trains, in the order of the article. |

The plain-text [`README`](README) file describes every high-level script and function.

## Installation

Clone the repository, start MATLAB in the repository's top-level folder, and run `startup`:

```matlab
startup
```

`startup.m` adds the repository's folders, including all of `third-party`, to the MATLAB path.
If you want to keep your own version of some of the bundled packages, edit `startup.m` accordingly (examples are provided in the file).

### Requirements

Most code runs on a basic MATLAB installation.
Some scripts and functions require the Wavelet Toolbox, the Image Processing Toolbox, or the Statistics and Machine Learning Toolbox.
Functions that use `tightPosition` to lay out figures require a modern version of MATLAB (R2022b or newer).

Some functions call Python through MATLAB, so they need a Python environment that MATLAB recognizes (see [`pyenv`](https://www.mathworks.com/help/matlab/ref/pyenv.html)):

- [FOOOF](https://github.com/fooof-tools/fooof) model estimation (`analyze_sinosc_train_fooof.m`, `analyze_osc_train_fooof_win_data.m`), which also needs the MATLAB wrapper `fooof_mat` on the path (it is not included in this repository).
  Install FOOOF with `python3 -m pip install fooof`.
- Intrinsic dimensionality estimation with [DADApy](https://github.com/sissa-data-science/DADApy), which can be installed with `python3 -m pip install git+https://github.com/sissa-data-science/DADApy`.
  Setting `py.sys.path` manually may be necessary.

### MEX files

Several measures use compiled MEX code from the packages in `third-party`.
The repository ships only Linux binaries (`.mexa64`).
On macOS and Windows, compile the MEX files from their C/C++ sources with `mex` before using the corresponding measures:

| Measure | Folder in `third-party` | How to compile |
|---|---|---|
| Victor-Purpura distance | `spkd` | `mex spkdl_mex.c` |
| Modulus metric | `modulus-metric-master` | `mex modulus_metric_mex.cpp` |
| Spike time tiling coefficient, correlation index | `Detecting_pairwise_correlations_in_spike_trains-master` | `mex spike_time_tiling_coefficient_mex.c` and `mex correlation_index_mex.c` |
| ISI-distance, SPIKE-distance, SPIKE-synchronization | `cSPIKE/cSPIKE/cSPIKEmex` | run `MEX_compile.m` in that folder |

### Test

To check that the installation works, run the unit test of the mean phase coherence measure:

```matlab
testResults = runtests('script_MPC_test')
```

## Quick start

The top-level script `script_all.m` runs all the analyses in the order of the article.
The real spike train datasets are not included in this repository.
Download them from the sources below, and set `dataDir` (and the other directory names) at the top of each `script_data_train_*.m` script to your local paths:

| Dataset | Script | Source |
|---|---|---|
| See et al. 2018 | `script_data_train_See18.m` | [doi:10.6080/K09021X1](http://dx.doi.org/10.6080/K09021X1) |
| Smith et al. 2008 | `script_data_train_Smith08.m` | [doi:10.6080/K0NC5Z4X](http://dx.doi.org/10.6080/K0NC5Z4X) |
| Formozov et al. 2022 | `script_data_train_Form22.m` | [doi:10.12751/g-node.lkx6kk](http://dx.doi.org/10.12751/g-node.lkx6kk) |

## Synthetic spike train generation

Multiple synthetic spike trains with parameters spanning a range of values can be generated by using one of the scripts named `script_*_train_range.m`:

| Script | Trains |
|---|---|
| `script_sin_train_range.m` | single-scale, non-sequential |
| `script_sinseq_train_range.m` | single-scale, sequential |
| `script_G_train_range.m` | dual-scale, non-sequential |
| `script_Gseq_train_range.m` | dual-scale, sequential |

`sin` in a script or function name indicates "single-scale" trains (stands for "sinusoidal").
`G` in a script or function name indicates "dual-scale" trains (stands for "Gaussian").
Spike train raster plots as in Fig 1 can be generated using `plot_sinosc_train.m`.

<img src="https://github.com/user-attachments/assets/e5de8602-90ec-4147-a190-b9b65a763427" width=70%>

## Synthetic spike train analysis

### Applying the library of multineuron spike train measures (MSTMs)

The MSTM library is included in the functions:

- `analyze_sinosc_train_ms.m`
- `analyze_sinosc_train_fooof.m`
- `analyze_sinosc_train_synfireind.m`

These are called from the scripts `script_*_train_range.m` mentioned above, in the "Synthetic spike train generation" section.
The measures expect spike times as column vectors, in milliseconds.

### Correlation of each MSTM with each generative parameter

The scripts `script_all_train_range_ss.m` and `script_all_train_range_ds.m` load (single-scale and dual-scale, respectively) synthetic spike train measures and calculate the correlation of each MSTM with each generative parameter.
They generate panels such as those shown in Fig 3 using the function `multi_all_train_range_anal_corr_bal.m`.

![sync_all_absspearmancorr_thr_scaled_mat_par_color_longn_cb_bs_050723](https://github.com/user-attachments/assets/f528794d-b1ca-437f-a2b0-57b4428ae1a1)

### Organizing the MSTM library using inter-MSTM correlations and clustering

The script `script_all_train_range.m` loads synthetic spike train measures from both the single-scale and the dual-scale formalisms.
It calculates inter-MSTM correlations and the resulting dendrogram, as in Fig 4, using the function `multi_all_train_range_anal_bs_cluster_bal.m`.

<img src="https://github.com/user-attachments/assets/0bfa7cce-8d60-4941-9b76-d420f735172e" width=70%>

## Real spike train analysis

### Applying the library of MSTMs

The scripts `script_data_train_{See18,Smith08,Form22}.m` load, preprocess and analyze each of the three spike train datasets considered in this study (see the table in [Quick start](#quick-start)).

The MSTM library can be applied to the preprocessed spike train datasets by using the functions:

- `analyze_osc_train_ms_win_{See18,Smith08,data}.m`
- `analyze_osc_train_fooof_win_data.m`
- `analyze_osc_train_synfireind_win_data.m`

These recapitulate the corresponding functions used for the synthetic spike train analysis, described above.

### Organizing data segments using clustering

A visualization of each dataset through the lens of the MSTM library, as in Fig 7, can be obtained by using `multi_train_anal_win_cluster.m`.

![fig_see](https://github.com/user-attachments/assets/d870d534-58c9-476e-af77-19621833eae5)

## Augmenting the MSTM library with new measures

To include additional MSTMs, you can write a new "synthetic spike train analysis" function following the template provided in the functions indicated above (`analyze_sinosc_train_ms.m`, `analyze_sinosc_train_fooof.m` or `analyze_sinosc_train_synfireind.m`).

Then, you can add a new case in `get_field_names.m` and `get_field_names_bs.m`.
`get_field_names.m` is for the extended set of MSTMs, including multiple timescales for the timescale-dependent measures.
`get_field_names_bs.m` is for the core set of MSTMs, including a single timescale (the "best scale") for the timescale-dependent measures.
Each specifies your new MSTM set, which is identified by the field `names_string` of the structure `par`.

The new selection of measures will then be included in subsequent processing, such as clustering analysis or correlation with generative parameters.

## Citation

If you use this code in your project, please cite:

> F. Baroni, B.D. Fulcher (2025). [Synchrony, oscillations, and phase relationships in collective neuronal activity: a highly-comparative overview of methods](https://doi.org/10.1371/journal.pcbi.1013597). _PLOS Computational Biology_ 21 (10): e1013597.

```bibtex
@article{Baroni2025Synchrony,
  title   = {Synchrony, oscillations, and phase relationships in collective neuronal activity: a highly comparative overview of methods},
  author  = {Baroni, Fabiano and Fulcher, Ben D.},
  journal = {PLOS Computational Biology},
  volume  = {21},
  number  = {10},
  pages   = {e1013597},
  year    = {2025},
  doi     = {10.1371/journal.pcbi.1013597}
}
```

## Contributing

This project welcomes and encourages contributions from the community, and [pull requests](https://github.com/GNB-UAM/sync_osc_MSTMs/pulls) are appreciated.

When contributing a novel MSTM that yields a well-defined value in certain reference cases (such as perfectly correlated or anticorrelated trains, or completely random trains), authors are encouraged to provide the corresponding unit tests.
Please see [`script_MPC_test.m`](data_analysis/script_MPC_test.m) (run through [`script_test.m`](data_analysis/script_test.m)) for an example of a unit test illustrating this for a specific measure.

Pull requests that edit an existing measure are discouraged.
Bug reports on an existing measure are encouraged.
Modifications or alternative implementations of an existing measure are only considered as pull requests if they yield a substantially different output in non-trivial cases (with empty spike trains or perfectly synchronized spike trains being considered as trivial cases), or a substantial improvement in computational time, and should be included under a different name.
All other modifications are encouraged as independent forks.

To file bug reports and/or ask questions about this project, please use the [GitHub issue tracker](https://github.com/GNB-UAM/sync_osc_MSTMs/issues).

## Acknowledgements

We include some code developed by others.
Please see the content of the directory `third-party`.

## Funding

This project was supported by grants PID2024-155923NB-I00 and PID2021-122347NB-I00 (PI: Pablo Varona Martinez), PID2023-149669NBI00 and PID2020-114867RB-I00 (PI: Francisco de Borja Rodríguez Ortiz) (MCIN/AEI and ERDF- "A way of making Europe").
BDF acknowledges support from the Australian Research Council (FT240100418).

<table>
<tr>
<td><img src="https://github.com/user-attachments/assets/9107610a-475f-42b9-b04d-3c803312ae74" height="120"></td>
<td><img src="https://github.com/user-attachments/assets/ec0917df-ae11-487c-b65b-ee8c04d9d949" height="90"></td>
</tr>
</table>
