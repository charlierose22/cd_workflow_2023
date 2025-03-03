library(tidyverse)

# import data
Charlie_JAN26 <- readxl::read_excel(
  "Data/Charlie_KPS_26JAN_22.xlsx") %>% 
  janitor::clean_names()
Thailand_15Feb_RAW <- readxl::read_excel(
  "Data/Thailand_15Feb_RAW.xlsx") %>% 
  janitor::clean_names()
KPS_15Feb_RAW <- readxl::read_excel(
  "Data/SC_March_RAW.xlsx") %>% 
  janitor::clean_names()
KPS_March_RAW <- readxl::read_excel(
  "Data/SC_March_RAW.xlsx") %>% 
  janitor::clean_names()
KPS_May_RAW <- readxl::read_excel(
  "Data/Kgato_17thMay.xlsx") %>% 
  janitor::clean_names()

# rename for the code, might be unnecessary but it's easy
Base1 <- Charlie_JAN26
Base2 <- Thailand_15Feb_RAW
Base3 <- KPS_March_RAW
Base4 <- KPS_May_RAW

# filter to remove samples with no annotation, or no MS2 data
Base1_NoNA <- with(Base1, Base1[!(name == "" | is.na(name)), ])
Base2_NoNA <- with(Base2, Base2[!(name == "" | is.na(name)), ])
Base3_NoNA <- with(Base3, Base3[!(name == "" | is.na(name)), ])
Base4_NoNA <- with(Base4, Base4[!(name == "" | is.na(name)), ])
Base1_MS2 <- Base1_NoNA[!grepl('No MS2', Base1_NoNA$ms2),]
Base2_MS2 <- Base2_NoNA[!grepl('No MS2', Base2_NoNA$ms2),]
Base3_MS2 <- Base3_NoNA[!grepl('No MS2', Base3_NoNA$ms2),]
Base4_MS2 <- Base4_NoNA[!grepl('No MS2', Base4_NoNA$ms2),]

# drop unnecessary columns entirely, unless you have used them in the CD software
Base1_MS2$tags = NULL
Base2_MS2$tags = NULL
Base3_MS2$tags = NULL
Base4_MS2$tags = NULL
Base1_MS2$checked = NULL
Base2_MS2$checked = NULL
Base3_MS2$checked = NULL
Base4_MS2$checked = NULL

# concatenate compound names and retention times to make a unique identifier, this will make things easier later on.
BaseUniqueID1 <- add_column(Base1_MS2, unique_id = NA, .after = 0)
BaseUniqueID1$unique_id <- str_c(BaseUniqueID1$name, "_", BaseUniqueID1$rt_min)
BaseUniqueID2 <- add_column(Base2_MS2, unique_id = NA, .after = 0)
BaseUniqueID2$unique_id <- str_c(BaseUniqueID2$name, "_", BaseUniqueID2$rt_min)
BaseUniqueID3 <- add_column(Base3_MS2, unique_id = NA, .after = 0)
BaseUniqueID3$unique_id <- str_c(BaseUniqueID3$name, "_", BaseUniqueID3$rt_min)
BaseUniqueID4 <- add_column(Base4_MS2, unique_id = NA, .after = 0)
BaseUniqueID4$unique_id <- str_c(BaseUniqueID4$name, "_", BaseUniqueID4$rt_min)

# add peak number in as another unique identifier
BaseUniqueID_PeakNumber1 <- add_column(BaseUniqueID1, peak_number = NA, .after = 0)
BaseUniqueID_PeakNumber2 <- add_column(BaseUniqueID2, peak_number = NA, .after = 0)
BaseUniqueID_PeakNumber3 <- add_column(BaseUniqueID3, peak_number = NA, .after = 0)
BaseUniqueID_PeakNumber4 <- add_column(BaseUniqueID4, peak_number = NA, .after = 0)
BaseUniqueID_PeakNumber1$peak_number <- seq.int(nrow(BaseUniqueID_PeakNumber1))
BaseUniqueID_PeakNumber2$peak_number <- seq.int(nrow(BaseUniqueID_PeakNumber2))
BaseUniqueID_PeakNumber3$peak_number <- seq.int(nrow(BaseUniqueID_PeakNumber3))
BaseUniqueID_PeakNumber4$peak_number <- seq.int(nrow(BaseUniqueID_PeakNumber4))

# starting with the group area measurements 
# lengthen the table to erase white space
colnames(BaseUniqueID_PeakNumber1) <- sub("*_raw_f\\d\\d*", "", 
                                          colnames(BaseUniqueID_PeakNumber1))
colnames(BaseUniqueID_PeakNumber2) <- sub("*_raw_f\\d\\d*", "", 
                                          colnames(BaseUniqueID_PeakNumber2))
colnames(BaseUniqueID_PeakNumber3) <- sub("*_raw_f\\d\\d*", "", 
                                          colnames(BaseUniqueID_PeakNumber3))
colnames(BaseUniqueID_PeakNumber4) <- sub("*_raw_f\\d\\d*", "", 
                                          colnames(BaseUniqueID_PeakNumber4))

# pivot longer all in one
Longer1 <- BaseUniqueID_PeakNumber1 %>% 
  pivot_longer(cols = group_area_1_feedpump_a:peak_rating_qc3,
               names_to = "sample",
               values_to = "result")
Longer2 <- BaseUniqueID_PeakNumber2 %>% 
  pivot_longer(cols = group_area_crh_fst1:peak_rating_thailand_sample_8,
               names_to = "sample",
               values_to = "result")
Longer3 <- BaseUniqueID_PeakNumber3 %>% 
  pivot_longer(cols = group_area_qc15x:peak_rating_solution_x2,
               names_to = "sample",
               values_to = "result")
Longer4 <- BaseUniqueID_PeakNumber4 %>% 
  pivot_longer(cols = group_area_qc15x:peak_rating_solution_x2,
               names_to = "sample",
               values_to = "result")

# create a new column for sample name
SampleNames1 <- add_column(Longer1, measurement = NA)
SampleNames2 <- add_column(Longer2, measurement = NA)
SampleNames3 <- add_column(Longer3, measurement = NA)
SampleNames4 <- add_column(Longer4, measurement = NA)

# fill in sample names
SampleNames1 <- mutate(SampleNames1,
                      measurement = case_when(str_detect(sample, 
                                                         "group_area") ~ 
                                                "group_area",
                                              str_detect(sample, 
                                                         "peak_rating") ~ 
                                                "peak_rating"))
SampleNames2 <- mutate(SampleNames2,
                      measurement = case_when(str_detect(sample, 
                                                         "group_area") ~ 
                                                "group_area",
                                              str_detect(sample, 
                                                         "peak_rating") ~ 
                                                "peak_rating"))
SampleNames3 <- mutate(SampleNames3,
                      measurement = case_when(str_detect(sample, 
                                                         "group_area") ~ 
                                                "group_area",
                                              str_detect(sample, 
                                                         "peak_rating") ~ 
                                                "peak_rating"))
SampleNames4 <- mutate(SampleNames4,
                       measurement = case_when(str_detect(sample, 
                                                          "group_area") ~ 
                                                 "group_area",
                                               str_detect(sample, 
                                                          "peak_rating") ~ 
                                                 "peak_rating"))

# clean up sample column
SampleNames1$sample <- str_replace_all(SampleNames1$sample, "group_area_", "")
SampleNames2$sample <- str_replace_all(SampleNames2$sample, "group_area_", "")
SampleNames3$sample <- str_replace_all(SampleNames3$sample, "group_area_", "")
SampleNames4$sample <- str_replace_all(SampleNames4$sample, "group_area_", "")
SampleNames1$sample <- str_replace_all(SampleNames1$sample, "peak_rating_", "")
SampleNames2$sample <- str_replace_all(SampleNames2$sample, "peak_rating_", "")
SampleNames3$sample <- str_replace_all(SampleNames3$sample, "peak_rating_", "")
SampleNames4$sample <- str_replace_all(SampleNames4$sample, "peak_rating_", "")

# pivot wider
Wider1 <- SampleNames1 %>%
  pivot_wider(names_from = measurement, values_from = result)
Wider2 <- SampleNames2 %>%
  pivot_wider(names_from = measurement, values_from = result)
Wider3 <- SampleNames3 %>%
  pivot_wider(names_from = measurement, values_from = result)
Wider4 <- SampleNames4 %>%
  pivot_wider(names_from = measurement, values_from = result)

# remove NAs and filter so that the peak_rating column only has values above 5
NoNAs1 <- drop_na(Wider1, group_area)
NoNAs2 <- drop_na(Wider2, group_area)
NoNAs3 <- drop_na(Wider3, group_area)
NoNAs4 <- drop_na(Wider4, group_area)
PeakRatingFiltered1 <- subset(NoNAs1, peak_rating > 5)
PeakRatingFiltered2 <- subset(NoNAs2, peak_rating > 5)
PeakRatingFiltered3 <- subset(NoNAs3, peak_rating > 5)
PeakRatingFiltered4 <- subset(NoNAs4, peak_rating > 5)

# CHANGE THIS NUMBER DEPENDING ON INTENSITY FILTER
GroupAreaFiltered1 <- subset(PeakRatingFiltered1, group_area > 100000)
GroupAreaFiltered2 <- subset(PeakRatingFiltered2, group_area > 100000)
GroupAreaFiltered3 <- subset(PeakRatingFiltered3, group_area > 100000)
GroupAreaFiltered4 <- subset(PeakRatingFiltered4, group_area > 100000)

# create column for replicate IDs if possible
FilteredReplicate1 <- add_column(GroupAreaFiltered1, replicate = NA)
FilteredReplicate3 <- add_column(GroupAreaFiltered3, replicate = NA)
FilteredReplicate4 <- add_column(GroupAreaFiltered4, replicate = NA)

# fill replicate file based on end of string in sample column
FilteredReplicate1 <- mutate(FilteredReplicate1,
                            replicate = case_when(
                              str_ends(sample, "a") ~ "1",
                              str_ends(sample, "b") ~ "2",
                              str_ends(sample, "c") ~ "3"))
FilteredReplicate3 <- mutate(FilteredReplicate3,
                             replicate = case_when(
                               str_ends(sample, "x") ~ "1",
                               str_ends(sample, "1") ~ "1",
                               str_ends(sample, "2") ~ "2"))
FilteredReplicate4 <- mutate(FilteredReplicate4,
                             replicate = case_when(
                               str_ends(sample, "x") ~ "1",
                               str_ends(sample, "1") ~ "1",
                               str_ends(sample, "2") ~ "2"))

# Add location column for each sample and remove numbers
# (DO NOT PUT NUMBERS IN LOCATION TITLES! 
# e.g. if you're talking pipe_1/pipe_2, call them pipe_a/pipe_b)
FilteredReplicate1$sample_location = FilteredReplicate1$sample
FilteredReplicate3$sample_location = FilteredReplicate3$sample
FilteredReplicate4$sample_location = FilteredReplicate4$sample
FilteredReplicate1$sample_location <- stringi::stri_replace_all_regex(
  FilteredReplicate1$sample_location, "^\\d|\\d|_*", "")
FilteredReplicate3$sample_location <- stringi::stri_replace_all_regex(
  FilteredReplicate3$sample_location, "_[^_]+$", "")
FilteredReplicate4$sample_location <- stringi::stri_replace_all_regex(
  FilteredReplicate4$sample_location, "_[^_]+$", "")
FilteredReplicate1$sample_location <- gsub('.{1}$', '', 
                                           FilteredReplicate1$sample_location)

# correct the digester numbers 
# (or correct anything that has number separation)
FilteredDigesterCorrect1 <- add_column(FilteredReplicate1, digester_number = NA)
FilteredDigesterCorrect1 <- mutate(FilteredDigesterCorrect1,
                                  digester_number = case_when(
                                    str_detect(sample, "digester1") ~ "A",
                                    str_detect(sample, "digester2") ~ "B",
                                    str_detect(sample, "digester3") ~ "C",
                                    str_detect(sample, "digester4") ~ "D",
                                    !str_detect(sample, "digester") ~ ""))
FilteredMerge1 <- add_column(FilteredDigesterCorrect1, location = NA)
FilteredDigesterMerge1 <- FilteredMerge1 %>%
  unite("location", sample_location:digester_number)

# remove underscores
FilteredDigesterMerge1$location <- stringi::stri_replace_all_regex(
  FilteredDigesterMerge1$location, "_", "")

# change names back to original!
colnames(FilteredDigesterMerge1)[27] = "sample_location"
FilteredReplicate1 <- FilteredDigesterMerge1

# Remove "solo" results.
SoloRemoved1 <- plyr::ddply(FilteredReplicate1, c("name", "sample_location"),
                           function(d) {if (nrow(d) > 1) d else NULL})
SoloRemoved3 <- plyr::ddply(FilteredReplicate3, c("name", "sample_location"),
                            function(d) {if (nrow(d) > 1) d else NULL})
SoloRemoved4 <- plyr::ddply(FilteredReplicate4, c("name", "sample_location"),
                            function(d) {if (nrow(d) > 1) d else NULL})

# rename if no filtering could be done.
SoloRemoved2 <- GroupAreaFiltered2
colnames(SoloRemoved2)[21] = "sample_location"

# calculate means, std and se
Summary1 <- SoloRemoved1 %>% 
  group_by(name, sample_location) %>% 
  summarise(mean_group_area = mean(group_area))

# create tables of clean but unanalysed data
write.csv(SoloRemoved1, "Results/Clean_Charlie_26JAN.csv", row.names = FALSE)
write.csv(SoloRemoved2, "Results/Clean_Thailand.csv", row.names = FALSE)
write.csv(SoloRemoved3, "Results/Clean_Kgato_MAR.csv", row.names = FALSE)
write.csv(SoloRemoved4, "Results/Clean_Kgato_MAY.csv", row.names = FALSE)

# calculate sums for each peak in the same replicate.
Sum1 <- SoloRemoved1 %>%
  group_by(name, sample_location, replicate) %>%
  summarise(total_area = sum(group_area))
Sum3 <- SoloRemoved3 %>%
  group_by(name, sample_location, replicate) %>%
  summarise(total_area = sum(group_area))
Sum4 <- SoloRemoved4 %>%
  group_by(name, sample_location, replicate) %>%
  summarise(total_area = sum(group_area))

# Group by name and sample_location, and calculate the mean of the total_area
Mean1 <- Sum1 %>%
  group_by(name, sample_location) %>%
  summarise(mean_area = mean(total_area))
Mean3 <- Sum3 %>%
  group_by(name, sample_location) %>%
  summarise(mean_area = mean(total_area))
Mean4 <- Sum4 %>%
  group_by(name, sample_location) %>%
  summarise(mean_area = mean(total_area))

# create tables of mean data, not split.
write.csv(Mean1, "Results/Mean_Charlie_26JAN.csv", row.names = FALSE)
write.csv(Mean3, "Results/Mean_Kgato_MAR.csv", row.names = FALSE)
write.csv(Mean4, "Results/Mean_Kgato_MAY.csv", row.names = FALSE)

# Split by the mass_list_search column
# and make two tables for mzcloud results and mass_list results
Split1 <- split(SoloRemoved1, SoloRemoved1$annot_source_mass_list_search)
MZCloud1 <- Split1$"No results"
MassList1 <- Split1$"Full match"
Split2 <- split(SoloRemoved2, SoloRemoved2$annot_source_mass_list_search)
MZCloud2 <- Split2$"No results"
MassList2 <- Split2$"Full match"
Split3 <- split(SoloRemoved3, SoloRemoved3$annot_source_mass_list_search)
MZCloud3 <- Split3$"No results"
MassList3 <- Split3$"Full match"
Split4 <- split(SoloRemoved4, SoloRemoved4$annot_source_mass_list_search)
MZCloud4 <- Split4$"No results"
MassList4 <- Split4$"Full match"

# Bring together the mass lists so we can split by specific mass list.
MassListLonger1 <- MassList1 %>% 
  pivot_longer(cols = c(starts_with("mass_list_match")) ,
               names_to = "mass_list_name",
               names_prefix = "mass_list_match_",
               values_to = "mass_list_match")
MassListLonger2 <- MassList2 %>% 
  pivot_longer(cols = c(starts_with("mass_list_match")) ,
               names_to = "mass_list_name",
               names_prefix = "mass_list_match_",
               values_to = "mass_list_match")
MassListLonger3 <- MassList3 %>% 
  pivot_longer(cols = c(starts_with("mass_list_match")) ,
               names_to = "mass_list_name",
               names_prefix = "mass_list_match_",
               values_to = "mass_list_match")
MassListLonger4 <- MassList4 %>% 
  pivot_longer(cols = c(starts_with("mass_list_match")) ,
               names_to = "mass_list_name",
               names_prefix = "mass_list_match_",
               values_to = "mass_list_match")
MZLonger1 <- MZCloud1 %>% 
  pivot_longer(cols = c(starts_with("mass_list_match")) ,
               names_to = "mass_list_name",
               names_prefix = "mass_list_match_",
               values_to = "mass_list_match")
MZLonger2 <- MZCloud2 %>% 
  pivot_longer(cols = c(starts_with("mass_list_match")) ,
               names_to = "mass_list_name",
               names_prefix = "mass_list_match_",
               values_to = "mass_list_match")
MZLonger3 <- MZCloud3 %>% 
  pivot_longer(cols = c(starts_with("mass_list_match")) ,
               names_to = "mass_list_name",
               names_prefix = "mass_list_match_",
               values_to = "mass_list_match")
MZLonger4 <- MZCloud4 %>% 
  pivot_longer(cols = c(starts_with("mass_list_match")) ,
               names_to = "mass_list_name",
               names_prefix = "mass_list_match_",
               values_to = "mass_list_match")

# specific for Charlie dataset.
MixRemoved1 <- MassListLonger1[!grepl('mix', MassListLonger1$sample_location),]
MixRemoved2 <- MixRemoved1[!grepl('control', MixRemoved1$sample_location),]
MassListLonger1 <- MixRemoved2
MixRemovedMZ1 <- MZLonger1[!grepl('mix', MZLonger1$sample_location),]
MixRemovedMZ2 <- MixRemovedMZ1[!grepl('control', MixRemovedMZ1$sample_location),]
MZLonger1 <- MixRemovedMZ2

# Filter for no matches, or invalid mass.
FilteredMassList1 <- MassListLonger1[!grepl('No matches found', 
                                            MassListLonger1$mass_list_match),]
FilteredMassList2 <- MassListLonger2[!grepl('No matches found', 
                                            MassListLonger2$mass_list_match),]
FilteredMassList3 <- MassListLonger3[!grepl('No matches found', 
                                            MassListLonger3$mass_list_match),]
FilteredMassList4 <- MassListLonger4[!grepl('No matches found', 
                                            MassListLonger4$mass_list_match),]
FilteredMZCloud1 <- MZLonger1[!grepl('Invalid mass|Partial match', 
                                     MZLonger1$annot_source_mz_cloud_search),]
FilteredMZCloud2 <- MZLonger2[!grepl('Invalid mass|Partial match', 
                                     MZLonger2$annot_source_mz_cloud_search),]
FilteredMZCloud3 <- MZLonger3[!grepl('Invalid mass|Partial match', 
                                     MZLonger3$annot_source_mz_cloud_search),]
FilteredMZCloud4 <- MZLonger4[!grepl('Invalid mass|Partial match', 
                                     MZLonger4$annot_source_mz_cloud_search),]

# create a mass_list_name column so we can add the tables together.
FilteredMZCloud1$mass_list_name <- "mz_cloud"
FilteredMZCloud2$mass_list_name <- "mz_cloud"
FilteredMZCloud3$mass_list_name <- "mz_cloud"
FilteredMZCloud4$mass_list_name <- "mz_cloud"

# write csvs
write.csv(FilteredMassList1, 
          "Results/Filtered_Mass_List_Charlie_26JAN.csv", row.names = FALSE)
write.csv(FilteredMZCloud1, 
          "Results/Filtered_MZ_Cloud_Charlie_26JAN.csv", row.names = FALSE)
write.csv(FilteredMassList2, 
          "Results/Filtered_Mass_List_Thailand.csv", row.names = FALSE)
write.csv(FilteredMZCloud2, 
          "Results/Filtered_MZ_Cloud_Thailand.csv", row.names = FALSE)
write.csv(FilteredMassList3, 
          "Results/Filtered_Mass_List_Kgato_March.csv", row.names = FALSE)
write.csv(FilteredMZCloud3, 
          "Results/Filtered_MZ_Cloud_Kgato_March.csv", row.names = FALSE)
write.csv(FilteredMassList4, 
          "Results/Filtered_Mass_List_Kgato_May.csv", row.names = FALSE)
write.csv(FilteredMZCloud4, 
          "Results/Filtered_MZ_Cloud_Kgato_May.csv", row.names = FALSE)

Merge1 <- full_join(FilteredMassList1, FilteredMZCloud1)
Merge2 <- full_join(FilteredMassList2, FilteredMZCloud2)
Merge3 <- full_join(FilteredMassList3, FilteredMZCloud3)
Merge4 <- full_join(FilteredMassList4, FilteredMZCloud4)

# write csvs
write.csv(Merge1, "Results/Filtered_All_Charlie_26JAN.csv", row.names = FALSE)
write.csv(Merge2, "Results/Filtered_All_Thailand.csv", row.names = FALSE)
write.csv(Merge3, "Results/Filtered_All_Kgato_MAR.csv", row.names = FALSE)
write.csv(Merge4, "Results/Filtered_All_Kgato_MAY.csv", row.names = FALSE)

# remove duplicates in mass lists
MergeFilter1 <- Merge1 %>%
  group_by(name, sample_location) %>%
  mutate(mass_list_name = factor(
    mass_list_name, levels = c("itn_kps",
                               "itn_cyp_metabolites",
                               "kps_cannabinoids",
                               "kps_psychoactive_substances_v2",
                               "kps_pharmaceuticals_oct22",
                               "mz_cloud"), ordered = TRUE)) %>%
  arrange(mass_list_name) %>%
  slice(1L)
MergeFilter2 <- Merge2 %>%
  group_by(name, sample_location) %>%
  mutate(mass_list_name = factor(
    mass_list_name, levels = c("itn_kps","itn_cyp_metabolites",
                               "kps_cannabinoids",
                               "kps_psychoactive_substances_v2",
                               "kps_pharmaceuticals_oct22",
                               "mz_cloud"), ordered = TRUE)) %>%
  arrange(mass_list_name) %>%
  slice(1L)
MergeFilter3 <- Merge3 %>%
  group_by(name, sample_location) %>%
  mutate(mass_list_name = factor(
    mass_list_name, levels = c("itn_kps",
                               "itn_cyp_metabolites",
                               "kps_cannabinoids",
                               "kps_psychoactive_substances_v2",
                               "kps_pharmaceuticals_oct22",
                               "mz_cloud"), ordered = TRUE)) %>%
  arrange(mass_list_name) %>%
  slice(1L)
MergeFilter4 <- Merge4 %>%
  group_by(name, sample_location) %>%
  mutate(mass_list_name = factor(
    mass_list_name, levels = c("itn_kps",
                               "itn_cyp_metabolites",
                               "kps_cannabinoids",
                               "kps_psychoactive_substances_v2",
                               "kps_pharmaceuticals_oct22",
                               "mz_cloud"), ordered = TRUE)) %>%
  arrange(mass_list_name) %>%
  slice(1L)

# turn mass list name column back into character
MergeFilter1$sample_location <- as.character(MergeFilter1$sample_location)
MergeFilter2$sample_location <- as.character(MergeFilter2$sample_location)
MergeFilter3$sample_location <- as.character(MergeFilter3$sample_location)
MergeFilter4$sample_location <- as.character(MergeFilter4$sample_location)

write.csv(MergeFilter1, 
          "Results/Ordered_Mass_List_Charlie_26JAN.csv", row.names = FALSE)
write.csv(MergeFilter2, 
          "Results/Ordered_Mass_List_Thailand.csv", row.names = FALSE)
write.csv(MergeFilter3, 
          "Results/Ordered_Mass_List_Kgato_MARCH.csv", row.names = FALSE)
write.csv(MergeFilter4, 
          "Results/Ordered_Mass_List_Kgato_MAY.csv", row.names = FALSE)

# duplicate tables so we can keep retention times
RT1 <- MergeFilter1[, c("peak_number", 
                        "name", 
                        "formula", 
                        "annot_delta_mass_ppm", 
                        "calc_mw", 
                        "m_z", 
                        "rt_min", 
                        "sample_location")]
RT2 <- MergeFilter2[, c("peak_number", 
                        "name", 
                        "formula", 
                        "annot_delta_mass_ppm", 
                        "calc_mw", 
                        "m_z", 
                        "rt_min", 
                        "sample_location")]
RT3 <- MergeFilter3[, c("peak_number", 
                        "name", 
                        "formula", 
                        "annot_delta_mass_ppm", 
                        "calc_mw", 
                        "m_z", 
                        "rt_min", 
                        "sample_location")]
RT4 <- MergeFilter4[, c("peak_number", 
                        "name", 
                        "formula", 
                        "annot_delta_mass_ppm", 
                        "calc_mw", 
                        "m_z", 
                        "rt_min", 
                        "sample_location")]

write.csv(RT1, "Results/RT_Charlie_26JAN.csv", row.names = FALSE)
write.csv(RT2, "Results/RT_Thailand.csv", row.names = FALSE)
write.csv(RT3, "Results/RT_Kgato_MAR.csv", row.names = FALSE)
write.csv(RT4, "Results/RT_Kgato_MAY.csv", row.names = FALSE)

# Try sum/mean.
Sum1 <- MergeFilter1 %>%
  group_by(name, sample_location, replicate, mass_list_name) %>%
  summarise(total_area = sum(group_area))
Sum2 <- MergeFilter2 %>%
  group_by(name, sample_location, mass_list_name) %>%
  summarise(total_area = sum(group_area))
Sum3 <- MergeFilter3 %>%
  group_by(name, sample_location, replicate, mass_list_name) %>%
  summarise(total_area = sum(group_area))
Sum4 <- MergeFilter4 %>%
  group_by(name, sample_location, replicate, mass_list_name) %>%
  summarise(total_area = sum(group_area))

# Group by name and sample_location, and calculate the mean of the total_area
Mean1 <- Sum1 %>%
  group_by(name, sample_location, mass_list_name) %>%
  summarise(mean_area = mean(total_area))
Mean2 <- Sum2 %>%
  group_by(name, sample_location, mass_list_name) %>%
  summarise(mean_area = mean(total_area))
Mean3 <- Sum3 %>%
  group_by(name, sample_location, mass_list_name) %>%
  summarise(mean_area = mean(total_area))
Mean4 <- Sum4 %>%
  group_by(name, sample_location, mass_list_name) %>%
  summarise(mean_area = mean(total_area))

# create a csv of filtered results.
write.csv(Mean1, "Results/Summary_Charlie_26JAN.csv", row.names = FALSE)
write.csv(Mean2, "Results/Summary_Thailand.csv", row.names = FALSE)
write.csv(Mean3, "Results/Summary_Kgato_MAR.csv", row.names = FALSE)
write.csv(Mean4, "Results/Summary_Kgato_MAY.csv", row.names = FALSE)

# add tables together to get RT back
RT_Join1 <- RT1 %>%
  inner_join(Mean1, by = c("name", "sample_location"))
RT_Join2 <- RT2 %>%
  inner_join(Mean2, by = c("name", "sample_location"))
RT_Join3 <- RT3 %>%
  inner_join(Mean3, by = c("name", "sample_location"))
RT_Join4 <- RT4 %>%
  inner_join(Mean4, by = c("name", "sample_location"))

# for Kgato's dataset only, read in sample location key
SC_Key <- read_csv("Data/SC_Key.csv") %>% 
  janitor::clean_names()
colnames(SC_Key)[1] = "sample_location"
SC_Key$sample_location <- stringi::stri_replace_all_regex(
  SC_Key$sample_location, "_", "")
CorrectNames3 <- fuzzyjoin::regex_inner_join(RT_Join3,
                                             SC_Key,
                                             by = "sample_location", 
                                             ignore_case = TRUE)
CorrectNames3$sample_location.x = NULL
CorrectNames3$sample_location.y = NULL
CorrectNames4 <- fuzzyjoin::regex_inner_join(RT_Join4,
                                             SC_Key,
                                             by = "sample_location", 
                                             ignore_case = TRUE)
CorrectNames4$sample_location.x = NULL
CorrectNames4$sample_location.y = NULL

# concatenate location and matrix into sample_location column
CorrectLocation3 <- add_column(CorrectNames3, 
                               sample_location = NA)
CorrectLocation3$sample_location <- str_c(CorrectLocation3$location, 
                                          " ", 
                                          CorrectLocation3$matrix)
CorrectLocation3$sample_location <- tolower(CorrectLocation3$sample_location)
CorrectLocation3$location = NULL
CorrectLocation3$matrix = NULL
CorrectLocation4 <- add_column(CorrectNames4, 
                               sample_location = NA)
CorrectLocation4$sample_location <- str_c(CorrectLocation4$location, 
                                          " ", 
                                          CorrectLocation4$matrix)
CorrectLocation4$sample_location <- tolower(CorrectLocation4$sample_location)
CorrectLocation4$location = NULL
CorrectLocation4$matrix = NULL

# rename for easier downstream application.
RT_Join3 <- CorrectLocation3
RT_Join4 <- CorrectLocation4

# specific for Charlie
Biosolid1 <- RT_Join1[grepl("newdry|olddry", RT_Join1$sample_location),]
RT_Join1 <- Biosolid1

# taking the joined tables, 
# pivot wider so that each sample location is a different column header.
Wider_Run1 <- pivot_wider(RT_Join1,
                          names_from = sample_location,
                          values_from = mean_area)
Wider_Run2 <- pivot_wider(RT_Join2,
                          names_from = sample_location,
                          values_from = mean_area)
Wider_Run3 <- pivot_wider(RT_Join3,
                          names_from = sample_location,
                          values_from = mean_area)
Wider_Run4 <- pivot_wider(RT_Join4,
                          names_from = sample_location,
                          values_from = mean_area)

# create a csv of long filtered results.
write.csv(RT_Join1, "Results/Analysed_Long_Charlie_26JAN.csv", row.names = FALSE)
write.csv(RT_Join2, "Results/Analysed_Long_Thailand.csv", row.names = FALSE)
write.csv(RT_Join3, "Results/Analysed_Long_Kgato_MARCH.csv", row.names = FALSE)
write.csv(RT_Join4, "Results/Analysed_Long_Kgato_MAY.csv", row.names = FALSE)

# create a csv of filtered results.
write.csv(Wider_Run1, "Results/Analysed_Wide_Charlie_26JAN.csv", row.names = FALSE)
write.csv(Wider_Run2, "Results/Analysed_Wide_Thailand.csv", row.names = FALSE)
write.csv(Wider_Run3, "Results/Analysed_Wide_Kgato_MARCH.csv", row.names = FALSE)
write.csv(Wider_Run4, "Results/Analysed_Wide_Kgato_MAY.csv", row.names = FALSE)

# Create a loop to produce a CSV for each group of mass_list_name entries
MassListNames1 <- unique(RT_Join1$mass_list_name)
MassListNames2 <- unique(RT_Join2$mass_list_name)
MassListNames3 <- unique(RT_Join3$mass_list_name)
MassListNames4 <- unique(RT_Join4$mass_list_name)
MassListNames1 <- as.character(MassListNames1)
MassListNames2 <- as.character(MassListNames2)
MassListNames3 <- as.character(MassListNames3)
MassListNames4 <- as.character(MassListNames4)

------------------------------------

for (i in MassListNames1) {2
  filtered_df1 <- RT_Join1 %>% filter(mass_list_name == i)
  write.csv(filtered_df1, paste0("Results/", i, "_Charlie_26JAN.csv"), 
            row.names = FALSE)
}
for (i in MassListNames2) {
  filtered_df2 <- RT_Join2 %>% filter(mass_list_name == i)
  write.csv(filtered_df2, paste0("Results/", i, "_Thailand.csv"), 
            row.names = FALSE)
}
for (i in MassListNames3) {
  filtered_df3 <- RT_Join3 %>% filter(mass_list_name == i)
  write.csv(filtered_df3, paste0("Results/", i, "_Kgato_MARCH.csv"), 
            row.names = FALSE)
}

# split further into mass lists
SplitMassList1 <- split(RT_Join1, RT_Join1$mass_list_name)
SplitMassList2 <- split(RT_Join2, RT_Join2$mass_list_name)
SplitMassList3 <- split(RT_Join3, RT_Join3$mass_list_name)

ITN1 <- SplitMassList1$"itn_kps"
Cannabinoids1 <- SplitMassList1$"kps_cannabinoids"
ITNMetabolites1 <- SplitMassList1$"itn_cyp_metabolites"
Psychoactive1 <- SplitMassList1$"kps_psychoactive_substances_v2"
Pharmaceuticals1 <- SplitMassList1$"kps_pharmaceuticals_oct22"
NPL2 <- SplitMassList2$"kps_npl"
Psychoactive2 <- SplitMassList2$"kps_psychoactive_substances_v2"
Pharmaceuticals2 <- SplitMassList2$"kps_pharmaceuticals_oct22"
ITN3 <- SplitMassList3$"itn_kps"
ITNMetabolites3 <- SplitMassList3$"itn_cyp_metabolites"
Psychoactive3 <- SplitMassList3$"kps_psychoactive_substances_v2"
Pharmaceuticals3 <- SplitMassList3$"kps_pharmaceuticals_oct22"

# summary figures, easier by name
ITN1 %>% 
  filter(!is.na(name)) %>% 
  ggplot() +
  geom_tile(aes(y = name, 
                x = sample_location, 
                fill = mean_area)) +
  scale_y_discrete(limits = rev) +
  scale_fill_gradient2(low = "turquoise3", high = "orange", mid = "yellow", midpoint = 1e+08) +
  labs(x = "Treatment Stage", y = "Compound Name", colour = "Intensity") +
  theme_bw(base_size = 12) +
  theme(panel.grid.major = element_line(colour = "gray80"),
        panel.grid.minor = element_line(colour = "gray80"),
        axis.text.x = element_text(angle = 90),
        legend.text = element_text(family = "serif", 
                                   size = 12), 
        axis.text = element_text(family = "serif", 
                                 size = 12),
        axis.title = element_text(family = "serif",
                                  size = 12, face = "bold", colour = "gray20"),
        legend.title = element_text(size = 12,
                                    family = "serif"),
        plot.background = element_rect(colour = NA,
                                       linetype = "solid"), 
        legend.key = element_rect(fill = NA)) + labs(fill = "Intensity")
ggsave("Figures/ITN_Charlie_26JAN_PRES.png", width = 20, height = 25)

ITNMetabolites1 %>% 
  filter(!is.na(name)) %>% 
  ggplot() +
  geom_tile(aes(y = name, 
                x = sample_location, 
                fill = mean_area)) +
  scale_y_discrete(limits = rev) +
  scale_fill_gradient2(low = "turquoise3", high = "orange", mid = "yellow", midpoint = 1e+08) +
  labs(x = "Sample", y = "Compound Name", colour = "Intensity") +
  theme_bw(base_size = 10) +
  theme(panel.grid.major = element_line(colour = "gray80"),
        panel.grid.minor = element_line(colour = "gray80"),
        axis.text.x = element_text(angle = 90),
        legend.text = element_text(family = "serif", 
                                   size = 10), 
        axis.text = element_text(family = "serif", 
                                 size = 10),
        axis.title = element_text(family = "serif",
                                  size = 10, face = "bold", colour = "gray20"),
        legend.title = element_text(size = 10,
                                    family = "serif"),
        plot.background = element_rect(colour = NA,
                                       linetype = "solid"), 
        legend.key = element_rect(fill = NA)) + labs(fill = "Intensity")
ggsave("Figures/ITNMetabolites_Charlie_26JAN_PRES.png", width = 20, height = 25)

# Create a for loop for a ggplot for the same groups
for (i in MassListNames1) {
  filtered_df4 <- RT_Join1 %>% filter(mass_list_name == i)
  ggplot() +
    geom_tile(aes(y = name, 
                  x = sample_location, 
                  fill = mean_area)) +
    scale_y_discrete(limits = rev) +
    scale_fill_gradient2(low = "turquoise3", high = "orange", mid = "yellow") +
    labs(x = "Sample", y = "Compound Name", colour = "Intensity") +
    theme_bw(base_size = 10) +
    theme(panel.grid.major = element_line(colour = "gray80"),
          panel.grid.minor = element_line(colour = "gray80"),
          axis.text.x = element_text(angle = 90),
          legend.text = element_text(family = "serif", 
                                     size = 10), 
          axis.text = element_text(family = "serif", 
                                   size = 10),
          axis.title = element_text(family = "serif",
                                    size = 10, face = "bold", colour = "gray20"),
          legend.title = element_text(size = 10,
                                      family = "serif"),
          plot.background = element_rect(colour = NA,
                                         linetype = "solid"), 
          legend.key = element_rect(fill = NA)) + labs(fill = "Intensity")
  ggsave(filename = paste0("Figures/", i, "_Charlie_JAN.pdf"), plot = last_plot())
}

for (i in MassListNames2) {
  filtered_df5 <- RT_Join2 %>% filter(mass_list_name == i)
  ggplot() +
    geom_tile(aes(y = name, 
                  x = sample_location, 
                  fill = mean_area)) +
    scale_y_discrete(limits = rev) +
    scale_fill_gradient2(low = "turquoise3", high = "orange", mid = "yellow") +
    labs(x = "Sample", y = "Compound Name", colour = "Intensity") +
    theme_bw(base_size = 10) +
    theme(panel.grid.major = element_line(colour = "gray80"),
          panel.grid.minor = element_line(colour = "gray80"),
          axis.text.x = element_text(angle = 90),
          legend.text = element_text(family = "serif", 
                                     size = 10), 
          axis.text = element_text(family = "serif", 
                                   size = 10),
          axis.title = element_text(family = "serif",
                                    size = 10, face = "bold", colour = "gray20"),
          legend.title = element_text(size = 10,
                                      family = "serif"),
          plot.background = element_rect(colour = NA,
                                         linetype = "solid"), 
          legend.key = element_rect(fill = NA)) + labs(fill = "Intensity")
  ggsave(filename = paste0("Figures/", i, "_Thailand.pdf"), plot = last_plot())
}

for (i in MassListNames3) {
  filtered_df6 <- RT_Join3 %>% filter(mass_list_name == i)
  ggplot() +
    geom_tile(aes(y = name, 
                  x = sample_location, 
                  fill = mean_area)) +
    scale_y_discrete(limits = rev) +
    scale_fill_gradient2(low = "turquoise3", high = "orange", mid = "yellow") +
    labs(x = "Sample", y = "Compound Name", colour = "Intensity") +
    theme_bw(base_size = 10) +
    theme(panel.grid.major = element_line(colour = "gray80"),
          panel.grid.minor = element_line(colour = "gray80"),
          axis.text.x = element_text(angle = 90),
          legend.text = element_text(family = "serif", 
                                     size = 10), 
          axis.text = element_text(family = "serif", 
                                   size = 10),
          axis.title = element_text(family = "serif",
                                    size = 10, face = "bold", colour = "gray20"),
          legend.title = element_text(size = 10,
                                      family = "serif"),
          plot.background = element_rect(colour = NA,
                                         linetype = "solid"), 
          legend.key = element_rect(fill = NA)) + labs(fill = "Intensity")
  ggsave(filename = paste0("Figures/", i, "_Kgato_MAR.pdf"), plot = last_plot())
}

