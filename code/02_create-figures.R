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
source(here::here("functions", "calculate_qom.R"))


### 2 - Read in basefile ----

basefile <- read_rds(here("data", "basefiles", 
                          glue("{pub_date}_base-file.rds")))


### 3 - Figure 1 - Trend Bar Chart ----

fig1 <- 
  
  basefile %>%
  group_by(fy) %>%
  summarise(qom_hosp = calculate_qom(sum(los), sum(deaths), "hosp"),
            qom_comm = calculate_qom(sum(los), sum(deaths), "comm")) %>%
  pivot_longer(cols = qom_hosp:qom_comm,
               names_to = "qom") %>%
  mutate(qom = if_else(qom == "qom_hosp",
                       "Hospital",
                       "Home/Community")) %>%
  
  # Control order of stacks in chart
  mutate(qom = fct_relevel(as.factor(qom), "Hospital")) %>%
  
  ggplot(aes(x = fy, y = value, fill = qom)) +
  geom_bar(position = "stack", stat = "identity", width = 0.5, show.legend = T) +
  scale_fill_manual(values = c("#00a2e5", "#004785")) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 10, face = "bold"),
        axis.text = element_text(size = 10),
        axis.text.x = element_text(angle = 45),
        legend.title = element_blank()) +
  xlab("Financial Year of Death") + 
  ylab("Percentage")

ggsave(here("markdown", "figures", "figure-1.png"), 
       plot = fig1,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)

ggsave(here("markdown", "figures", "figure-1-summary.png"), 
       plot = fig1,
       width = 17, height = 7, 
       units = "cm", device = "png", dpi = 600)


### 4 - Figure 2 - Health Board Map ----


### 5 - Figure 3 - Age/Sex Bar Chart ----

fig3 <- 
  
  basefile %>%
  filter(fy == max(.$fy) & !is.na(sex)) %>%
  group_by(age_grp, sex) %>%
  summarise(qom = calculate_qom(sum(los), sum(deaths), "comm")) %>%
  
  ggplot(aes(x = age_grp, y = qom, fill = sex)) +
  geom_bar(position = "dodge", stat = "identity", width = 0.5, show.legend = T) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12),
        legend.title = element_blank()) +
  xlab("Age Group") + 
  ylab("Percentage")

ggsave(here("markdown", "figures", "figure-3.png"), 
       plot = fig3,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 6 - Figure 4 - Deprivation Bar Chart ----

fig4 <- 
  
  basefile %>%
  filter(fy == max(.$fy)) %>%
  group_by(simd) %>%
  summarise(qom = calculate_qom(sum(los), sum(deaths), "comm")) %>%
  
  ggplot(aes(x = simd, y = qom, fill = 1)) +
  geom_bar(stat = "identity", width = 0.5, show.legend = F) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12),
        legend.title = element_blank()) +
  xlab("Deprivation") + 
  ylab("Percentage")

ggsave(here("markdown", "figures", "figure-4.png"), 
       plot = fig4,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 7 - Figure 5 - Urban/Rural Bar Chart ---

fig5 <- 
  
  basefile %>%
  filter(fy == max(.$fy)) %>%
  group_by(urban_rural) %>%
  summarise(qom = calculate_qom(sum(los), sum(deaths), "comm")) %>%
  
  ggplot(aes(x = urban_rural, y = qom, fill = 1)) +
  geom_bar(stat = "identity", width = 0.5, show.legend = F) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 12),
        legend.title = element_blank()) +
  xlab("Urban / Rural Classification") + 
  ylab("Percentage")

ggsave(here("markdown", "figures", "figure-5.png"), 
       plot = fig5,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 8 - Figure A1.1 - Health Board Trends ----

figa11 <- 
  
  basefile %>%
  group_by(fy, hb) %>%
  summarise(qom = calculate_qom(sum(los), sum(deaths), "comm")) %>%
  
  # Add row for Scotland
  bind_rows(
    basefile %>%
      group_by(fy) %>%
      summarise(hb = "Scotland",
                qom = calculate_qom(sum(los), sum(deaths), "comm"))
  ) %>%
  mutate(hb = forcats::fct_relevel(hb, "Scotland")) %>%
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line() +
  facet_wrap( ~ hb, ncol = 3) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 8),
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank()) +
  ylim(75, 100) +
  xlab("Financial Year of Death") + 
  ylab("Percentage")

ggsave(here("markdown", "figures", "figure-a1-1.png"), 
       plot = figa11,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 9 - Figure A1.2 - HSCP Trends ----

figa12 <- 
  
  basefile %>%
  group_by(fy, hscp) %>%
  summarise(qom = calculate_qom(sum(los), sum(deaths), "comm")) %>%
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line() +
  facet_wrap( ~ hscp, ncol = 4) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 8),
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank()) +
  ylim(75, 100) +
  xlab("Financial Year of Death") + 
  ylab("Percentage")

ggsave(here("markdown", "figures", "figure-a1-2.png"), 
       plot = figa12,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 10 - Figure A1.3 - Deprivation Trends ----

figa13 <- 
  
  basefile %>%
  group_by(fy, simd) %>%
  summarise(qom = calculate_qom(sum(los), sum(deaths), "comm")) %>%
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line() +
  facet_wrap( ~ simd, ncol = 3) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 8),
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank()) +
  ylim(75, 100) +
  xlab("Financial Year of Death") + 
  ylab("Percentage")

ggsave(here("markdown", "figures", "figure-a1-3.png"), 
       plot = figa13,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 11 - Figure A1.4 - Urban/Rural Trends ----

figa14 <- 
  
  basefile %>%
  group_by(fy, urban_rural) %>%
  summarise(qom = calculate_qom(sum(los), sum(deaths), "comm")) %>%
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line() +
  facet_wrap( ~ urban_rural, ncol = 3) +
  theme(panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        axis.text = element_text(size = 8),
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank()) +
  ylim(75, 100) +
  xlab("Financial Year of Death") + 
  ylab("Percentage")

ggsave(here("markdown", "figures", "figure-a1-4.png"), 
       plot = figa14,
       width = 17.49, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### END OF SCRIPT ###
