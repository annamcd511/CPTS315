# CPTS315

## The Question
The first task is to discover if samples will cluster based off gene expression between patients who tested positive for Covid-19 and those who tested negative. I will also find which genes are differentially expressed between these two groups. Lastly, I will create a machine learning algorithm to classify patients as either positive or negative for Covid-19 based off of the significant differentially expressed (DE) genes.  I will test my algorithm with different learning rates and number of iterations and then evaluate the accuracy by taking the total number of correct identifications and dividing it by the total number of classifications made for both the training and testing data.

## Methods and Results
### Data Source
Data was downloaded from Gene Expression Omnibus (GEO) repository on the National Center for Biotechnology Information website.  It was originally part of a study that took place at the University of Washington [1].  The dataset consists of 484 individuals (columns) who were tested for Covid-19 and the number of reads present that correspond to each of the 35,784 genes (rows).  

### Pre-Processing
I first created a sample key for the data.  Each sample had a unique combination of the following features; Individual, age, gender, infection (positive or negative), and viral load.  Then the gene count matrix and the newly created sample key were loaded into R (version 4.2.1).  Genes were filtered out if there were less than 0.5 counts per million in at least three individuals, resulting in 27,877 genes. 

### Cluster Analysis
To visualize overall variation in gene expression, the top 10,000 variable genes were plotted on a multidimensional scaling (MDS) plot.  Differential expression was quantified using the Bioconductor package edgeR (version 3.40.0), implementing a generalized linear model (GLM). In hopes of seeing a difference between the positive and negative individuals, I categorized the points by the results of their Covid test. Even though this is a dimension reduction technique, there are still too many factors to observe any obvious patterns in gene expression among the independent variables (Figure 1).

### Differential Gene Expression Analysis
To test for statistical significance, I used the GLM quasilikelihood F test (glmQLFTest in edgeR) with a Benjamini-Hochberg correction.  Significance was set at a false discovery rate (FDR) <0.05.  I found 2,365 genes that were up regulated in the individuals that tested positive for Covid in comparison to those who tested negative and 754 that were down regulated. To further investigate the differences in gene expression, I created a boxplot for one of the most differentialy expressed genes, XAF1, which was up regulated in Covid patients (Figure 2). This is a protein-coding gene that counteracts the inhibitory effect of a member of the IAP (inhibitor of apoptosis) protein family according to the National Center for Biotechnology.

### Binary-Classifier with Perceptron Weight Update
The 15 most differentially expressed genes (ten up regulated, five down regulated) were saved into a new csv file (Table 1).  This file was loaded into Python (version 3.8) and about 75% of the samples were designated to the training set whereas the remaining 100 samples were used for testing purposes.  Using the pseudocode from the algorithm below, the classifier was implemented using different learning rates (n = 0.1, 1, 10) and iterations (1-20) to find the combination that would result in the highest training accuracy (Figure 3). The chosen model resulted in a testing accuracy of 87%.

![image](https://user-images.githubusercontent.com/67665228/233068348-0eeaa6b4-173a-4f8a-ad53-326edfe7f8f1.png)

### Challenges
One challenge I came across was having to reduce the dimensionality of the data. Before finding the number of DEgenes, I expected it to be no greater than 100. However, I was left with 13,075 which was too many to use as features in my classifier. I also had a problem where my training accuracy was extremely high, but the testing accuracy was significantly lower. I found this to be due to the fact that the samples were sorted with all of the positive samples at the top and the negatives ones at the bottom.  To create batches that were more representative of the overall dataset, I implemented a shuffle function that I could perform before each iteration.

## Figures and Tables

![image](https://user-images.githubusercontent.com/67665228/233068559-73b3e086-26b1-4784-bfdd-f65dc76012db.png) 

Figure 1. Multidimensional scaling plot of the top 10,000 common genes for the entire dataset.  The two categories we can see are the positive (black) and negative (red) samples.  There appears to be no clustering among the samples.
 
 ![image](https://user-images.githubusercontent.com/67665228/233068611-36375d46-4022-46bc-ac75-50120f43dbbe.png)

Figure 2. Level of Gene Expression in the XAF1 gene between individuals that test positive and negative for Covid-19.  The DE gene is upregulated in the comparison between positive and negative individuals.  This gene encodes a protein which binds to and counteracts the inhibitory effect of a member of the IAP (inhibitor of apoptosis) protein family.

Table 1. Table of the top differentially expressed genes that were up regulated and down regulated in the comparison between Covid positive and negative individuals.  These are the genes that were used as features in the classifier.

<img width="200" alt="image" src="https://user-images.githubusercontent.com/67665228/233068737-4b74e15c-2429-4d4f-a40c-126363f9056f.png">

 ![image](https://user-images.githubusercontent.com/67665228/233068816-5631dd5b-5b69-4bbd-bdd0-e07ec5e6426f.png)

Figure 3. Training accuracies after each iteration for the learning rates n = 0.1, 1, and 10.  Both n = 0.1 and n = 1 had the same training accuracy after each iteration.  With the increase in learning rate, the training accuracy decreased 46% by the 20th iteration.  The testing accuracies after using these learning rates for 20 iterations were 87%, 87%, and 27% respectively.

### References
[1] Lieberman, N. A., Peddu, V., Xie, H., Shrestha, L., Huang, M.-L., Mears, M. C., Cajimat, M. N., Bente, D. A., Shi, P.-Y., Bovier, F., Roychoudhury, P., Jerome, K. R., Moscona, A., Porotto, M., &amp; Greninger, A. L. (2020). In vivo antiviral host transcriptional response to SARS-COV-2 by viral load, sex, and age. PLOS Biology, 18(9). https://doi.org/10.1371/journal.pbio.3000849

