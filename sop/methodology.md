## Methodology

Each R script in the repository is commented as much as possible to explain what each section of the code is doing. However, there are a couple of more complex sections that require a bit more explanation. 

### Aggregating SMR data to Continuous Inpatient Stays (CIS), accounting for Care Home episodes

Some Care Home episodes are submitted to SMR, however this activity should be counted as time spent in the community. To ensure accurate counting of time spent in hospital, these episodes must be removed before aggrgating SMR data to Continuous Inpatient Stay (CIS) level. To do this, a new 'CIS marker' is calculated to account for care home episodes. The following section of code is taken from `code/01_create-basefile.R`.
 
```r
smr01 %<>%
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(lead(ch_flag) != ch_flag | 
                              lead(gls_cis_marker) != gls_cis_marker)[-n()])) %>%
  filter(ch_flag == 0)
```

First, episodes are sorted in order of admission date. The `ch_flag` is added during the SQL query and is 1 for any record with a care home location code. The `mutate` section of this code creates a new variable called `index`. This will start at 0 (zero) for every link number. If either of the following is true, the value increases by 1 compared to the previous row:
* `lead(ch_flag) != ch_flag` - Is the Care Home flag in the next row different to the one in the current row?
* `lead(gls_marker) != gls_cis_marker` - Is the CIS marker in the next row different to the one in the current row?
See the following example:

| link_no | gls_cis_marker | admission_date | discharge_date | ch_flag | index | |
| --- | --- | --- | --- | --- | --- | --- |
| A | 1 | 2018-01-01 | 2018-01-02 | 0 | 0 | always starts at zero |
| A | 1 | 2018-01-02 | 2018-02-03 | 0 | 0 | both cis_marker and ch_flag are the same, so remains as zero |
| A | 1 | 2018-02-03 | 2018-04-01 | 1 | **1** | ch_flag is now 1, so increase index by 1 |
| A | 1 | 2018-04-01 | 2018-04-04 | 0 | 2 | ch_flag is now 0, so increase index by 1 |

Rows with `ch_flag` equal to 1 can now be removed from the data and the `index` variable (instead of `gls_cis_marker`) used to aggregate the data to CIS level in the usual way. It may be worth running this section of code on a subset of the data to fully understand what it is doing.


### Joining SMR01 and SMR04 data, accounting for overlapping stays

There is no CIS marker inclusive of both SMR01 and SMR04 activity, however there are occassions where these stays overlap or are embedded in one another. Treating these separately and simply adding together their lengths of stay can lead to double counting. Therefore, a similar approach to the above is used to create a new 'index' variable. See the following code from `code/01_create-basefile.R`. 

```r
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(as.numeric(lead(admission_date)) >
                               cummax(as.numeric(discharge_date)))[-n()]))
```

The SMR01 and SMR04 episodes have already been aggregated to CIS level when the above code is run and so this acts as a second aggregation to account for any overlaps. As above, it may be useful to run this on a subset of the data extract to fully understand what it is doing.


### Excluding external causes of death, but including falls

There can be up to 10 causes of death recorded on a death record and we wish to exclude any deaths where any of these is an external cause. However, if there is also a cause of death due to fall recorded on the same record, then the death should be included; e.g.

| Cause of Death 1 | Cause of Death 2 | Cause of Death 3 | ... | Include/Exclude |
| --- | --- | --- | --- | --- |
| * | External | * | * | Exclude |
| * | * | Fall | * | Include |
| * | External | Fall | * | Include |

This exclusion criteria is written into the SQL queries in the `functions/sql_queries.R` script and follows the following method:

(Cause of Death 1 isn't external **AND** Cause of Death 2 isn't external **AND** ...) **OR**
   
(Cause of Death 1 is fall **OR** Cause of Death 2 is fall **OR** ...)
