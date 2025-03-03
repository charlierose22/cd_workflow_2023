#SETUP/CLEAN----------
# Install/load packages (working within a project so working directory is fine) 
library(tidyverse)

# Import data from excel file, using the janitor package to clean the name format up. 
# Make sure you change the name of the file to match, and check the pathway!
JAN26_data <- readxl::read_excel("~/GitHub/cd_workflow_2023/data/raw/2023-01-26-naburn-msc.xlsx") %>% 
  janitor::clean_names()

# To make sure we don't edit any raw data files, duplicate and call the original dataset "base".
Base <- JAN26_data

# filter to remove samples with no annotation, or no MS2 data.
Base_NoNA <- with(Base, Base[!(name == "" | is.na(name)), ])
Base_MS2 <- Base_NoNA[!grepl('No MS2', Base_NoNA$ms2),]

# drop unnecessary columns entirely, unless you have used them in the CD software.
Base_MS2$tags = NULL
Base_MS2$checked = NULL

# concatenate compound names and retention times to make a unique identifier, this will make things easier later on.
BaseUniqueID <- add_column(Base_MS2, unique_id = NA, .after = 0)
BaseUniqueID$unique_id <- str_c(BaseUniqueID$name, "_", BaseUniqueID$rt_min)

# add peak number in as another unique identifier.
BaseUniqueID_PeakNumber <- add_column(BaseUniqueID, peak_number = NA, .after = 0)
BaseUniqueID_PeakNumber$peak_number <- seq.int(nrow(BaseUniqueID_PeakNumber))

# starting with the group area measurements, lengthen the table to erase white space.
colnames(BaseUniqueID_PeakNumber) <- sub("*_raw_f\\d\\d*", "", colnames(BaseUniqueID_PeakNumber))

# pivot longer all in one
Longer <- BaseUniqueID_PeakNumber %>% 
  pivot_longer(cols = group_area_1_feedpump_a:peak_rating_qc3,
               names_to = "sample",
               values_to = "result")

# create a new column for sample name
SampleNames <- add_column(Longer, measurement = NA)

# fill in sample names
SampleNames <- mutate(SampleNames,
                      measurement = case_when(str_detect(sample, "group_area") ~ "group_area",
                                            str_detect(sample, "peak_rating") ~ "peak_rating"))

# clean up sample column
SampleNames$sample <- str_replace_all(SampleNames$sample, "group_area_", "")
SampleNames$sample <- str_replace_all(SampleNames$sample, "peak_rating_", "")

# pivot wider
Wider <- SampleNames %>%
  pivot_wider(names_from = measurement, values_from = result)

#FILTER----------

# remove NAs and filter so that the peak_rating column only has values above 5.
NoNAs <- drop_na(Wider, group_area)
PeakRatingFiltered <- subset(NoNAs, peak_rating > 5)

# CHANGE THIS NUMBER DEPENDING ON INTENSITY FILTER
GroupAreaFiltered <- subset(PeakRatingFiltered, group_area > 100000)

# create column for replicate IDs.
FilteredReplicate <- add_column(GroupAreaFiltered, replicate = NA)

# fill replicate file based on end of string in sample column
FilteredReplicate <- mutate(FilteredReplicate,
                            replicate = case_when(
                              str_ends(sample, "a") ~ "1",
                              str_ends(sample, "b") ~ "2",
                              str_ends(sample, "c") ~ "3"))

# Add location column for each sample and remove numbers (DO NOT PUT NUMBERS IN LOCATION TITLES! e.g. if you're talking pipe_1/pipe_2, call them pipe_a/pipe_b)
FilteredReplicate$sample_location = FilteredReplicate$sample
FilteredReplicate$sample_location <- stringi::stri_replace_all_regex(FilteredReplicate$sample_location, "^\\d|\\d|_*", "")
FilteredReplicate$sample_location <- gsub('.{1}$', '', FilteredReplicate$sample_location)

#SPECIFIC FOR THIS DATASET-----------------------------------
# correct the digester numbers (or correct anything that has number separation)
FilteredDigesterCorrect <- add_column(FilteredReplicate, digester_number = NA)
FilteredDigesterCorrect <- mutate(FilteredDigesterCorrect,
                            digester_number = case_when(
                              str_detect(sample, "digester1") ~ "A",
                              str_detect(sample, "digester2") ~ "B",
                              str_detect(sample, "digester3") ~ "C",
                              str_detect(sample, "digester4") ~ "D",
                              !str_detect(sample, "digester") ~ ""))
FilteredMerge <- add_column(FilteredDigesterCorrect, location = NA)
FilteredDigesterMerge <- FilteredMerge %>%
  unite("location", sample_location:digester_number)

# remove underscores
FilteredDigesterMerge$location <- stringi::stri_replace_all_regex(FilteredDigesterMerge$location, "_", "")

# change names back to original!
colnames(FilteredDigesterMerge)[27] = "sample_location"
FilteredReplicate <- FilteredDigesterMerge

#FILTER2------------
# Remove "solo" results.
SoloRemoved <- plyr::ddply(FilteredReplicate, c("unique_id", "sample_location"),
                      function(d) {if (nrow(d) > 1) d else NULL})

# Split by the mass_list_search column, and make two tables for mzcloud results and mass_list results
Split <- split(SoloRemoved, SoloRemoved$annot_source_mass_list_search)
MZCloud <- Split$"No results"
MassList <- Split$"Full match"

# Bring together the mass lists so we can split by specific mass list.
MassListLonger <- MassList %>% 
  pivot_longer(cols = c(starts_with("mass_list_match")) ,
               names_to = "mass_list_name",
               names_prefix = "mass_list_match_",
               values_to = "mass_list_match")

# filter for no matches in mass list.
MixRemoved <- MassListLonger[!grepl('mix', MassListLonger$sample_location),]
MixRemoved2 <- MixRemoved[!grepl('control', MixRemoved$sample_location),]
FilteredMassList <- MixRemoved2[!grepl('No matches found', MixRemoved2$mass_list_match),]

# split further into mass lists
# POSSIBLY UNIQUE TO THIS DATASE, CHANGE AS NEEDED.
SplitMassList <- split(FilteredMassList, FilteredMassList$mass_list_name)
ITN <- SplitMassList$"itn_kps"
Cannabinoids <- SplitMassList$"kps_cannabinoids"
ITNMetabolites <- SplitMassList$"itn_cyp_metabolites"

# method to count unique compounds in each
# CHANGE NAME OF MASS LIST EACH TIME, NUMBER WILL PRINT IN CONSOLE.
length(unique(ITN$unique_id))
### go into a table or a flowchart?

# create a csv of filtered results.
write.csv(ITN, "ITN-filtered-R.csv", row.names = FALSE)

#VISUALISE------------
# heatmap
heatmap <- ITN %>% 
  filter(!is.na(name)) %>% 
  ggplot(aes(y = name, 
             x = sample_location, 
             fill = group_area)) +
  geom_tile() +
  scale_y_discrete(limits = rev) +
  scale_fill_gradient2(low = "turquoise3", high = "orange", mid = "yellow", midpoint = 1.8e+08) +
  labs(x = "Wastewater Treatment Stage", y = "Compound Name", colour = "Intensity") +
  theme_bw(base_size = 14) +
  theme(panel.grid.major = element_line(colour = "gray80"),
        panel.grid.minor = element_line(colour = "gray80"),
        axis.title = element_text(family = "serif",
                                  size = 14, face = "bold", colour = "gray20"),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 13,
                                    family = "serif"),
        plot.background = element_rect(colour = NA,
                                       linetype = "solid"), legend.key = element_rect(fill = NA)) + labs(fill = "Intensity")
ggsave("Test_Heatmap.png", width = 15, height = 5)

ggThemeAssist::ggThemeAssistGadget(heatmap)

heatmap + theme(axis.title = element_text(size = 18),
    axis.text = element_text(family = "serif",
        size = 18), plot.title = element_text(size = 18))
