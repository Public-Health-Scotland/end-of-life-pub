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


### 3 - Figure 1 ----

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
