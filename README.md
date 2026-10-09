<!-- TODO before release: complete every [bracketed] item, then delete this comment. -->

# Data and Code: Competing Risks of Loss to Follow-up and Mortality Among Adults Receiving Antiretroviral Therapy in Northern Ghana

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23269219.svg)](https://doi.org/10.5281/zenodo.23269219)

## Overview

This repository contains the dataset, data dictionary and analysis code that accompany the manuscript:

> Abo SC, [co-authors]. *Assessing the Competing Risks of Loss to Follow-up and Mortality Among Adults Receiving Antiretroviral Therapy in Northern Ghana: Application of the Fine-Gray Subdistribution Hazard Model.* [Journal / preprint server]. [Year]. [Manuscript DOI or URL]

The dataset contains records of **329 adults** who registered for antiretroviral therapy (ART) between **2013 and 2019** at [facility name], Northern Ghana. Each row is one patient. The data were used to estimate the cumulative incidence of, and covariate effects on, [loss to follow-up] in the presence of the competing event of [death], using the Fine-Gray subdistribution hazard model.

## Repository contents

```
.
├── README.md                  This file
├── LICENSE                    Licence for the code
├── CITATION.cff               Citation metadata
├── data/
│   ├── ART.csv                Patient-level dataset (329 rows, 16 columns)
│   └── data_dictionary.csv    Variable definitions and coding
└── R/
    └── [analysis_script.R]    Code reproducing the tables and figures in the manuscript
```

## Data description

| | |
|---|---|
| **File** | `data/ART.csv` |
| **Format** | Comma-separated values, UTF-8, header row |
| **Dimensions** | 329 rows × 16 columns |
| **Missing values** | None |
| **Unit of observation** | One patient |

### Variables

| Variable | Type | Description | Values / range |
|---|---|---|---|
| `No` | integer | Row identifier (not a clinic or patient ID) | 1–329 |
| `YearReg` | integer | Year of registration for ART | 2013–2019 |
| `Weight` | numeric | Body weight at [baseline], in [kg] | 20–90 |
| `Emp` | categorical | Employment status | `Employed`, `Not employed` |
| `Religion` | categorical | Religion | `Muslim`, `Christian`, `Traditionalist` |
| `distance_facility` | categorical | Distance from home to the treatment facility | `short`, `long` ([define cut-off, e.g. ≤ X km]) |
| `Contact` | categorical | [Whether patient contact information (e.g. phone or address) was provided] | `Provided`, `Not provided` |
| `Age` | integer | Age at [ART initiation], in years | 16–83 |
| `Gender` | categorical | Gender | `F`, `M` |
| `ed` | categorical | Education | `Had no education`, `Had some form of education` |
| `marital` | categorical | Marital status | `Married`, `Single`, `Widowed`, `Divorced/Separated` |
| `Cotrimoxazole` | categorical | Cotrimoxazole prophylaxis | `Received`, `Not received` |
| `HospitalAdmission` | categorical | [Hospital admission during follow-up / at baseline] | `Admitted`, `Not admitted` |
| `Regimen` | categorical | First-line ART regimen | `EFV` (efavirenz-based), `NVP` (nevirapine-based) |
| `fuptime` | integer | Follow-up time from [time origin] to [event or censoring], in [months] | 0–82 |
| `statuscprsk` | integer | Outcome status for the competing-risks analysis | `0`, `1`, `2` (see below) |

The same information is provided in machine-readable form in `data/data_dictionary.csv`.

### Outcome coding

`fuptime` and `statuscprsk` together define the competing-risks outcome.

| `statuscprsk` | Meaning | Patients |
|---|---|---|
| 0 | [Censored: e.g. retained in care at end of follow-up] | 124 |
| 1 | [Event type 1: loss to follow-up or death] | 153 |
| 2 | [Event type 2: death or loss to follow-up] | 52 |

[State how follow-up started and ended, how loss to follow-up was defined (e.g. no clinic contact for more than X days), how censoring was defined, and the date of data closure.]

## Data collection and ethics

- **Source:** [e.g. routine clinic records / ART register at the facility]
- **Design and period:** [Retrospective cohort; patients registered 2013–2019; follow-up until [date]]
- **Ethics approval:** [Committee name, approval reference number, date]
- **Consent:** [e.g. waiver of individual consent for use of anonymised routine records]

## De-identification and privacy

[Describe the steps taken, for example: direct identifiers (names, folder numbers, contact details, dates of birth, exact dates) were removed; `No` is a randomly assigned number; age was grouped / registration years were grouped / rare categories were merged.]

Although direct identifiers have been removed, individual-level health data can carry a residual risk of re-identification when several characteristics are combined. **Users must not attempt to identify, contact or trace any individual represented in the data, or link these data with other datasets for that purpose.**

## Reproducing the analysis

**Software:** R [version X.Y.Z] with the packages [e.g. `survival`, `cmprsk`, `tidycmprsk`, `ggplot2`]. Package versions are recorded in [`renv.lock` / `sessionInfo.txt`].

```r
# Run from the repository root
dat <- read.csv("data/ART.csv", stringsAsFactors = TRUE)
source("R/[analysis_script.R]")
```

[Say which script produces which table or figure in the manuscript.]

## Licence

- **Data:** [Creative Commons Attribution 4.0 International (CC BY 4.0)]
- **Code:** [MIT License]

## How to cite

Please cite the dataset and the manuscript.

**Dataset:**

> Abo, S. C. (2026). *Data for competing risks of loss to follow-up and mortality among adults receiving antiretroviral therapy* (Version 1.0.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.23269219

**Manuscript:** see [Overview](#overview).

## Contact

Solomon Crusader Abo
School of Mathematics, Statistics and Actuarial Science, University of Essex, Colchester, UK
Email: sa24769@essex.ac.uk
ORCID: [https://orcid.org/XXXX-XXXX-XXXX-XXXX]

## Changelog

- **v1.0.0** (9 October 2026): Initial release accompanying the manuscript.
