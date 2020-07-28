#########################################################################
# Name of file - 03_create-figures.R
# Data release - End of Life Publication
# Original Authors - Alice Byers
# Orginal Date - September 2019
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Create and save figures for summary and report.
#
# Approximate run time - xx minutes
#########################################################################


### 1 - Setup environment and load functions ----

source(here::here("code", "00_setup-environment.R"))
source(here::here("functions", "summarise_data.R"))


### 2 - Read in basefile ----

basefile <- read_rds(here("data", "basefiles", 
                          glue("{pub_date}_base-file.rds")))


# If provisional publication, add p superscript to latest FY
if(pub_type == "provisional")
  basefile %<>%
  mutate(fy = if_else(fy == max(.$fy), paste0(fy, "^p"), fy))


### 3 - Figure 1 - Trend Bar Chart ----
# Selects data source and years of interest
# Measures of data being percentage spent in hospital or at home/community

fig1 <- 
  
  basefile %>%
  summarise_data(include_years = "all",
                 format_numbers = FALSE) %>%
  pivot_longer(cols = qom:qom_hosp,
               names_to = "qom") %>%
  mutate(qom = if_else(qom == "qom_hosp",
                       "Hospital",
                       "Home/Community")) %>%
  
  # Control order of stacks in chart
  # Formats the design of the graph, such as font size of axis titles, legend and axis labels are also defined
  
  mutate(qom = fct_relevel(as.factor(qom), "Hospital")) %>%
  
  ggplot(aes(x = fy, y = value, fill = qom)) +
  geom_bar(position = "stack", stat = "identity", width = 0.5, show.legend = T) +
  scale_fill_manual(values = c("#00a2e5", "#004785")) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 100)) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 10, face = "bold"),
        axis.text = element_text(size = 10),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.title = element_blank(),
        axis.line = element_line(size = 0.1)) +
  scale_x_discrete(labels = parse(text = sort(unique(basefile$fy)))) +
  xlab("Financial Year of Death") + 
  ylab("Percentage")

# Save graph into the specific folder
# For this figure, 2 different versions are saved with varying height and width

ggsave(here("markdown", "figures", "figure-1.png"), 
       plot = fig1,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)

ggsave(here("markdown", "figures", "figure-1-summary.png"), 
       plot = fig1,
       width = 17, height = 7, 
       units = "cm", device = "png", dpi = 600)


### 4 - Figure 2 - Health Board Map ----
# Creates the health board map, using the basefile as the data source and mark health board as the measure

fig2 <- shapefile()

fig2@data %<>%
  left_join(summarise_data(basefile, hb,
                           format_numbers = FALSE) %>% 
              mutate(hb = substring(hb, 5)) %>%
              select(hb, qom),
            by = c("HBName" = "hb"))

fig2@data$id <- rownames(fig2@data)

# Design of the map is created, uses geom_polygon and latitude and longitude as the axis design
# Text inserted to mark the health boards with the lowest and highest percentages

fig2 <-
  full_join(tidy(fig2, region = "id"),
            fig2@data,
            by = "id")

fig2 <-
  
  ggplot() +
  geom_polygon(data = fig2,
               aes(x = long,
                   y = lat,
                   group = group,
                   fill = qom),
               colour = "white",
               size = 0.3) +
  scale_fill_continuous(low = "#56B1F7", high = "#132B43",
                        limits=c(floor(min(fig2$qom)),
                                   ceiling(max(fig2$qom)))) +
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        legend.title = element_blank()) +
  annotate("text", 
           x = 4e+05, y = 630000, 
           label = paste0("NHS ", unique(fig2$HBName[which.min(fig2$qom)]),
                          ": ", 
                          sprintf("%.1f", round_half_up(min(fig2$qom), 1)), 
                          "%"), 
           size = 2.5,
           fontface = 2) +
  annotate("text", 
           x = 4e+05, y = 1100000, 
           label = paste0("NHS ", unique(fig2$HBName[which.max(fig2$qom)]),
                          ": ", 
                          sprintf("%.1f", round_half_up(max(fig2$qom), 1)), 
                          "%"), 
           size = 2.5,
           fontface = 2)

# Map is saved in the required folder

ggsave(here("markdown", "figures", "figure-2.png"), 
       plot = fig2,
       width = 11.67, height = 14, 
       units = "cm", device = "png", dpi = 600)  


### 5 - Figure 3 - Age/Sex Bar Chart ----
# Creates the age and gender chart
# Modification required to the basefile to define 'All ages' as well as original age groups, add these to basefile

fig3 <- 
  
  basefile %>%
  filter(!is.na(sex)) %>%
  summarise_data(age_grp, sex, format_numbers = FALSE) %>%
  bind_rows(basefile %>%
              filter(!is.na(sex)) %>%
              summarise_data(age_grp = "All Ages", sex, format_numbers = FALSE)) %>%
  
  # Format of the clustered bar chart is created, x axis age group, y axis percentage, filled bars are gender
  
  ggplot(aes(x = age_grp, y = qom, fill = sex)) +
  geom_bar(position = "dodge", stat = "identity", width = 0.5, show.legend = T) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 100)) +
  scale_fill_manual(values = c("#00a2e5", "#004785")) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 10, face = "bold"),
        axis.text = element_text(size = 10),
        legend.title = element_blank(),
        axis.line = element_line(size = 0.1)) +
  xlab("Age Group") + 
  ylab("Percentage")

# Graph is then saved in the markdown folder

ggsave(here("markdown", "figures", "figure-3.png"), 
       plot = fig3,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 6 - Figure 4 - Deprivation Bar Chart ----
# Creates the deprivation chart, define basefile and SIMD as variable of interest

fig4 <- 
  
  basefile %>%
  summarise_data(simd, format_numbers = FALSE) %>%

  #This creates the bar chart, SIMD as x axis, percentge as y axis, specific font design for axis titles
  
  ggplot(aes(x = simd, y = qom, fill = 1)) +
  geom_bar(stat = "identity", width = 0.5, show.legend = F, fill = "#004785") +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 100)) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 10, face = "bold"),
        axis.text = element_text(size = 10),
        legend.title = element_blank(),
        axis.line = element_line(size = 0.1)) +
  xlab("Deprivation") + 
  ylab("Percentage")

# Chart is then saved in the markdown folder

ggsave(here("markdown", "figures", "figure-4.png"), 
       plot = fig4,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 7 - Figure 5 - Urban/Rural Bar Chart ---
# Creates the urban/rural chart, define basefile and urban_rural as the variable of interest

fig5 <- 
  
  basefile %>%
  summarise_data(urban_rural, format_numbers = FALSE) %>%
  mutate(urban_rural = str_wrap(urban_rural,
                                width = 15)) %>%

  # Creates the bar chart, urban/rural on the x axis and percentage on the y axis
    
  ggplot(aes(x = urban_rural, y = qom, fill = 1)) +
  geom_bar(stat = "identity", width = 0.5, show.legend = F, fill = "#004785") +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 100)) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 10, face = "bold"),
        axis.text = element_text(size = 10),
        legend.title = element_blank(),
        axis.line = element_line(size = 0.1)) +
  xlab("Urban / Rural Classification") + 
  ylab("Percentage")

# Chart is then saved in the markdown folder

ggsave(here("markdown", "figures", "figure-5.png"), 
       plot = fig5,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 8 - Figure A1.1 - Health Board Trends ----
# Creates multiple line charts by health board and Scotland
# Modify basefile to include Scotland total as an additional health board in order to display

figa11 <- 
  
  basefile %>%
  summarise_data(hb, include_years = "all", format_numbers = FALSE) %>%
  
  # Add row for Scotland
  bind_rows(
    basefile %>%
      summarise_data(fy, 
                     hb = "Scotland", 
                     include_years = "all", 
                     format_numbers = FALSE)
  ) %>%
  mutate(hb = forcats::fct_relevel(hb, "Scotland")) %>%

  # Designs line charts, financial year of death as x axis, percentage as y axis
  # Axis labels and font design are also defined
  # Each graph is given a heading from Scotland to start, then each hb in alphabetical order and placed on each chart
    
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line(color = "#004785") +
  facet_rep_wrap( ~ hb, ncol = 3) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 8, face = "bold"),
        axis.title.y = element_text(size = 8, face = "bold"),
        axis.text = element_text(size = 6),
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank(),
        strip.text = element_blank(),
        strip.background = element_blank(),
        axis.line = element_line(size = 0.1)) +
  scale_x_discrete(labels = parse(text = sort(unique(basefile$fy)))) +
  ylim(75, 100) +
  xlab("Financial Year of Death") + 
  ylab("Percentage") +
  geom_text(data = 
              data.frame(
                hb = c("Scotland", sort(unique(basefile$hb))),
                xpos  = rep(10, 15), ypos = rep(98, 15)), 
            aes(x = xpos, y = ypos, label = hb, group = NULL),
            size = 2.5, hjust = 1)

# Final chart is then saved in the markdown folder

ggsave(here("markdown", "figures", "figure-a1-1.png"), 
       plot = figa11,
       width = 17.48, height = 19.9,
       units = "cm", device = "png", dpi = 600)


### 9 - Figure A1.2 - HSCP Trends ----
# Creates multiple line charts by health and social care partnership, basefile is the data set to be used

figa12 <- 
  
  basefile %>%
  summarise_data(hscp, include_years = "all", format_numbers = FALSE) %>%
  
  # Designs the line charts, financial year of death as x axis, percentage as y axis
  # Axis labels and font design are also defined
  # Header given for each HSCP in alphabetical order and placed in specific position in each chart
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line(color = "#004785") +
  facet_rep_wrap( ~ hscp, ncol = 4) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 8, face = "bold"),
        axis.title.y = element_text(size = 8, face = "bold"),
        axis.text = element_text(size = 6),
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank(),
        strip.text = element_blank(),
        strip.background = element_blank()) +
  scale_x_discrete(labels = parse(text = sort(unique(basefile$fy)))) +
  ylim(75, 100) +
  geom_hline(aes(yintercept = -Inf)) + 
  geom_vline(aes(xintercept = -Inf)) +
  xlab("Financial Year of Death") + 
  ylab("Percentage") +
  geom_text(data = 
              data.frame(
                hscp = sort(unique(basefile$hscp)),
                xpos  = rep(10, 31), ypos = rep(98, 31)), 
            aes(x = xpos, y = ypos, label = hscp, group = NULL),
            size = 2.4, hjust = 1)

# Final chart is then saved in the markdown folder

ggsave(here("markdown", "figures", "figure-a1-2.png"), 
       plot = figa12,
       width = 17.48, height = 19.9, 
       units = "cm", device = "png", dpi = 600)


### 10 - Figure A1.3 - Deprivation Trends ----
# Creates multiple line charts, one for each deprivation quintile, select basefile as data source
# Rename deprivation quintiles to ensure they are more readable when displayed on the charts

figa13 <- 
  
  basefile %>%
  summarise_data(simd, include_years = "all", format_numbers = FALSE) %>%
  mutate(simd = 
           case_when(
             simd == 2 ~ "2nd Quintile",
             simd == 3 ~ "3rd Quintile",
             simd == 4 ~ "4th Quintile",
             TRUE ~ simd
           )) %>%
  
  # Designs line charts, financial year of death as x axis, percentage as y axis
  # Axis labels and font design are also defined
  # Each graph given a heading for each deprivation quintile from 1-Most deprived to 5-Least deprived
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line(color = "#004785") +
  facet_rep_wrap( ~ simd, ncol = 3) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 8, face = "bold"),
        axis.title.y = element_text(size = 8, face = "bold"),
        axis.text = element_text(size = 8),
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank(),
        strip.text = element_blank(),
        strip.background = element_blank()) +
  scale_x_discrete(labels = parse(text = sort(unique(basefile$fy)))) +
  ylim(75, 100) +
  geom_hline(aes(yintercept = -Inf)) + 
  geom_vline(aes(xintercept = -Inf)) +
  xlab("Financial Year of Death") + 
  ylab("Percentage") +
  geom_text(data = 
              data.frame(
                simd = c("1 - Most Deprived", "2nd Quintile", "3rd Quintile",
                         "4th Quintile", "5 - Least Deprived"),
                xpos  = rep(10, 5), ypos = rep(98, 5)), 
            aes(x = xpos, y = ypos, label = simd, group = NULL),
            size = 3, hjust = 1)

# Final chart is then saved in the markdown folder

ggsave(here("markdown", "figures", "figure-a1-3.png"), 
       plot = figa13,
       width = 17.48, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 11 - Figure A1.4 - Urban/Rural Trends ----
# Creates multiple line charts, one for each urban/rural description, basefile selected as data source

figa14 <- 
  
  basefile %>%
  summarise_data(urban_rural, include_years = "all", format_numbers = FALSE) %>%
  
  # Designs line charts, financial year of death as x axis, percentage as y axis
  # Axis labels and font design are also defined
  # Each graph given a heading for each urban/rural classification from 1-Large urban areas to 6-Remote rural
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line(color = "#004785") +
  facet_rep_wrap( ~ urban_rural, ncol = 3) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 8, face = "bold"),
        axis.title.y = element_text(size = 8, face = "bold"),
        axis.text = element_text(size = 8),
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank(),
        strip.text = element_blank(),
        strip.background = element_blank()) +
  scale_x_discrete(labels = parse(text = sort(unique(basefile$fy)))) +
  ylim(75, 100) +
  geom_hline(aes(yintercept = -Inf)) + 
  geom_vline(aes(xintercept = -Inf)) +
  xlab("Financial Year of Death") + 
  ylab("Percentage") +
  geom_text(data = 
              data.frame(
                urban_rural = sort(unique(basefile$urban_rural)),
                xpos  = rep(10, 6), ypos = rep(98, 6)), 
            aes(x = xpos, y = ypos, label = urban_rural, group = NULL),
            size = 3, hjust = 1)

# Final chart saved in the markdown folder

ggsave(here("markdown", "figures", "figure-a1-4.png"), 
       plot = figa14,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 12 - Figure A3.1 - Old Methodology Comparison ----
# Creates final line chart which compares old measure with the new measure which excludes care home activity
# Basefile defined as the data set and also redefinee measures to distinguish between old and new

figa31 <-
  
  basefile %>%
  summarise_data(include_years = "all", format_numbers = FALSE) %>%
  rename(qom_new = qom) %>%
  
  left_join(basefile %>%
            mutate(los = los_old) %>%
            summarise_data(include_years = "all", format_numbers = FALSE) %>%
            rename(qom_old = qom) %>%
            select(fy, qom_old)) %>%
  
  pivot_longer(cols = c("qom_old", "qom_new"),
               names_to = "method",
               values_to = "qom") %>%
  
  mutate(method = case_when(
    method == "qom_old" ~ str_wrap("Old measure", width = 12),
    method == "qom_new" ~ str_wrap(paste0("New measure (including ",
                                      "care home activity)"),
                                   width = 12)
  )) %>%
  
  # Designs the line chart, financial year of death as x axis, percentage as y axis
  # Axis labels and font design are also defined
  # Dotted line on chart is the old measure and filled line is the new measure
  
  ggplot(aes(x = fy, y = qom, group = method)) +
  geom_line(aes(linetype = method), colour = "#004785") +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 8, face = "bold"),
        axis.title.y = element_text(size = 8, face = "bold"),
        axis.text = element_text(size = 8),
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank()) +
  scale_x_discrete(labels = parse(text = sort(unique(basefile$fy)))) +
  ylim(80, 90) +
  geom_hline(aes(yintercept = -Inf)) + 
  geom_vline(aes(xintercept = -Inf)) +
  xlab("Financial Year of Death") + 
  ylab("Percentage")

# Chart then saved in the markdown folder

ggsave(here("markdown", "figures", "figure-a3-1.png"), 
       plot = figa31,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### END OF SCRIPT ###