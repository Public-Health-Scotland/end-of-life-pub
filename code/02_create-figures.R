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
  
  basefile %>%
  summarise_data(include_years = "all",
                 format_numbers = FALSE) %>%
  pivot_longer(cols = qom:qom_hosp,
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

fig2 <- shapefile()

fig2@data %<>%
  left_join(summarise_data(basefile, hb,
                           format_numbers = FALSE) %>% 
              mutate(hb = substring(hb, 5)) %>%
              select(hb, qom),
            by = c("HBName" = "hb"))

fig2@data$id <- rownames(fig2@data)

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
  scale_fill_continuous(trans = "reverse") +
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        legend.title = element_blank())

ggsave(here("markdown", "figures", "figure-2.png"), 
       plot = fig2,
       width = 10, height = 12, 
       units = "cm", device = "png", dpi = 600)  


### 5 - Figure 3 - Age/Sex Bar Chart ----

fig3 <- 
  
  basefile %>%
  filter(!is.na(sex)) %>%
  summarise_data(age_grp, sex, format_numbers = FALSE) %>%
  
  ggplot(aes(x = age_grp, y = qom, fill = sex)) +
  geom_bar(position = "dodge", stat = "identity", width = 0.5, show.legend = T) +
  scale_fill_manual(values = c("#00a2e5", "#004785")) +
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
  summarise_data(simd, format_numbers = FALSE) %>%

  ggplot(aes(x = simd, y = qom, fill = 1)) +
  geom_bar(stat = "identity", width = 0.5, show.legend = F, fill = "#004785") +
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
  summarise_data(urban_rural, format_numbers = FALSE) %>%
  
  ggplot(aes(x = urban_rural, y = qom, fill = 1)) +
  geom_bar(stat = "identity", width = 0.5, show.legend = F, fill = "#004785") +
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
  summarise_data(hb, include_years = "all", format_numbers = FALSE) %>%
  
  # Add row for Scotland
  bind_rows(
    basefile %>%
      group_by(fy) %>%
      summarise(hb = "Scotland",
                qom = calculate_qom(sum(los), sum(deaths), "comm"))
  ) %>%
  mutate(hb = forcats::fct_relevel(hb, "Scotland")) %>%
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line(color = "#004785") +
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
       width = 15.43, height = 17.25, 
       units = "cm", device = "png", dpi = 600)


### 9 - Figure A1.2 - HSCP Trends ----

figa12 <- 
  
  basefile %>%
  summarise_data(hscp, include_years = "all", format_numbers = FALSE) %>%
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line(color = "#004785") +
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
       width = 15.45, height = 19.9, 
       units = "cm", device = "png", dpi = 600)


### 10 - Figure A1.3 - Deprivation Trends ----

figa13 <- 
  
  basefile %>%
  summarise_data(simd, include_years = "all", format_numbers = FALSE) %>%
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line(color = "#004785") +
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
       width = 17.48, height = 9.03, 
       units = "cm", device = "png", dpi = 600)


### 11 - Figure A1.4 - Urban/Rural Trends ----

figa14 <- 
  
  basefile %>%
  summarise_data(urban_rural, include_years = "all", format_numbers = FALSE) %>%
  
  ggplot(aes(x = fy, y = qom, group = 1)) +
  geom_line(color = "#004785") +
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