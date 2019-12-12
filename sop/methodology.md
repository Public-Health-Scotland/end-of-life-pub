## Methodology

Each R script in the repository is commented as much as possible to explain what each section of the code is doing. However, there are a couple of more complex sections that require a bit more explanation. 

### Aggregating SMR data to Continuous Inpatient Stays (CIS), accounting for Care Home episodes

As Care Home episodes are not included as hospital activity, these need to be excluded before SMR data is aggregated to Continuous Inpatient Stay (CIS) level. To do this, a new 'CIS marker' is calculated to account for this. The following section of code is taken from `code/01_create-basefile.R`.
 
```r
smr01 %<>%
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(lead(ch_flag) != ch_flag | 
                              lead(gls_cis_marker) != gls_cis_marker)[-n()])) %>%
  filter(ch_flag == 0)
```

The `mutate` section of this code creates a new variable called `index`. It is important that the episodes are sorted by admission date first. This will start at 0 (zero) for every link number. If either of the following is true, the value increases by 1 compared to the previous row:
* `lead(ch_flag) != ch_flag` - Is the Care Home flag in the next row different to the one in the current row?
* `lead(gls_marker) != gls_cis_marker` - Is the CIS marker in the next row different to the one in the current row?
If either of these are true, the index increases by 1 compared to the previous row. See the following example:

| link_no | gls_cis_marker | admission_date | discharge_date | ch_flag | index | |
| --- | --- | --- | --- | --- | --- | --- |
| A | 1 | 2018-01-01 | 2018-01-02 | 0 | 0 | always starts at zero |
| A | 1 | 2018-01-02 | 2018-02-03 | 0 | 0 | both cis_marker and ch_flag are the same, so remains as zero |
| A | 1 | 2018-02-03 | 2018-04-01 | 1 | **1** | ch_flag is now 1, so increase index by 1 |
| A | 1 | 2018-04-01 | 2018-04-04 | 0 | 2 | ch_flag is now 0, so increase index by 1 |

The data is then aggregated to CIS level in the usual way using `link_no` and `index` rather than `cis_marker`.


### Joining SMR01 and SMR04 data, accounting for some overlapping stays

There is no CIS marker inclusive of both SMR01 and SMR04 data. There are occassions where these stays overlap or are embedded which risks length of stay being double counted if treated separately. A similar approach to the previous item is used to create a new `index` variable. 

```r
  group_by(link_no) %>%
  arrange(admission_date) %>%
  mutate(index = c(0, cumsum(as.numeric(lead(admission_date)) >
                               cummax(as.numeric(discharge_date)))[-n()]))
```


### Producing Figure 2 - Health Board Map

### Excluding external causes of death, but including falls
