# Train XGBoost model

Trains an XGBoost model for predictive isotope analysis using DBSCAN
clustering. SMOTE data imputation for the training data set and XGBoost,
following the method of Shnyr et al. (2026).

## Usage

``` r
pb_iso_train_data(ref, ...)

# S3 method for class 'ASTR_Pbiso_ref_data'
pb_iso_train_data(
  ref,
  minSize = 20,
  minPts_fac = 0.1,
  eps = 0.18,
  eta = 0.1,
  max_depth = 6,
  nrounds = 100,
  nthread = 4L,
  ...
)

# S3 method for class 'ASTR'
pb_iso_train_data(
  ref,
  ref_group,
  min_groupsize = 5,
  minSize = 20,
  minPts_fac = 0.1,
  eps = 0.18,
  eta = 0.1,
  max_depth = 6,
  nrounds = 100,
  nthread = 4L,
  ...
)
```

## Arguments

- ref:

  `ASTR` object containing 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb or
  `ASTR_Pbiso_ref_data` object.

- ...:

  Arguments passed on to
  [`dbscan::dbscan`](https://michael.hahsler.net/dbscan/reference/dbscan.html),
  [`xgboost::xgb.train`](https://rdrr.io/pkg/xgboost/man/xgb.train.html)

  `weights`

  :   numeric; weights for the data points. Only needed to perform
      weighted clustering.

  `borderPoints`

  :   logical; should border points be assigned to clusters. The default
      is `TRUE` for regular DBSCAN. If `FALSE` then border points are
      considered noise (see DBSCAN\* in Campello et al, 2013).

  `early_stopping_rounds`

  :   Number of boosting rounds after which training will be stopped if
      there is no improvement in performance (as measured by the
      evaluatiation metric that is supplied or selected by default for
      the objective) on the evaluation data passed under `evals`.

      Must pass `evals` in order to use this functionality. Setting this
      parameter adds the
      [`xgb.cb.early.stop()`](https://rdrr.io/pkg/xgboost/man/xgb.cb.early.stop.html)
      callback.

      If `NULL`, early stopping will not be used.

  `maximize`

  :   If `feval` and `early_stopping_rounds` are set, then this
      parameter must be set as well. When it is `TRUE`, it means the
      larger the evaluation score the better. This parameter is passed
      to the
      [`xgb.cb.early.stop()`](https://rdrr.io/pkg/xgboost/man/xgb.cb.early.stop.html)
      callback.

- minSize:

  Minimum number of samples in group to be used for clustering, default
  value is `20`.

- minPts_fac:

  Scaling factor for the minimum number of points needed from each
  group, ranging from 0 to 1, default value is `0.1`.

- eps:

  Size (radius) of the epsilon neighbourhood, default value is `0.18`.

- eta:

  Step size shrinkage used in update to prevent overfitting. After each
  boosting step, we can directly get the weights of new features, and
  eta shrinks the feature weights to make the boosting process more
  conservative. Default value is `0.1`.

- max_depth:

  Maximum depth of a tree. Increasing this value will make the model
  more complex and more likely to overfit. Zero indicates no limit on
  depth. Beware that XGBoost aggressively consumes memory when training
  a deep tree. "exact" tree method requires non-zero value. Default
  value is `6`.

- nrounds:

  Maximum number of boosting iterations, default value is `100`.

- nthread:

  Integer setting the number of threads for parallel processing. When
  choosing it, please keep thread contention and hyper threading in
  mind. Default value is `4L`.

- ref_group:

  Character string with name of the column containing isotope groups.

- min_groupsize:

  Integer value for the minimum number of samples in a group, default
  value is `5L`.

## Value

List of XGBoost model objects.

## Details

The Machine learning workflow described by Shnyr et al. (2026) for data
preparation, clustering, class balancing, and classification is
discussed here.

## *DBSCAN clustering and outlier identification*

The Density-Based Spatial Clustering of Applications with Noise (DBSCAN)
algorithm is used to identify outliers and subgroup patterns. This
method facilitates outlier removal and cluster formation within lead
isotopic data, effectively reducing inter-regional overlaps. Systematic
evaluation of the neighbourhood radius (eps) utilized the Silhouette
Score and Davies–Bouldin Index. The optimal parameter, `eps = 0.18`,
yielded a Silhouette Score of 0.691 and a Davies–Bouldin Index of 0.347.
This result indicates the formation of well-separated, compact clusters.
The minimum points parameter (minPts) was dynamically established at 10%
of the total samples per region. This strategy adapts the density
threshold to varying sample sizes, adhering to established proportional
scaling practices. To ensure reliability, analysis was restricted to
regions with ≥ 20 samples. This constraint successfully minimized
noise-related bias. Finally, regions forming multiple clusters received
systematic labels, while single-cluster regions remained unassigned.

## *SMOTE application*

The Synthetic Minority Over-sampling Technique (SMOTE) generates
synthetic data points for the minority class through interpolation. This
process balances class distribution and enhances learning by introducing
variety while reducing overfitting risks. This study transformed the
data set into a binary classification problem. Synthetic sample counts
were dynamically adjusted based on minority cluster density to maintain
appropriate balance. This step mitigated class imbalance, preventing
predictive bias and improving classifier performance.

## *XGBoost model training*

XGBoost algorithm was used to train a binary classification model using
three isotopic ratios as input features. The regional cluster names
derived from DBSCAN served as target labels. The resampled data set was
partitioned into training and testing sets, treating each cluster as an
independent classification problem. This iterative process involved data
encoding, SMOTE application, and individual XGBoost model training for
every cluster. Final results demonstrate varying probabilities for
potential clusters as the definitive source for the sample group.

## References

Shnyr, E., Kuflik, T., Desai, K., and Eshel, T. (2026) Determining the
origins of Phoenician silver: Exploring the potential of machine
learning for lead isotope analysis. Journal of Archaeological Science
188, pp. 106–499. <https://doi.org/10.1016/j.jas.2026.106499>

## See also

Other Pb isotope functions:
[`age_models`](https://archaeothommy.github.io/ASTR/reference/age_models.md),
[`as_pbiso_ref_data()`](https://archaeothommy.github.io/ASTR/reference/as_pbiso_ref_data.md),
[`geom_sk_lines()`](https://archaeothommy.github.io/ASTR/reference/geom_sk_lines.md),
[`pb_iso_endmembers()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_endmembers.md),
[`pb_iso_prov_dist()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_dist.md),
[`pb_iso_prov_predict()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_predict.md),
[`tel_dor`](https://archaeothommy.github.io/ASTR/reference/tel_dor.md)

## Examples

``` r
# Create an 'ASTR_Pbiso_ref_data' object
GlobaLID_ASTR_ref <- as_pbiso_ref_data(GlobaLID_ASTR,
                  names(GlobaLID_ASTR)[[2]],
                  min_groupsize = 5)

# Train machine learning model
if (FALSE) ml_model <- pb_iso_train_data(GlobaLID_ASTR_ref) # \dontrun{}

# Predict using a pre-trained model
if (FALSE) pb_iso_prov_predict(tel_dor, model_list = ml_model, .top = 1) # \dontrun{}
```
