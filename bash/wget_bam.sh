#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=wget_bam_%A_%a.txt
#SBATCH --job-name=wget_bam
#SBATCH --mem=16G  # memory requested, units available: K,M,G,T

#---------------------Variables to be set-------------------------#
path=/athena/elementolab/scratch/yah2014/Projects/scRNAseq-MCL/data/bam
echo $path
cd $path
echo -e "\n\n*** Downloading files for cart: MCL_bam...\n";
wget --no-check-certificate --content-disposition --continue --user=yah2014@med.cornell.edu --password=Hy@161578 "https://abc.med.cornell.edu/pubshare/data/0/106416/2_Pt_28_PB_C1D1-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/100686/3_Pt_19_BM_C2D1-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/101689/4_Pt_13_PB_C1b-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/98231/Ib_1-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/98230/Ib_p-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/98227/Ib_R-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/95064/Pt_MD.bam" "https://abc.med.cornell.edu/pubshare/data/0/95062/Pt_MS.bam" "https://abc.med.cornell.edu/pubshare/data/0/95067/Pt_11_C1.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/99452/1_Pt_11_PB_C1-5P.bam" "https://abc.med.cornell.edu/pubshare/data/0/98231/Ib_1-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/98230/Ib_p-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/98227/Ib_R-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/98222/NZ-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/95064/Pt_MD.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/95061/Pt_RM.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/95060/Pt_1475.bam" "https://abc.med.cornell.edu/pubshare/data/0/95067/Pt_11_C1.bam" "https://abc.med.cornell.edu/pubshare/data/0/99452/1_Pt_11_PB_C1-5P.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/99451/2_Pt_11_PB_C28-5P.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/101692/1_Pt_10_LN_C2-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/101687/2_Pt_20_C1D1-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/101691/3_Pt_13_PB_C1a-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/101689/4_Pt_13_PB_C1b-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/98223/BH-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/95062/Pt_MS.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/95063/Pt_LM.bam" "https://abc.med.cornell.edu/pubshare/data/0/95060/Pt_1475.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/95065/Pt_11_C14.bam" "https://abc.med.cornell.edu/pubshare/data/0/101692/1_Pt_10_LN_C2-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/106417/1_Pt_28_LN_C1D1-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/106417/1_Pt_28_LN_C1D1-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/101688/1_Pt_2_day_0-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/101688/1_Pt_2_day_0-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/101693/2_Pt_13_BMA-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/101687/2_Pt_20_C1D1-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/100686/3_Pt_19_BM_C2D1-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/98223/BH-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/106416/2_Pt_28_PB_C1D1-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/101691/3_Pt_13_PB_C1a-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/106415/3_Pt_28_PB_C4D1-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/106414/4_Pt_28_PB_C25D1-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/101690/5_Pt_16_PB_C3-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/98224/DJ-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/95061/Pt_RM.bam" "https://abc.med.cornell.edu/pubshare/data/0/101693/2_Pt_13_BMA-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/106415/3_Pt_28_PB_C4D1-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/106414/4_Pt_28_PB_C25D1-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/101690/5_Pt_16_PB_C3-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/98224/DJ-5GEX.bam" "https://abc.med.cornell.edu/pubshare/data/0/98222/NZ-5GEX.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/95063/Pt_LM.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/95065/Pt_11_C14.bam.bai" "https://abc.med.cornell.edu/pubshare/data/0/99451/2_Pt_11_PB_C28-5P.bam" "https://abc.med.cornell.edu/pubshare/download_list_items/checksums.txt?download_list_id=2350"

echo -e "\n\n*** Running checksum...\n";
sha1sum -c *.sha1;

echo -e "\n\n*** Complete\n";
