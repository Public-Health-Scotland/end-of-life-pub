#########################################################################
# Name of file - 02_create-figures.R
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


### 3 - Figure 1 - Trend Bar Chart ----

fig1 <- 
  
  summarise_data(basefile, trend = TRUE) %>%
  select(-deaths, -comm) %>%
  mutate(qom_comm = 100 - qom) %>%
  pivot_longer(cols = qom:qom_comm,
               names_to = "qom") %>%
  mutate(qom = if_else(qom == "qom",
                       "Hopsital",
                       "Home/Community")) %>%
  
  ggplot(aes(x = fy, y = value, fill = qom)) +
  geom_bar(position = "stack", stat = "identity", width = 0.5, show.legend = T) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12)) +
  xlab("Financial Year of Death") + 
  ylab("Percentage")


### 4 - Figure 2 - Health Board Map ----


### 5 - Figure 3 ----

fig3 <- 
  
  summarise_data(basefile, age_grp, sex, trend = FALSE) %>%
  filter(sex != "null") %>%
  
  ggplot(aes(x = age_grp, y = qom, fill = sex)) +
  geom_bar(position = "dodge", stat = "identity", width = 0.5, show.legend = T) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12)) +
  xlab("Age Group") + 
  ylab("Percentage")


### 6 - Figure 4 ----

fig4 <- 
  
  summarise_data(basefile, simd, trend = FALSE) %>%
  
  ggplot(aes(x = simd, y = qom, fill = 1)) +
  geom_bar(position = "dodge", stat = "identity", width = 0.5, show.legend = F) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12)) +
  xlab("Deprivation") + 
  ylab("Percentage")


### 7 - Figure 5 ----

fig5 <- 
  
  summarise_data(basefile, urban_rural, trend = FALSE) %>%
  
  ggplot(aes(x = urban_rural, y = qom, fill = 1)) +
  geom_bar(position = "dodge", stat = "identity", width = 0.5, show.legend = F) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12)) +
  xlab("Urban / Rural Classification") + 
  ylab("Percentage")


### 8 - Figure A1 - Health Board Trends

figa1 <- 
  
  summarise_data(basefile, hb, trend = TRUE) %>%
  
  # Add row for Scotland
  bind_rows(summarise_data(basefile, trend = TRUE) %>%
              mutate(hb = "Scotland")) %>%
  mutate(hb = forcats::fct_relevel(hb, "Scotland")) %>%
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line() +
  facet_wrap( ~ hb, ncol = 3) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12)) +
  xlab("Financial Year of Death") + 
  ylab("Percentage")
